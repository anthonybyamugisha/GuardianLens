/// Central configuration for on-device image moderation.
///
/// The model is trained and exported by the `ml/` pipeline. The quantisation
/// constants below are read directly from the exported `moderator_int8.tflite`
/// model (input int8 [1,128,128,3], output int8 [1,1]).
class ModerationConfig {
  const ModerationConfig._();

  /// TFLite asset bundle that ships inside the app (fully offline).
  static const String modelAsset = 'assets/models/moderator_int8.tflite';
  static const String labelsAsset = 'assets/models/moderator_labels.json';

  /// Square input size expected by the model.
  static const int imageSize = 128;

  /// Decision threshold on P(unsafe). Lower values favour recall (child
  /// safety), higher values favour precision. 0.4 is the tuned default.
  static const double unsafeThreshold = 0.4;

  /// How often a frame is sampled while a monitored app is active.
  static const Duration sampleInterval = Duration(seconds: 7);

  /// Minimum gap between two warnings, to avoid repeat pop-ups.
  static const Duration warningCooldown = Duration(seconds: 20);

  // --- Quantization parameters read from the exported int8 model ---
  /// Input: real = scale * (q - zeroPoint); q in [-128, 127] maps to [0, 1].
  static const double inputScale = 1.0 / 255.0;
  static const int inputZeroPoint = -128;

  /// Output: P(unsafe) = scale * (q - zeroPoint); q in [-128, 127].
  static const double outputScale = 1.0 / 256.0;
  static const int outputZeroPoint = -128;
}
