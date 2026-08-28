import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/app_camera.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../core/helpers/permission_helper.dart';
import '../../../shared/components/custom_snackbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/my_garden_controller.dart';
import '../data/plant_care_engine.dart';

class LightMeterView extends StatefulWidget {
  const LightMeterView({super.key, this.plantId});

  final String? plantId;

  @override
  State<LightMeterView> createState() => _LightMeterViewState();
}

class _LightMeterViewState extends State<LightMeterView> {
  CameraController? _camera;
  var _ready = false;
  var _luminance = 80.0;
  var _streaming = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _stopStream();
    _camera?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    await PermissionHelper.request(AppPermission.camera);
    if (!await PermissionHelper.isGranted(AppPermission.camera)) {
      CustomSnackbar.warning(
        title: 'Camera needed',
        message: 'Enable camera to measure light.',
      );
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final back = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final camera = await AppCamera.open(back, afterRelease: true);
      if (!mounted) {
        await camera.dispose();
        return;
      }
      _camera = camera;
      setState(() => _ready = true);
      await camera.startImageStream(_onImage);
      _streaming = true;
    } catch (_) {
      CustomSnackbar.error(
        title: 'Light meter',
        message: 'Could not start the camera.',
      );
    }
  }

  void _onImage(CameraImage image) {
    final value = _luminanceOf(image);
    if ((value - _luminance).abs() < 2) return;
    if (!mounted) return;
    setState(() => _luminance = value);
  }

  double _luminanceOf(CameraImage image) {
    if (image.planes.isEmpty) return 0;
    final plane = image.planes.first;
    final bytes = plane.bytes;
    if (bytes.isEmpty) return 0;
    if (image.format.group == ImageFormatGroup.bgra8888) {
      return _bgraLuma(bytes);
    }
    var sum = 0;
    final step = bytes.length > 4000 ? bytes.length ~/ 2000 : 1;
    for (var i = 0; i < bytes.length; i += step) {
      sum += bytes[i];
    }
    final count = (bytes.length / step).ceil();
    return sum / count;
  }

  double _bgraLuma(Uint8List bytes) {
    var sum = 0;
    var count = 0;
    final step = bytes.length > 8000 ? 16 : 4;
    for (var i = 0; i + 2 < bytes.length; i += step) {
      final b = bytes[i];
      final g = bytes[i + 1];
      final r = bytes[i + 2];
      sum += (r * 30 + g * 59 + b * 11) ~/ 100;
      count++;
    }
    return count == 0 ? 0 : sum / count;
  }

  Future<void> _stopStream() async {
    if (!_streaming) return;
    _streaming = false;
    try {
      await _camera?.stopImageStream();
    } catch (_) {}
  }

  void _save() {
    final plantId = widget.plantId;
    if (plantId == null || !Get.isRegistered<MyGardenController>()) {
      NavigationHelper.back();
      return;
    }
    final garden = Get.find<MyGardenController>();
    final plant = garden.plantById(plantId);
    if (plant == null) {
      NavigationHelper.back();
      return;
    }
    garden.applyLightReading(plant, PlantCareEngine.lightLabel(_luminance));
    NavigationHelper.back();
    CustomSnackbar.success(
      title: 'Light saved',
      message: '${PlantCareEngine.lightHint(_luminance)} · watering interval updated',
    );
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;
    final label = PlantCareEngine.lightHint(_luminance);
    final level = PlantCareEngine.lightLabel(_luminance);
    final canSave = widget.plantId != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_ready && camera != null)
              CoverCameraPreview(controller: camera)
            else
              const Center(
                child: CircularProgressIndicator(color: AppColors.lightGreen),
              ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.medium.w,
                  AppSpacing.small.h,
                  AppSpacing.medium.w,
                  AppSpacing.large.h,
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomContainer(
                        onTap: NavigationHelper.back,
                        width: 36,
                        height: 36,
                        color: AppColors.white.withValues(alpha: 0.94),
                        borderRadius: AppRadius.circular,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close_rounded,
                          size: 20.sp,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    const Spacer(),
                    CustomText(
                      label,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      '$level light',
                      fontSize: 15,
                      color: const Color(0xCCFFFFFF),
                    ),
                    SizedBox(height: AppSpacing.medium.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.circular.r),
                      child: LinearProgressIndicator(
                        value: (_luminance / 255).clamp(0.0, 1.0),
                        minHeight: 10.h,
                        backgroundColor: AppColors.white.withValues(alpha: 0.2),
                        color: _luminance < 40
                            ? AppColors.warning
                            : AppColors.lightGreen,
                      ),
                    ),
                    SizedBox(height: AppSpacing.large.h),
                    if (canSave)
                      CustomButton(
                        text: 'Use this reading',
                        backgroundColor: AppColors.primaryGreen,
                        textColor: AppColors.white,
                        onPressed: _save,
                      )
                    else
                      const CustomText(
                        'Open a plant to save this reading to care',
                        fontSize: 13,
                        color: Color(0xCCFFFFFF),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
