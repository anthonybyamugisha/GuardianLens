import 'dart:async';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../config/moderation_config.dart';
import 'moderator.dart';
import 'perceptual_hash.dart';
import 'screen_capture.dart';

/// Drives the offline moderation loop: sample the screen, skip unchanged
/// frames, classify, and raise a warning (with a cooldown) when unsafe.
class MonitorController {
  MonitorController({
    required this.classifier,
    this.screenCapture = const ScreenCapture(),
  });

  final ModeratorClassifier classifier;
  final ScreenCapture screenCapture;

  /// Called for every classified frame, with the frame's JPEG bytes.
  void Function(ModerationResult result, Uint8List frameJpeg)? onResult;

  /// Called when an unsafe frame should raise a warning to the child.
  void Function(ModerationResult result)? onWarning;

  /// Called when the native side reports an error.
  void Function(Object error)? onError;

  Timer? _timer;
  bool _busy = false;
  bool _running = false;
  int? _lastHash;
  DateTime? _lastWarningAt;

  bool get isRunning => _running;

  /// Requests capture permission and starts periodic sampling.
  Future<bool> start() async {
    if (_running) return true;
    final granted = await screenCapture.requestPermission();
    if (!granted) return false;
    _running = true;
    _lastHash = null;
    _timer = Timer.periodic(ModerationConfig.sampleInterval, (_) => _tick());
    unawaited(_tick());
    return true;
  }

  /// Stops sampling and tears down the native capture service.
  Future<void> stop() async {
    _running = false;
    _timer?.cancel();
    _timer = null;
    await screenCapture.stop();
  }

  Future<void> _tick() async {
    if (!_running || _busy) return;
    _busy = true;
    try {
      final bytes = await screenCapture.captureJpeg();
      if (bytes == null) return;
      final frame = img.decodeImage(bytes);
      if (frame == null) return;

      final hash = averageHash(frame);
      final previous = _lastHash;
      if (previous != null && hammingDistance(hash, previous) <= 2) {
        return;
      }
      _lastHash = hash;

      final result = classifier.classify(frame);
      onResult?.call(result, bytes);

      if (result.isUnsafe && _cooldownElapsed) {
        _lastWarningAt = DateTime.now();
        onWarning?.call(result);
      }
    } catch (error) {
      onError?.call(error);
    } finally {
      _busy = false;
    }
  }

  bool get _cooldownElapsed {
    final last = _lastWarningAt;
    if (last == null) return true;
    return DateTime.now().difference(last) >= ModerationConfig.warningCooldown;
  }
}

