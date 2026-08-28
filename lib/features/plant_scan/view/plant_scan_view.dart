import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/app_camera.dart';
import '../../../shared/camera/premium_camera_widgets.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/plant_scan_controller.dart';
import '../model/plant_scan_model.dart';

class PlantScanView extends GetView<PlantScanController> {
  const PlantScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: Stack(
          fit: StackFit.expand,
          children: [
            GetBuilder<PlantScanController>(
              id: 'camera',
              builder: (scan) {
                if (scan.isCameraReady.value &&
                    scan.camera != null &&
                    scan.camera!.value.isInitialized) {
                  return CameraPreviewGestures(
                    camera: scan.camera!,
                    session: scan.session,
                    onChanged: () => scan.update(['chrome']),
                    child: CoverCameraPreview(controller: scan.camera!),
                  );
                }
                return const ColoredBox(color: Color(0xFF111111));
              },
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x66000000),
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0x00000000),
                      ],
                      stops: [0, 0.14, 0.45, 1],
                    ),
                  ),
                ),
              ),
            ),
            GetBuilder<PlantScanController>(
              id: 'chrome',
              builder: (scan) =>
                  CameraShutterFlash(visible: scan.session.shutterBurst),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
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
                              _RoundIcon(
                                icon: Icons.close_rounded,
                                onTap: controller.closeScan,
                              ),
                              const Spacer(),
                              GetBuilder<PlantScanController>(
                                id: 'chrome',
                                builder: (scan) {
                                  if (scan.camera == null ||
                                      !scan.isCameraReady.value) {
                                    return const SizedBox.shrink();
                                  }
                                  return CameraFlashButton(
                                    mode: scan.session.light,
                                    onTap: () async {
                                      await scan.session
                                          .cycleLight(scan.camera!);
                                      scan.update(['chrome']);
                                    },
                                  );
                                },
                              ),
                              SizedBox(width: AppSpacing.small.w),
                              _RoundIcon(
                                icon: Icons.cameraswitch_outlined,
                                onTap: controller.flipCamera,
                              ),
                            ],
                          ),
                          Expanded(
                            child: GetBuilder<PlantScanController>(
                              id: 'chrome',
                              builder: (scan) {
                                return Obx(() {
                                  controller.toxicityFocus.value;
                                  final identify =
                                      controller.isIdentifyMode.value;
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Positioned.fill(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onScaleStart: (_) =>
                                              scan.session.beginPinch(),
                                          onScaleUpdate: (details) async {
                                            final cam = scan.camera;
                                            if (cam == null) return;
                                            if (details.pointerCount >= 2) {
                                              await scan.session.updatePinch(
                                                cam,
                                                details.scale,
                                              );
                                            } else {
                                              await scan.session.nudgeZoom(
                                                cam,
                                                details.focalPointDelta.dy,
                                              );
                                            }
                                            scan.update(['chrome']);
                                          },
                                          child: const SizedBox.expand(),
                                        ),
                                      ),
                                      _ScanGuide(identify: identify),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.small.h,
                                            right: 4.w,
                                          ),
                                          child: CameraZoomRail(
                                            zoom: scan.session.zoom,
                                            min: scan.session.minZoom,
                                            max: scan.session.maxZoom,
                                            onChanged: (value) async {
                                              final cam = scan.camera;
                                              if (cam == null) return;
                                              await scan.session
                                                  .setZoom(cam, value);
                                              scan.update(['chrome']);
                                            },
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            bottom: AppSpacing.small.h,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (!identify)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: AppSpacing.small.h,
                                                  ),
                                                  child: _MultipleSlots(
                                                    paths: controller
                                                        .capturedPaths
                                                        .toList(),
                                                    onRemove: controller
                                                        .removeCapturedAt,
                                                  ),
                                                ),
                                              CustomContainer(
                                                color: Colors.black
                                                    .withValues(alpha: 0.42),
                                                borderRadius:
                                                    AppRadius.circular,
                                                padding: EdgeInsets.all(4.r),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    _ModePill(
                                                      label: 'Identify',
                                                      selected: identify,
                                                      onTap: () => controller
                                                          .setIdentifyMode(
                                                        true,
                                                      ),
                                                    ),
                                                    _ModePill(
                                                      label: 'Multiple',
                                                      selected: !identify,
                                                      onTap: () => controller
                                                          .setIdentifyMode(
                                                        false,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ColoredBox(
                    color: const Color(0xFF111111),
                    child: CameraControlDock(
                      frosted: false,
                      extraBottom: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Obx(() {
                          final selected = controller.selectedCategory.value;
                          return SizedBox(
                            height: 36.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: ScanCategory.all.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(width: 22.w),
                              itemBuilder: (context, i) {
                                return _ScanCategoryChip(
                                  item: ScanCategory.all[i],
                                  active: i == selected,
                                  onTap: () => controller.selectCategory(i),
                                );
                              },
                            ),
                          );
                        }),
                        Obx(() {
                          if (controller.isIdentifyMode.value ||
                              controller.capturedPaths.isEmpty) {
                            return SizedBox(height: AppSpacing.medium.h);
                          }
                          return Padding(
                            padding: EdgeInsets.only(
                              top: AppSpacing.small.h,
                              bottom: AppSpacing.medium.h,
                            ),
                            child: CustomContainer(
                              onTap: controller.identifyCaptured,
                              color: AppColors.primaryGreen,
                              borderRadius: AppRadius.circular,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 10.h,
                              ),
                              child: CustomText(
                                'Identify ${controller.capturedPaths.length} photos',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          );
                        }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(
                              () => _ThumbButton(
                                path: controller.lastThumbPath.value,
                                onTap: controller.openGallery,
                              ),
                            ),
                            CameraShutterButton(
                              enabled: true,
                              onPressed: controller.capture,
                            ),
                            _RoundIcon(
                              icon: Icons.info_outline_rounded,
                              onTap: controller.openTips,
                              large: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
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
    return CustomContainer(
      onTap: onTap,
      width: size,
      height: size,
      color: Colors.black.withValues(alpha: 0.38),
      borderRadius: AppRadius.circular,
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.white, size: large ? 22.sp : 20.sp),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: selected ? AppColors.white : Colors.transparent,
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
      child: CustomText(
        label,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: selected ? AppColors.primaryText : AppColors.white,
      ),
    );
  }
}

class _ThumbButton extends StatelessWidget {
  const _ThumbButton({required this.path, required this.onTap});

  final String? path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      width: 52,
      height: 52,
      color: Colors.black.withValues(alpha: 0.38),
      borderRadius: AppRadius.circular,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      child: path == null
          ? ClipOval(
              child: Image.asset(
                'assets/images/home/trending/trending_peace_lily.png',
                width: 52.w,
                height: 52.w,
                fit: BoxFit.cover,
              ),
            )
          : Image.file(
              File(path!),
              width: 52.w,
              height: 52.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.photo_outlined,
                color: AppColors.white,
                size: 22.sp,
              ),
            ),
    );
  }
}

class _ScanGuide extends StatelessWidget {
  const _ScanGuide({required this.identify});

  final bool identify;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = (identify ? 0.72 : 0.58) *
            constraints.maxWidth.clamp(1, constraints.maxWidth);
        return IgnorePointer(
          child: Center(
            child: SizedBox(
              width: side,
              height: side,
              child: CustomPaint(painter: _FramePainter()),
            ),
          ),
        );
      },
    );
  }
}

