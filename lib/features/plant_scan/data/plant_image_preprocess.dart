import 'dart:io';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';

/// Copies and normalizes scan photos under a unique scan folder (no over-compress).
class PlantImagePreprocess {
  PlantImagePreprocess._();

  static const maxEdge = 1600;

  /// Returns a stable path for this scan attempt, or null on failure.
  static Future<String?> prepare(
    String sourcePath, {
    required String scanId,
    required int index,
  }) async {
    if (sourcePath.startsWith('assets/')) return sourcePath;
    final source = File(sourcePath);
    if (!source.existsSync()) return null;

    try {
      final bytes = await source.readAsBytes();
      if (bytes.isEmpty) return null;

      ui.Codec codec;
      try {
        codec = await ui.instantiateImageCodec(
          bytes,
          targetWidth: maxEdge,
          targetHeight: maxEdge,
        );
      } catch (_) {
        codec = await ui.instantiateImageCodec(bytes);
      }
      final frame = await codec.getNextFrame();
      frame.image.dispose();

      final dir = await getTemporaryDirectory();
      final scanDir = Directory('${dir.path}/scans/$scanId');
      if (!scanDir.existsSync()) {
        await scanDir.create(recursive: true);
      }

      final ext = _extension(sourcePath);
      final dest = File('${scanDir.path}/angle_$index.$ext');
      await source.copy(dest.path);
      return dest.path;
    } catch (_) {
      return null;
    }
  }

  static Future<List<String>> prepareAll(
    List<String> paths, {
    required String scanId,
  }) async {
    final out = <String>[];
    for (var i = 0; i < paths.length; i++) {
      final prepared = await prepare(paths[i], scanId: scanId, index: i);
      if (prepared != null) out.add(prepared);
    }
    return out;
  }

  static String _extension(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    return 'jpg';
  }
}
