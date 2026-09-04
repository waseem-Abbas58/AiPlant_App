import 'dart:io';
import 'dart:typed_data';

/// Prepares a local plant photo for AI upload (no network).
///
/// Limits (locked for backend):
/// - Formats: JPEG / PNG only
/// - Max size: 8 MB
/// - Field name for multipart: `image`
class PlantImageUpload {
  PlantImageUpload._();

  static const maxBytes = 8 * 1024 * 1024;
  static const multipartField = 'image';

  static const _jpegMagic = [0xFF, 0xD8, 0xFF];
  static const _pngMagic = [0x89, 0x50, 0x4E, 0x47];

  /// Returns null when the file is missing, empty, too large, or not jpeg/png.
  static Future<PlantImageUploadReady?> prepare(String path) async {
    final trimmed = path.trim();
    if (trimmed.isEmpty || trimmed.startsWith('assets/')) return null;

    final file = File(trimmed);
    if (!file.existsSync()) return null;

    final length = await file.length();
    if (length <= 0 || length > maxBytes) return null;

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty || bytes.length > maxBytes) return null;

    final kind = _detectKind(bytes);
    if (kind == null) return null;

    final base = trimmed.replaceAll('\\', '/').split('/').last;
    final filename = _safeFilename(base, kind.extension);

    return PlantImageUploadReady(
      path: trimmed,
      bytes: bytes,
      filename: filename,
      contentType: kind.contentType,
      sizeBytes: bytes.length,
    );
  }

  /// Same as [prepare], but maps failure to a clear reason for UI/API.
  static Future<PlantImageUploadResult> prepareWithReason(String path) async {
    final trimmed = path.trim();
    if (trimmed.isEmpty || trimmed.startsWith('assets/')) {
      return const PlantImageUploadResult.fail(PlantImageUploadFail.invalidPath);
    }

    final file = File(trimmed);
    if (!file.existsSync()) {
      return const PlantImageUploadResult.fail(PlantImageUploadFail.missing);
    }

    final length = await file.length();
    if (length <= 0) {
      return const PlantImageUploadResult.fail(PlantImageUploadFail.empty);
    }
    if (length > maxBytes) {
      return const PlantImageUploadResult.fail(PlantImageUploadFail.tooLarge);
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      return const PlantImageUploadResult.fail(PlantImageUploadFail.empty);
    }
    if (bytes.length > maxBytes) {
      return const PlantImageUploadResult.fail(PlantImageUploadFail.tooLarge);
    }

    final kind = _detectKind(bytes);
    if (kind == null) {
      return const PlantImageUploadResult.fail(PlantImageUploadFail.unsupportedFormat);
    }

    final base = trimmed.replaceAll('\\', '/').split('/').last;
    return PlantImageUploadResult.ok(
      PlantImageUploadReady(
        path: trimmed,
        bytes: bytes,
        filename: _safeFilename(base, kind.extension),
        contentType: kind.contentType,
        sizeBytes: bytes.length,
      ),
    );
  }

  static _ImageKind? _detectKind(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == _jpegMagic[0] &&
        bytes[1] == _jpegMagic[1] &&
        bytes[2] == _jpegMagic[2]) {
      return _ImageKind.jpeg;
    }
    if (bytes.length >= 4 &&
        bytes[0] == _pngMagic[0] &&
        bytes[1] == _pngMagic[1] &&
        bytes[2] == _pngMagic[2] &&
        bytes[3] == _pngMagic[3]) {
      return _ImageKind.png;
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return _ImageKind.webp;
    }
    return null;
  }

  static String _safeFilename(String original, String extension) {
    final stem = original.contains('.')
        ? original.substring(0, original.lastIndexOf('.'))
        : original;
    final cleaned = stem
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final name = cleaned.isEmpty ? 'plant' : cleaned;
    return '$name.$extension';
  }
}

enum PlantImageUploadFail {
  invalidPath,
  missing,
  empty,
  tooLarge,
  unsupportedFormat,
}

class PlantImageUploadResult {
  const PlantImageUploadResult._({this.ready, this.fail});

  const PlantImageUploadResult.ok(PlantImageUploadReady ready)
      : this._(ready: ready);

  const PlantImageUploadResult.fail(PlantImageUploadFail fail)
      : this._(fail: fail);

  final PlantImageUploadReady? ready;
  final PlantImageUploadFail? fail;

  bool get isOk => ready != null;
}

class PlantImageUploadReady {
  const PlantImageUploadReady({
    required this.path,
    required this.bytes,
    required this.filename,
    required this.contentType,
    required this.sizeBytes,
  });

  final String path;
  final Uint8List bytes;
  final String filename;
  final String contentType;
  final int sizeBytes;

  /// Multipart map for Dio `FormData.fromMap` when API connects.
  /// Example: `FormData.fromMap({ ...ready.toFormMap(), 'categoryId': id })`
  Map<String, dynamic> toFormMap({String field = PlantImageUpload.multipartField}) {
    return {
      field: MultipartFileBytes(
        bytes: bytes,
        filename: filename,
        contentType: contentType,
      ),
    };
  }
}

/// Lightweight stand-in so UI does not depend on Dio types yet.
/// Backend wiring can convert this to `dio.MultipartFile.fromBytes`.
class MultipartFileBytes {
  const MultipartFileBytes({
    required this.bytes,
    required this.filename,
    required this.contentType,
  });

  final Uint8List bytes;
  final String filename;
  final String contentType;
}

enum _ImageKind {
  jpeg('jpg', 'image/jpeg'),
  png('png', 'image/png'),
  webp('webp', 'image/webp');

  const _ImageKind(this.extension, this.contentType);

  final String extension;
  final String contentType;
}
