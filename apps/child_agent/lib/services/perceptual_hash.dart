import 'package:image/image.dart' as img;

/// Computes a 64-bit average hash (aHash) of an image.
///
/// Used to skip frames that are visually identical to the previous one, so the
/// classifier is not run on a static screen.
int averageHash(img.Image image, {int size = 8}) {
  final small = img.copyResize(
    image,
    width: size,
    height: size,
    interpolation: img.Interpolation.average,
  );
  final gray = img.grayscale(small);

  final values = <int>[];
  var sum = 0;
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final value = gray.getPixel(x, y).r.toInt();
      values.add(value);
      sum += value;
    }
  }

  final average = sum / values.length;
  var hash = 0;
  for (var i = 0; i < values.length; i++) {
    if (values[i] >= average) hash |= 1 << i;
  }
  return hash;
}

/// Hamming distance between two 64-bit hashes (number of differing bits).
int hammingDistance(int a, int b) {
  var x = a ^ b;
  var count = 0;
  while (x != 0) {
    count += x & 1;
    x >>= 1;
  }
  return count;
}