class _ScanCategoryChip extends StatelessWidget {
  const _ScanCategoryChip({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final ScanCategory item;
  final bool active;
  final VoidCallback onTap;

  static const _gold = Color(0xFFFFD54F);

  @override
  Widget build(BuildContext context) {
    final color = active ? _gold : AppColors.white;
    return CustomContainer(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco_rounded, color: color, size: 16.sp),
          SizedBox(width: 6.w),
          CustomText(
            item.label,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _MultipleSlots extends StatelessWidget {
  const _MultipleSlots({
    required this.paths,
    required this.onRemove,
  });

  final List<String> paths;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final count = paths.length > 3
        ? PlantScanController.maxMultipleShots
        : PlantScanController.visibleMultipleSlots;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.small.w),
          _Slot(
            path: i < paths.length ? paths[i] : null,
            index: i,
            onRemove: i < paths.length ? onRemove : null,
          ),
        ],
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    this.path,
    required this.index,
    this.onRemove,
  });

  final String? path;
  final int index;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: path == null ? null : () => onRemove?.call(index),
      width: 56,
      height: 56,
      borderRadius: AppRadius.medium,
      color: Colors.white.withValues(alpha: 0.1),
      border: Border.all(
        color: AppColors.white.withValues(alpha: path == null ? 0.45 : 0.9),
        width: path == null ? 1.2 : 1.6,
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      child: path == null
          ? Icon(
              Icons.add_rounded,
              color: AppColors.white.withValues(alpha: 0.7),
              size: 22.sp,
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(path!), fit: BoxFit.cover),
                const Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;
    final arm = w * 0.22;
    const r = 18.0;

    void corner(Offset o, {required bool right, required bool bottom}) {
      final hx = right ? -1.0 : 1.0;
      final vy = bottom ? -1.0 : 1.0;
      final path = Path()
        ..moveTo(o.dx + hx * arm, o.dy)
        ..lineTo(o.dx + hx * r, o.dy)
        ..arcToPoint(
          Offset(o.dx, o.dy + vy * r),
          radius: const Radius.circular(r),
          clockwise: right ^ bottom,
        )
        ..lineTo(o.dx, o.dy + vy * arm);
      canvas.drawPath(path, paint);
    }

    corner(Offset.zero, right: false, bottom: false);
    corner(Offset(w, 0), right: true, bottom: false);
    corner(Offset(0, h), right: false, bottom: true);
    corner(Offset(w, h), right: true, bottom: true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
