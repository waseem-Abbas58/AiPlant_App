import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/plant_image_store.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

Future<String?> showPlantCropSheet(BuildContext context, String imagePath) async {
  final result = Get.to<String>(
    () => PlantCropView(imagePath: imagePath),
    fullscreenDialog: true,
    transition: Transition.fadeIn,
  );
  if (result == null) return null;
  return result;
}

class PlantCropView extends StatefulWidget {
  const PlantCropView({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<PlantCropView> createState() => _PlantCropViewState();
}

class _PlantCropViewState extends State<PlantCropView> {
  final _cropKey = GlobalKey();
  final _transform = TransformationController();
  var _saving = false;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _reset() {
    _transform.value = Matrix4.identity();
  }

  Future<void> _save() async {
    if (_saving) return;
    final boundary =
        _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    setState(() => _saving = true);
    try {
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) {
        if (mounted) setState(() => _saving = false);
        return;
      }
      final temp = File(
        '${Directory.systemTemp.path}/plant_crop_raw_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await temp.writeAsBytes(bytes.buffer.asUint8List());
      final path = await PlantImageStore.persistCopy(
        temp.path,
        extension: 'png',
      );
      await temp.delete();
      if (!mounted) return;
      Navigator.of(context).pop(path);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cropSize = size.width - (AppSpacing.large.w * 2);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.large.w,
              AppSpacing.small.h,
              AppSpacing.large.w,
              AppSpacing.large.h,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomContainer(
                      onTap: _saving ? null : () => Navigator.of(context).pop(),
                      padding: EdgeInsets.all(AppSpacing.small.w),
                      child: Icon(
                        Icons.close_rounded,
                        size: 22.sp,
                        color: AppColors.white,
                      ),
                    ),
                    const Expanded(
                      child: CustomText(
                        'Crop photo',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    CustomContainer(
                      onTap: _saving ? null : _reset,
                      padding: EdgeInsets.all(AppSpacing.small.w),
                      child: Icon(
                        Icons.refresh_rounded,
                        size: 22.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.small.h),
                const CustomText(
                  'Pinch to zoom, drag to frame your plant',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xB3FFFFFF),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: cropSize,
                  height: cropSize,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.large.r),
                        child: ColoredBox(
                          color: AppColors.nearBlack,
                          child: RepaintBoundary(
                            key: _cropKey,
                            child: ClipRect(
                              child: InteractiveViewer(
                                transformationController: _transform,
                                minScale: 1,
                                maxScale: 4,
                                child: SizedBox(
                                  width: cropSize,
                                  height: cropSize,
                                  child: Image.file(
                                    File(widget.imagePath),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    errorBuilder: (_, __, ___) => ColoredBox(
                                      color: AppColors.nearBlack,
                                      child: SizedBox(
                                        width: cropSize,
                                        height: cropSize,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: CustomPaint(painter: _CropGridPainter()),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        backgroundColor: const Color(0xFF2A2A2A),
                        textColor: AppColors.white,
                        onPressed:
                            _saving ? null : () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(width: AppSpacing.small.w),
                    Expanded(
                      child: CustomButton(
                        text: 'Done',
                        backgroundColor: AppColors.primaryGreen,
                        textColor: AppColors.white,
                        enabled: !_saving,
                        isLoading: _saving,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CropGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..strokeWidth = 1;
    final border = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Offset.zero & size, border);
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      line,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      line,
    );
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      line,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
