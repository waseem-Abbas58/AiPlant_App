import 'dart:io';

import 'package:flutter/painting.dart';

class PlantImageStore {
  PlantImageStore._();

  static Future<String> persistCopy(
    String sourcePath, {
    String extension = 'jpg',
  }) async {
    final dir = Directory('${Directory.systemTemp.path}/ai_plant_images');
    await dir.create(recursive: true);
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
