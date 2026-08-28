import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/app_camera.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../core/helpers/permission_helper.dart';
import '../../../core/helpers/plant_image_store.dart';
import '../widgets/plant_crop_sheet.dart';
import '../../../shared/camera/premium_camera_session.dart';
import '../../../shared/camera/premium_camera_widgets.dart';
import '../../../shared/components/custom_snackbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../plant_scan/controller/plant_scan_controller.dart';

enum _AddCameraStatus { starting, ready, failed }

class AddPlantCameraView extends StatefulWidget {
  const AddPlantCameraView({super.key});

  @override
  State<AddPlantCameraView> createState() => _AddPlantCameraViewState();
}

class _AddPlantCameraViewState extends State<AddPlantCameraView> {
  static const _black = Color(0xFF111111);

  CameraController? _camera;
  List<CameraDescription> _cameras = [];
  var _status = _AddCameraStatus.starting;
  var _busy = false;
  var _usingFront = false;
  String? _reviewPath;
  final _session = PremiumCameraSession();

  @override
  void initState() {
    super.initState();
    _session.onTick = () {
      if (mounted) setState(() {});
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _start();
    });
  }

  @override
  void dispose() {
    _session.dispose();
    _camera?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _status = _AddCameraStatus.starting);

    if (Get.isRegistered<PlantScanController>()) {
      await Get.find<PlantScanController>().releaseCamera();
    }

    await PermissionHelper.request(AppPermission.camera);
    if (!mounted) return;
    if (!await PermissionHelper.isGranted(AppPermission.camera)) {
      final permanentlyDenied =
          await PermissionHelper.isPermanentlyDenied(AppPermission.camera);
      if (!mounted) return;
      CustomSnackbar.warning(
        title: 'Camera needed',
        message: permanentlyDenied
            ? 'Enable camera in Settings to take a photo.'
            : 'Camera permission is required to take a photo.',
        actionLabel: permanentlyDenied ? 'Settings' : null,
        onAction: permanentlyDenied ? PermissionHelper.openSettings : null,
      );
      setState(() => _status = _AddCameraStatus.failed);
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty || !mounted) {
        setState(() => _status = _AddCameraStatus.failed);
        return;
      }
      await _openCamera(_backOrFirst(), afterRelease: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = _AddCameraStatus.failed);
    }
  }

  CameraDescription _backOrFirst() {
    if (_usingFront) {
      return _cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );
    }
    return _cameras.firstWhere(
      (item) => item.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );
  }

  Future<void> _openCamera(
    CameraDescription description, {
    required bool afterRelease,
  }) async {
    final previous = _camera;
    _camera = null;
    if (mounted) setState(() => _status = _AddCameraStatus.starting);
    await previous?.dispose();

    try {
      final next = await AppCamera.open(
        description,
        afterRelease: afterRelease || previous != null,
      );
      if (!mounted) {
        await next.dispose();
        return;
      }
      _camera = next;
      await _session.bind(next);
      if (!mounted) return;
      setState(() => _status = _AddCameraStatus.ready);
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = _AddCameraStatus.failed);
    }
  }

  Future<void> _flip() async {
    if (_busy || _cameras.length < 2) return;
    _usingFront = !_usingFront;
    _session.resetForNewLens();
    await _openCamera(_backOrFirst(), afterRelease: true);
  }

  Future<void> _showReview(String path) async {
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() => _reviewPath = path);
  }

  void _retake() {
    setState(() => _reviewPath = null);
  }

  Future<void> _cropReview() async {
    final current = _reviewPath;
    if (current == null || _busy) return;
    final cropped = await showPlantCropSheet(context, current);
    if (!mounted || cropped == null || cropped.isEmpty) return;
    setState(() => _reviewPath = cropped);
  }

  Future<void> _usePhoto() async {
    final current = _reviewPath;
    if (current == null || _busy) return;
    setState(() => _busy = true);
    try {
      final path = await PlantImageStore.persistCopy(current);
      if (!mounted) return;
      NavigationHelper.back(path);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _capture() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_status != _AddCameraStatus.ready || _camera == null) {
        CustomSnackbar.error(
          title: 'Camera not ready',
          message: 'Wait a moment, or pick a photo from gallery.',
        );
        return;
      }
      _session.playShutter();
      setState(() {});
      final shot = await _camera!.takePicture();
      if (!mounted) return;
      await _showReview(shot.path);
    } catch (_) {
      CustomSnackbar.error(
        title: 'Capture failed',
        message: 'Try again or pick a photo from gallery.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openGallery() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (!mounted || file == null) return;
      await _showReview(file.path);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _status == _AddCameraStatus.ready &&
        _camera != null &&
        _camera!.value.isInitialized;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (ready)
              CameraPreviewGestures(
                camera: _camera!,
                session: _session,
                onChanged: () {
                  if (mounted) setState(() {});
                },
                child: CoverCameraPreview(controller: _camera!),
              )
            else
              const ColoredBox(color: _black),
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x99000000),
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0xCC000000),
                      ],
                      stops: [0, 0.16, 0.58, 1],
                    ),
                  ),
                ),
              ),
            ),
            if (_status == _AddCameraStatus.starting)
              const _CameraStatusOverlay(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                    SizedBox(height: 16),
                    CustomText(
                      'Starting camera',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            if (_status == _AddCameraStatus.failed)
              _CameraStatusOverlay(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      color: AppColors.white.withValues(alpha: 0.85),
                      size: 36.sp,
                    ),
                    SizedBox(height: AppSpacing.medium.h),
                    const CustomText(
                      'Could not start camera',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                    SizedBox(height: 6.h),
                    CustomText(
                      'Retry, or pick a photo from gallery.',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: 0.72),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.large.h),
                    CustomContainer(
                      onTap: _busy ? null : _start,
                      color: AppColors.white,
                      borderRadius: AppRadius.circular,
                      padding: EdgeInsets.symmetric(
                        horizontal: 22.w,
                        vertical: 10.h,
                      ),
                      child: const CustomText(
                        'Retry',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            if (_reviewPath == null)
              Column(
                children: [
                  Expanded(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.medium.w,
                          AppSpacing.small.h,
                          AppSpacing.medium.w,
                          AppSpacing.small.h,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _FrostedCircle(
                                  icon: Icons.close_rounded,
                                  onTap: NavigationHelper.back,
                                ),
                                const Expanded(
                                  child: CustomText(
                                    'Add Plant',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                    textAlign: TextAlign.center,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                if (ready)
                                  CameraFlashButton(
                                    mode: _session.light,
                                    onTap: () async {
                                      await _session.cycleLight(_camera!);
                                      if (mounted) setState(() {});
                                    },
                                  )
                                else
                                  SizedBox(width: 40.w, height: 40.h),
                              ],
                            ),
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IgnorePointer(
                                      child: SizedBox(
                                        width: 236.w,
                                        height: 236.w,
                                        child: CustomPaint(
                                          painter: _AddFramePainter(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.medium.h),
                                    CameraGuideHint(text: _session.guide.hint),
                                    SizedBox(height: AppSpacing.small.h + 4.h),
                                    CameraFrameGuideToggle(
                                      value: _session.guide,
                                      onChanged: (value) {
                                        setState(() => _session.guide = value);
                                      },
                                    ),
                                    SizedBox(height: AppSpacing.small.h),
                                    CameraZoomLabel(zoom: _session.zoom),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CameraControlDock(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _FrostedCircle(
                          icon: Icons.photo_outlined,
                          onTap: _openGallery,
                          large: true,
                        ),
                        CameraShutterButton(
                          enabled: !_busy && ready,
                          onPressed: _busy || !ready ? null : _capture,
                        ),
                        _FrostedCircle(
                          icon: Icons.cameraswitch_outlined,
                          onTap: _flip,
                          large: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            CameraShutterFlash(visible: _session.shutterBurst),
            if (_reviewPath != null)
              _PhotoReviewOverlay(
                path: _reviewPath!,
                busy: _busy,
                onRetake: _retake,
                onCrop: _cropReview,
                onUse: _usePhoto,
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoReviewOverlay extends StatelessWidget {
  const _PhotoReviewOverlay({
    required this.path,
    required this.busy,
    required this.onRetake,
    required this.onCrop,
    required this.onUse,
  });

  final String path;
  final bool busy;
  final VoidCallback onRetake;
  final VoidCallback onCrop;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ColoredBox(
      color: const Color(0xFF111111),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(path),
            fit: BoxFit.cover,
            key: ValueKey(path),
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Color(0xFF111111),
            ),
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99000000),
                    Color(0x00000000),
                    Color(0xCC000000),
                  ],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.medium.w,
                AppSpacing.small.h,
                AppSpacing.medium.w,
                AppSpacing.large.h + bottomInset,
              ),
              child: Column(
                children: [
                  const CustomText(
                    'Use this photo?',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Retake',
                          backgroundColor: const Color(0xFF2A2A2A),
                          textColor: AppColors.white,
                          onPressed: busy ? null : onRetake,
                        ),
                      ),
                      SizedBox(width: AppSpacing.small.w),
                      Expanded(
                        child: CustomButton(
                          text: 'Crop',
                          backgroundColor: const Color(0xFF2A2A2A),
                          textColor: AppColors.white,
                          onPressed: busy ? null : onCrop,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.small.h),
                  CustomButton(
                    text: 'Use photo',
                    backgroundColor: AppColors.primaryGreen,
                    textColor: AppColors.white,
                    enabled: !busy,
                    isLoading: busy,
                    onPressed: onUse,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraStatusOverlay extends StatelessWidget {
  const _CameraStatusOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: child,
        ),
      ),
    );
  }
}

class _FrostedCircle extends StatelessWidget {
  const _FrostedCircle({
    required this.icon,
    required this.onTap,
    this.large = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 52.0 : 40.0;
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: CustomContainer(
          onTap: onTap,
          width: size,
          height: size,
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: AppRadius.circular,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppColors.white,
            size: large ? 22.sp : 20.sp,
          ),
        ),
      ),
    );
  }
}

class _AddFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const arm = 26.0;
    final r = size.width;

    void corner(double x, double y, double dx, double dy) {
      canvas.drawLine(Offset(x, y), Offset(x + dx * arm, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * arm), paint);
    }

    corner(0, 0, 1, 1);
    corner(r, 0, -1, 1);
    corner(0, r, 1, -1);
    corner(r, r, -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
