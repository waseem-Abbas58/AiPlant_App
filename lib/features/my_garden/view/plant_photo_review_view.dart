import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../core/helpers/plant_image_store.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text.dart';
import '../widgets/plant_crop_sheet.dart';

class PlantPhotoReviewView extends StatefulWidget {
  const PlantPhotoReviewView({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<PlantPhotoReviewView> createState() => _PlantPhotoReviewViewState();
}

class _PlantPhotoReviewViewState extends State<PlantPhotoReviewView> {
  late String _path;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _path = widget.imagePath;
  }

  Future<void> _crop() async {
    if (_busy) return;
    final cropped = await showPlantCropSheet(context, _path);
    if (!mounted || cropped == null || cropped.isEmpty) return;
    setState(() => _path = cropped);
  }

  Future<void> _use() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final path = await PlantImageStore.persistCopy(_path);
      if (!mounted) return;
      NavigationHelper.back(path);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
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
            Image.file(
              File(_path),
              fit: BoxFit.cover,
              key: ValueKey(_path),
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFF111111)),
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
                            onPressed: _busy
                                ? null
                                : () => NavigationHelper.back(),
                          ),
                        ),
                        SizedBox(width: AppSpacing.small.w),
                        Expanded(
                          child: CustomButton(
                            text: 'Crop',
                            backgroundColor: const Color(0xFF2A2A2A),
                            textColor: AppColors.white,
                            onPressed: _busy ? null : _crop,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.small.h),
                    CustomButton(
                      text: 'Use photo',
                      backgroundColor: AppColors.primaryGreen,
                      textColor: AppColors.white,
                      enabled: !_busy,
                      isLoading: _busy,
                      onPressed: _use,
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
