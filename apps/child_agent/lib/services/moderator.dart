import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../config/moderation_config.dart';

/// Outcome of classifying a single frame.
class ModerationResult {
  const ModerationResult({
    required this.unsafeProbability,
    required this.isUnsafe,
    required this.label,
    required this.elapsed,
  });

  /// P(unsafe), in [0, 1].
  final double unsafeProbability;

  /// True when [unsafeProbability] meets the decision threshold.
  final bool isUnsafe;

  /// Human-readable label ("safe" or "unsafe").
  final String label;

  /// Time spent in the model inference call.
  final Duration elapsed;

  @override
  String toString() =>
      'ModerationResult($label, p=${unsafeProbability.toStringAsFixed(3)}, '
      '${elapsed.inMilliseconds} ms)';
}

/// On-device image moderator.
///
/// Wraps the exported int8 TFLite model. Everything runs locally: no network,
/// no cloud service. Load once with [load] and reuse [classify] for each frame.
class ModeratorClassifier {
  ModeratorClassifier._(this._interpreter, this._labels);

  final Interpreter _interpreter;
  final List<String> _labels;

  /// Loads the bundled model and label list.
  static Future<ModeratorClassifier> load() async {
    final interpreter = await Interpreter.fromAsset(ModerationConfig.modelAsset);
    final decoded =
        jsonDecode(await rootBundle.loadString(ModerationConfig.labelsAsset))
            as Map<String, dynamic>;
    final labels = (decoded['classes'] as List).cast<String>();
    return ModeratorClassifier._(interpreter, labels);
  }

  List<String> get labels => List.unmodifiable(_labels);

  /// Classifies one frame. [image] may be any size; it is resized and
  /// quantized to match the model's training pipeline.
  ModerationResult classify(
    img.Image image, {
    double threshold = ModerationConfig.unsafeThreshold,
  }) {
    final input = _preprocess(image);

    final stopwatch = Stopwatch()..start();
    _interpreter.getInputTensor(0).data = input;
    _interpreter.invoke();
    stopwatch.stop();

    final probability = _readProbability(_interpreter.getOutputTensor(0).data);
    final isUnsafe = probability >= threshold;
    return ModerationResult(
      unsafeProbability: probability,
      isUnsafe: isUnsafe,
      label: _labels[isUnsafe ? 1 : 0],
      elapsed: stopwatch.elapsed,
    );
  }

  /// Decodes encoded bytes (e.g. a PNG screenshot) and classifies the frame.
  ModerationResult classifyBytes(
    Uint8List encoded, {
    double threshold = ModerationConfig.unsafeThreshold,
  }) {
    final decoded = img.decodeImage(encoded);
    if (decoded == null) {
      throw const FormatException('Could not decode image bytes.');
    }
    return classify(decoded, threshold: threshold);
  }

  void dispose() => _interpreter.close();

  Uint8List _preprocess(img.Image image) {
    final resized = img.copyResize(
      image,
      width: ModerationConfig.imageSize,
      height: ModerationConfig.imageSize,
      interpolation: img.Interpolation.cubic,
    );
    final rgb = resized.getBytes(order: img.ChannelOrder.rgb);

    final input =
        Uint8List(ModerationConfig.imageSize * ModerationConfig.imageSize * 3);
    for (var i = 0; i < rgb.length; i++) {
      final normalized = rgb[i] / 255.0;
      final quantized = (normalized / ModerationConfig.inputScale +
              ModerationConfig.inputZeroPoint)
          .round()
          .clamp(-128, 127);
      input[i] = quantized & 0xFF;
    }
    return input;
  }

  /// Reads P(unsafe) from the int8 output tensor: real = scale * (q - zero).
  double _readProbability(Uint8List output) {
    final raw = output[0];
    final signed = raw > 127 ? raw - 256 : raw;
    return (ModerationConfig.outputScale *
            (signed - ModerationConfig.outputZeroPoint))
        .clamp(0.0, 1.0);
  }
}
