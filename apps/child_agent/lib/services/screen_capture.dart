import 'package:flutter/services.dart';

/// Dart bridge to the native Android MediaProjection capture plugin
/// (see `MainActivity.kt` and `ScreenCaptureService.kt`).
///
/// Android only; calls are no-ops that throw [MissingPluginException] elsewhere.
class ScreenCapture {
  const ScreenCapture();

  static const MethodChannel _channel = MethodChannel('guardianlens/capture');

  /// Shows the system screen-capture consent dialog. Returns true if granted.
  Future<bool> requestPermission() async {
    final granted = await _channel.invokeMethod<bool>('requestPermission');
    return granted ?? false;
  }

  /// True while the native capture service is active.
  Future<bool> isRunning() async {
    final running = await _channel.invokeMethod<bool>('isRunning');
    return running ?? false;
  }

  /// Returns the latest screen frame as JPEG bytes, or null if unavailable.
  Future<Uint8List?> captureJpeg() {
    return _channel.invokeMethod<Uint8List>('capture');
  }

  /// Stops the native capture service.
  Future<void> stop() => _channel.invokeMethod<void>('stop');
}
