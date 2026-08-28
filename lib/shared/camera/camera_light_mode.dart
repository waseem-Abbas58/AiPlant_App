import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

enum CameraLightMode { off, auto, on }

extension CameraLightModeX on CameraLightMode {
  CameraLightMode get next => switch (this) {
        CameraLightMode.off => CameraLightMode.auto,
        CameraLightMode.auto => CameraLightMode.on,
        CameraLightMode.on => CameraLightMode.off,
      };

  String get label => switch (this) {
        CameraLightMode.off => 'Off',
        CameraLightMode.auto => 'Auto',
        CameraLightMode.on => 'On',
      };

  IconData get icon => switch (this) {
        CameraLightMode.off => Icons.flash_off_rounded,
        CameraLightMode.auto => Icons.flash_auto_rounded,
        CameraLightMode.on => Icons.flash_on_rounded,
      };

  FlashMode get flashMode => switch (this) {
        CameraLightMode.off => FlashMode.off,
        CameraLightMode.auto => FlashMode.auto,
        CameraLightMode.on => FlashMode.torch,
      };
}

enum CameraFrameGuide {
  leaf,
  plant;

  String get hint => switch (this) {
        leaf => 'Fill the frame with a leaf',
        plant => 'Fill the frame with your plant',
      };

  String get chip => switch (this) {
        leaf => 'Leaf',
        plant => 'Whole plant',
      };
}
