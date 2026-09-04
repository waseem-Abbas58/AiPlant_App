import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../model/plant_identify_result.dart';

/// On-device photo quality checks before identification (no API).
class PlantPhotoQuality {
  PlantPhotoQuality._();

  static const _decodeSize = 256;
  static const _minEdgePx = 400;
  static const _blurVarianceMin = 12.0;
  static const _darkLuminanceMax = 0.14;

  static Future<IdentifyFailReason?> check(String imagePath) async {
    if (imagePath.startsWith('assets/')) return null;
    final file = File(imagePath);
    if (!file.existsSync()) return IdentifyFailReason.lowQuality;

    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return IdentifyFailReason.lowQuality;

      ui.Codec codec;
      try {
        codec = await ui.instantiateImageCodec(bytes);
      } catch (_) {
        return IdentifyFailReason.lowQuality;
      }
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final w = image.width;
      final h = image.height;

      if (math.min(w, h) < _minEdgePx) {
        image.dispose();
        return IdentifyFailReason.subjectTooSmall;
      }

      final thumb = await _decodeThumb(bytes);
      image.dispose();
      if (thumb == null) return IdentifyFailReason.lowQuality;

      if (_meanLuminance(thumb.pixels) < _darkLuminanceMax) {
        return IdentifyFailReason.tooDark;
      }

      // Soft phone/Pinterest photos were falsely rejected as tooBlurry
      // before Kindwise. Kindwise handles mild blur; do not block here.

      if (_centerSubjectShare(thumb.pixels, thumb.width, thumb.height) <
          0.08) {
        return IdentifyFailReason.subjectTooSmall;
      }

      if (_looksLikeMultiplePlants(thumb.pixels, thumb.width, thumb.height)) {
        return IdentifyFailReason.multiplePlants;
      }

      return null;
    } catch (_) {
      return IdentifyFailReason.lowQuality;
    }
  }

  /// True when two photos are nearly identical (duplicate angle).
  static Future<bool> areNearDuplicate(String a, String b) async {
    if (a == b) return true;
    try {
      final ta = await _decodeThumb(await File(a).readAsBytes(), size: 32);
      final tb = await _decodeThumb(await File(b).readAsBytes(), size: 32);
      if (ta == null || tb == null) return false;
      if (ta.width != tb.width || ta.height != tb.height) return false;
      var diff = 0.0;
      final n = ta.pixels.length;
      for (var i = 0; i < n; i++) {
        diff += (ta.pixels[i] - tb.pixels[i]).abs();
      }
      return diff / n < 8.0;
    } catch (_) {
      return false;
    }
  }

  static Future<_ThumbData?> _decodeThumb(
    Uint8List bytes, {
    int size = _decodeSize,
  }) async {
    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: size,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final w = image.width;
      final h = image.height;
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      if (data == null || w < 3 || h < 3) return null;

      final rgba = data.buffer.asUint8List();
      final gray = Float32List(w * h);
      for (var i = 0, p = 0; p < gray.length; p++, i += 4) {
        final r = rgba[i] / 255.0;
        final g = rgba[i + 1] / 255.0;
        final b = rgba[i + 2] / 255.0;
        gray[p] = 0.299 * r + 0.587 * g + 0.114 * b;
      }
      return _ThumbData(w, h, gray);
    } catch (_) {
      return null;
    }
  }

  static double _meanLuminance(Float32List gray) {
    if (gray.isEmpty) return 0;
    var sum = 0.0;
    for (final v in gray) {
      sum += v;
    }
    return sum / gray.length;
  }

  static double _laplacianVariance(Float32List gray, int w, int h) {
    if (w < 3 || h < 3) return 0;
    var sum = 0.0;
    var sumSq = 0.0;
    var count = 0;
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final i = y * w + x;
        final lap = -4 * gray[i] +
            gray[i - 1] +
            gray[i + 1] +
            gray[i - w] +
            gray[i + w];
        sum += lap;
        sumSq += lap * lap;
        count++;
      }
    }
    if (count == 0) return 0;
    final mean = sum / count;
    return sumSq / count - mean * mean;
  }

  /// Share of non-background detail in the center crop.
  static double _centerSubjectShare(Float32List gray, int w, int h) {
    final x0 = (w * 0.2).floor();
    final x1 = (w * 0.8).ceil();
    final y0 = (h * 0.2).floor();
    final y1 = (h * 0.8).ceil();
    var strong = 0;
    var total = 0;
    for (var y = y0; y < y1; y++) {
      for (var x = x0; x < x1; x++) {
        if (x <= 0 || y <= 0 || x >= w - 1 || y >= h - 1) continue;
        final i = y * w + x;
        final gx = (gray[i + 1] - gray[i - 1]).abs();
        final gy = (gray[i + w] - gray[i - w]).abs();
        if (gx + gy > 0.08) strong++;
        total++;
      }
    }
    if (total == 0) return 0;
    return strong / total;
  }

  static bool _looksLikeMultiplePlants(Float32List gray, int w, int h) {
    if (w < 9 || h < 9) return false;
    final left = _edgeDetailShare(gray, w, h, 0.0, 0.33);
    final center = _edgeDetailShare(gray, w, h, 0.33, 0.66);
    final right = _edgeDetailShare(gray, w, h, 0.66, 1.0);
    return left > 0.10 && right > 0.10 && center < 0.06;
  }

  static double _edgeDetailShare(
    Float32List gray,
    int w,
    int h,
    double startX,
    double endX,
  ) {
    final x0 = (w * startX).floor().clamp(1, w - 2);
    final x1 = (w * endX).ceil().clamp(1, w - 1);
    var strong = 0;
    var total = 0;
    for (var y = 1; y < h - 1; y++) {
      for (var x = x0; x < x1; x++) {
        final i = y * w + x;
        final gx = (gray[i + 1] - gray[i - 1]).abs();
        final gy = (gray[i + w] - gray[i - w]).abs();
        if (gx + gy > 0.08) strong++;
        total++;
      }
    }
    if (total == 0) return 0;
    return strong / total;
  }

  static Future<IdentifyFailReason?> firstDuplicateIn(List<String> paths) async {
    for (var i = 1; i < paths.length; i++) {
      for (var j = 0; j < i; j++) {
        if (await areNearDuplicate(paths[i], paths[j])) {
          return IdentifyFailReason.duplicateAngle;
        }
      }
    }
    return null;
  }
}

class _ThumbData {
  const _ThumbData(this.width, this.height, this.pixels);

  final int width;
  final int height;
  final Float32List pixels;
}
