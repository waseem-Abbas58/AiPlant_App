import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../data/plant_identify_repository.dart';
import '../model/plant_identify_result.dart';

class IdentifyProcessingView extends StatefulWidget {
  const IdentifyProcessingView({
    super.key,
    required this.imagePath,
    this.categoryId = 'plant',
  });

  final String imagePath;
  final String categoryId;

  @override
  State<IdentifyProcessingView> createState() => _IdentifyProcessingViewState();
}

class _IdentifyProcessingViewState extends State<IdentifyProcessingView> {
  var _step = 0;
  var _finished = false;

  String get _detectLabel => switch (widget.categoryId) {
        'tree' => 'Looking at leaf and bark',
        'mushroom' => 'Looking at cap and stem',
        'weed' => 'Looking at the whole plant',
        'disease' => 'Looking for leaf damage',
        _ => 'Looking at the leaf',
      };

  String get _identifyLabel => switch (widget.categoryId) {
        'tree' => 'Previewing a tree',
        'mushroom' => 'Previewing a mushroom',
        'weed' => 'Previewing a weed',
        'disease' => 'Previewing plant health',
        _ => 'Previewing a houseplant',
      };

  PlantIdentifyRepository get _repository {
    if (Get.isRegistered<PlantIdentifyRepository>()) {
      return Get.find<PlantIdentifyRepository>();
    }
    return LocalPlantIdentifyRepository();
  }

  @override
  void initState() {
    super.initState();
    _run();
  }

  void _close() {
    if (_finished) return;
    _finished = true;
    NavigationHelper.back();
  }

  Future<void> _run() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted || _finished) return;
    setState(() => _step = 1);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted || _finished) return;
    setState(() => _step = 2);
    final result = await _repository.identifyFromImage(
      widget.imagePath,
      categoryId: widget.categoryId,
    );
    if (!mounted || _finished) return;
    setState(() => _step = 3);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted || _finished) return;
    _finished = true;
    Navigator.of(context).pop<PlantIdentifyResult>(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.large.w),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CustomContainer(
                  onTap: _close,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.small.h),
                  child: Icon(
                    Icons.close_rounded,
                    size: 22.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.extraLarge.r),
                child: Image.file(
                  File(widget.imagePath),
                  width: 220.w,
                  height: 220.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: AppColors.nearBlack,
                    child: SizedBox(width: 220.w, height: 220.w),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.extraLarge.h),
              const CustomText(
                'Preview match',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
              SizedBox(height: AppSpacing.extraSmall.h),
              const CustomText(
                'Live ID connects when AI is ready',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFFC8C8C8),
              ),
              SizedBox(height: AppSpacing.extraLarge.h),
              _StepRow(label: 'Reading the photo', done: _step >= 0, active: _step == 0),
              SizedBox(height: AppSpacing.medium.h),
              _StepRow(
                label: _detectLabel,
                done: _step >= 1,
                active: _step == 1,
              ),
              SizedBox(height: AppSpacing.medium.h),
              _StepRow(
                label: _identifyLabel,
                done: _step >= 2,
                active: _step == 2,
              ),
              SizedBox(height: AppSpacing.medium.h),
              _StepRow(
                label: 'Picking similar examples',
                done: _step >= 3,
                active: _step == 3,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.done,
    required this.active,
  });

  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = done || active ? AppColors.lightGreen : const Color(0xFF8A8A8A);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomContainer(
          width: 26,
          height: 26,
          color: done ? AppColors.lightGreen : Colors.transparent,
          borderRadius: AppRadius.circular,
          border: done ? null : Border.all(color: color, width: 1.6),
          alignment: Alignment.center,
          child: done
              ? Icon(Icons.check_rounded, size: 16.sp, color: AppColors.nearBlack)
              : active
                  ? SizedBox(
                      width: 12.w,
                      height: 12.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.6,
                        color: color,
                      ),
                    )
                  : null,
        ),
        SizedBox(width: AppSpacing.small.w),
        CustomText(
          label,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ],
    );
  }
}
