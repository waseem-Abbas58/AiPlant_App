import 'dart:io';
import 'dart:ui' as ui;

/// On-device scene check. Not live species ID.
/// A plant must show real leaf green (g > r, g > b). Bright desks, keyboards,
/// and warm indoor whites do not count as bark or flowers.
class PlantSceneGate {
  PlantSceneGate._();

  static const enabled = true;

  static Future<bool> looksLikePlant(
    String imagePath, {
    String categoryId = 'plant',
  }) async {
    if (!enabled) return true;
    try {
      final bytes = await File(imagePath).readAsBytes();
      if (bytes.isEmpty) return false;

      ui.Codec codec;
      try {
        codec = await ui.instantiateImageCodec(
          bytes,
          targetWidth: 96,
          targetHeight: 96,
        );
      } catch (_) {
        codec = await ui.instantiateImageCodec(bytes);
      }
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      if (data == null) return false;

      final pixels = data.buffer.asUint8List();
      var green = 0;
      var bark = 0;
      var counted = 0;

      for (var i = 0; i + 3 < pixels.length; i += 4) {
        if (pixels[i + 3] < 40) continue;
        counted++;
        final r = pixels[i] / 255.0;
        final g = pixels[i + 1] / 255.0;
        final b = pixels[i + 2] / 255.0;
        final max = r > g ? (r > b ? r : b) : (g > b ? g : b);
        final min = r < g ? (r < b ? r : b) : (g < b ? g : b);
        final v = max;
        final s = max == 0 ? 0.0 : (max - min) / max;
        final h = _hue(r, g, b, max, min);

        final leafGreen = g > r + 0.04 &&
            g > b + 0.02 &&
            g > 0.16 &&
            s > 0.12 &&
            v < 0.92;
        final hsvLeaf = h >= 72 &&
            h <= 168 &&
            s > 0.22 &&
            v > 0.16 &&
            v < 0.90 &&
            g >= r;
        if (leafGreen || hsvLeaf) {
          green++;
          continue;
        }

        final darkBark = r > g + 0.03 &&
            g >= b &&
            s > 0.24 &&
            v > 0.10 &&
            v < 0.50;
        if (darkBark) bark++;
      }

      if (counted < 80) return false;

      final greenShare = green / counted;
      final barkShare = bark / counted;
      if (greenShare >= 0.10) return true;
      if (categoryId == 'tree' &&
          (greenShare >= 0.06 || barkShare >= 0.14)) {
        return true;
      }
      if (categoryId == 'mushroom' &&
          (greenShare >= 0.05 || barkShare >= 0.12)) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static double _hue(double r, double g, double b, double max, double min) {
    if (max == min) return 0;
    final d = max - min;
    var h = max == r
        ? ((g - b) / d) % 6
        : max == g
            ? (b - r) / d + 2
            : (r - g) / d + 4;
    h *= 60;
    if (h < 0) h += 360;
    return h;
  }
}
