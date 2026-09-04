import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

/// Durable plant photos under app documents (not system temp).
class PlantImageStore {
  PlantImageStore._();

  static Future<Directory> _dir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/ai_plant_images');
    await dir.create(recursive: true);
    return dir;
  }

  static Future<String> persistCopy(
    String sourcePath, {
    String extension = 'jpg',
  }) async {
    final dir = await _dir();
    final dest = File(
      '${dir.path}/plant_${DateTime.now().millisecondsSinceEpoch}.$extension',
    );
    await File(sourcePath).copy(dest.path);
    await evict(dest.path);
    return dest.path;
  }

  static Future<void> evict(String path) async {
    await FileImage(File(path)).evict();
  }
}
