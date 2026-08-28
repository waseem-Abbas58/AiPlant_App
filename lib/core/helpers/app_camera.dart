import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class AppCamera {
  AppCamera._();

  static ImageFormatGroup get formatGroup => Platform.isAndroid
      ? ImageFormatGroup.yuv420
      : ImageFormatGroup.bgra8888;

  static Future<void> waitForRelease() {
    return Future<void>.delayed(const Duration(milliseconds: 400));
  }

  static Future<CameraController> open(
    CameraDescription description, {
    bool afterRelease = false,
  }) async {
    if (afterRelease) {
      await waitForRelease();
    }

    CameraException? lastError;
    for (final preset in [
      ResolutionPreset.high,
      ResolutionPreset.medium,
      ResolutionPreset.low,
    ]) {
      final controller = CameraController(
        description,
        preset,
        enableAudio: false,
        imageFormatGroup: formatGroup,
      );
      try {
        await controller.initialize();
        return controller;
      } on CameraException catch (error) {
        lastError = error;
        await controller.dispose();
      } catch (_) {
        await controller.dispose();
      }
    }
    throw lastError ??
        CameraException('initFailed', 'Could not start the camera.');
  }
}

class CoverCameraPreview extends StatelessWidget {
  const CoverCameraPreview({super.key, required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const ColoredBox(color: Color(0xFF111111));
    }

    final preview = controller.value.previewSize;
    if (preview == null) {
      return SizedBox.expand(child: CameraPreview(controller));
    }

    return ColoredBox(
      color: const Color(0xFF111111),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ClipRect(
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: preview.height,
                  height: preview.width,
                  child: CameraPreview(controller),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
