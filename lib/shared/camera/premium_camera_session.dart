import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera_light_mode.dart';

class PremiumCameraSession {
  CameraLightMode light = CameraLightMode.off;
  CameraFrameGuide guide = CameraFrameGuide.leaf;
  double zoom = 1;
  double minZoom = 1;
  double maxZoom = 1;
  Offset? focusLocal;
  var showFocus = false;
  var showLowLightHint = false;
  var shutterBurst = false;
  VoidCallback? onTick;

  double _pinchBase = 1;
  Timer? _focusTimer;
  Timer? _hintTimer;
  Timer? _shutterTimer;

  void _notify() => onTick?.call();

  Future<void> bind(CameraController? camera) async {
    if (camera == null || !camera.value.isInitialized) return;
    try {
      minZoom = await camera.getMinZoomLevel();
      maxZoom = await camera.getMaxZoomLevel();
    } catch (_) {
      minZoom = 1;
      maxZoom = 1;
    }
    zoom = zoom.clamp(minZoom, maxZoom);
    try {
      await camera.setZoomLevel(zoom);
    } catch (_) {}
    await applyLight(camera);
  }

  Future<void> applyLight(CameraController camera) async {
    try {
      await camera.setFlashMode(light.flashMode);
    } catch (_) {
      if (light == CameraLightMode.on) {
        try {
          await camera.setFlashMode(FlashMode.always);
        } catch (_) {}
      }
    }
  }

  Future<void> cycleLight(CameraController camera) async {
    HapticFeedback.selectionClick();
    light = light.next;
    showLowLightHint = false;
    await applyLight(camera);
  }

  Future<void> turnLightOn(CameraController camera) async {
    light = CameraLightMode.on;
    showLowLightHint = false;
    await applyLight(camera);
  }

  void dismissLowLightHint() {
    showLowLightHint = false;
  }

  Future<void> setZoom(CameraController camera, double value) async {
    zoom = value.clamp(minZoom, maxZoom);
    try {
      await camera.setZoomLevel(zoom);
    } catch (_) {}
    _notify();
  }

  Future<void> nudgeZoom(CameraController camera, double dy) {
    final range = (maxZoom - minZoom).clamp(0.8, 10.0);
    return setZoom(camera, zoom - dy * range / 240);
  }

  void beginPinch() {
    _pinchBase = zoom;
  }

  Future<void> updatePinch(CameraController camera, double scale) {
    return setZoom(camera, _pinchBase * scale);
  }

  Future<void> focusAt(
    CameraController camera,
    Offset local,
    Size area,
  ) async {
    if (area.width <= 0 || area.height <= 0) return;
    final nx = (local.dx / area.width).clamp(0.0, 1.0);
    final ny = (local.dy / area.height).clamp(0.0, 1.0);
    focusLocal = local;
    showFocus = true;
    _focusTimer?.cancel();
    _focusTimer = Timer(const Duration(milliseconds: 900), () {
      showFocus = false;
      _notify();
    });
    HapticFeedback.selectionClick();
    try {
      await camera.setFocusMode(FocusMode.auto);
      await camera.setFocusPoint(Offset(nx, ny));
      await camera.setExposurePoint(Offset(nx, ny));
    } catch (_) {}
  }

  void playShutter() {
    HapticFeedback.mediumImpact();
    shutterBurst = true;
    _shutterTimer?.cancel();
    _shutterTimer = Timer(const Duration(milliseconds: 120), () {
      shutterBurst = false;
      _notify();
    });
  }

  void resetForNewLens() {
    zoom = 1;
    light = CameraLightMode.off;
    showLowLightHint = false;
    showFocus = false;
    focusLocal = null;
  }

  void dispose() {
    _focusTimer?.cancel();
    _hintTimer?.cancel();
    _shutterTimer?.cancel();
  }
}
