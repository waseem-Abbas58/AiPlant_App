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
import '../data/identify_flow.dart';
import '../data/plant_identify_repository.dart';
import '../model/plant_identify_result.dart';

class IdentifyProcessingView extends StatefulWidget {
  const IdentifyProcessingView({
    super.key,
    required this.imagePaths,
    this.categoryId = 'plant',
    required this.scanId,
  });

  final List<String> imagePaths;
  final String categoryId;
  final String scanId;

  String get imagePath =>
      imagePaths.isEmpty ? '' : imagePaths.first;

  @override
  State<IdentifyProcessingView> createState() => _IdentifyProcessingViewState();
}

class _IdentifyProcessingViewState extends State<IdentifyProcessingView> {
  var _step = 0;
  var _finished = false;
  var _failReason = IdentifyFailReason.none;

  static const _steps = [
    'Checking photo quality',
    'Looking for a plant',
    'Analyzing plant features',
    'Comparing possible matches',
    'Preparing result',
  ];

  bool get _failed => _failReason != IdentifyFailReason.none;

  String get _statusSubtitle {
    if (_failed) {
      return switch (_failReason) {
        IdentifyFailReason.notPlant => 'No supported plant subject detected',
        IdentifyFailReason.tooBlurry => 'Photo too blurry',
        IdentifyFailReason.tooDark => 'Not enough light',
        IdentifyFailReason.subjectTooSmall => 'Move closer to the plant',
        IdentifyFailReason.duplicateAngle => 'Try a different angle',
        IdentifyFailReason.multiplePlants =>
          'Multiple plants in frame — focus on one',
        IdentifyFailReason.offline ||
        IdentifyFailReason.timeout ||
        IdentifyFailReason.serverError =>
          'Identification service unavailable',
        IdentifyFailReason.aiUnavailable => 'Live identify not connected yet',
        _ => 'Could not continue',
      };
    }
    if (_step >= _steps.length) return 'Done';
    return _steps[_step.clamp(0, _steps.length - 1)];
  }

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
    if (widget.imagePaths.isEmpty) {
      _popFailed(IdentifyFailReason.lowQuality);
      return;
    }

    final identify = IdentifyFlow.identifySafe(
      repository: _repository,
      imagePaths: widget.imagePaths,
      categoryId: widget.categoryId,
      scanId: widget.scanId,
    );

    if (!mounted || _finished) return;
    setState(() => _step = 1);
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted || _finished) return;
    setState(() => _step = 2);

    final result = await identify;
    if (!mounted || _finished) return;

    if (!result.isIdentified) {
      setState(() => _failReason = result.failReason);
      _pop(result);
      return;
    }

    setState(() => _step = 3);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted || _finished) return;
    setState(() => _step = 4);
    _pop(result);
  }

  void _popFailed(IdentifyFailReason reason) {
    if (_finished) return;
    _finished = true;
    Navigator.of(context).pop<PlantIdentifyResult>(
      PlantIdentifyResult.failed(widget.imagePath, reason),
    );
  }

  void _pop(PlantIdentifyResult result) {
    if (_finished) return;
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
              if (widget.imagePaths.length > 1) ...[
                SizedBox(height: AppSpacing.small.h),
                CustomText(
                  '${widget.imagePaths.length} photos · scan ${widget.scanId.split('-').last}',
                  fontSize: 12,
                  color: const Color(0xFF8A8A8A),
                ),
              ],
              SizedBox(height: AppSpacing.large.h),
              const CustomText(
                'Identifying',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                letterSpacing: -0.4,
              ),
              SizedBox(height: 6.h),
              CustomText(
                _statusSubtitle,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8A8A8A),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.large.h),
              _StepColumn(
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    _StepRow(
                      label: _steps[i],
                      done: !_failed && _step > i,
                      active: !_failed && _step == i,
                      failed: _failed && i == _step.clamp(0, _steps.length - 1),
                    ),
                ],
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepColumn extends StatelessWidget {
  const _StepColumn({required this.children});

  final List<Widget> children;

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: _gap.h),
              children[i],
            ],
          ],
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
    this.failed = false,
  });

  final String label;
  final bool done;
  final bool active;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final color = failed
        ? AppColors.error
        : done || active
            ? AppColors.lightGreen
            : const Color(0xFF8A8A8A);
    return SizedBox(
      height: 28.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomContainer(
            width: 22,
            height: 22,
            color: done
                ? AppColors.lightGreen
                : failed
                    ? AppColors.error
                    : Colors.transparent,
            borderRadius: AppRadius.circular,
            border: done || failed ? null : Border.all(color: color, width: 1.5),
            alignment: Alignment.center,
            child: done
                ? Icon(
                    Icons.check_rounded,
                    size: 14.sp,
                    color: AppColors.nearBlack,
                  )
                : failed
                    ? Icon(
                        Icons.close_rounded,
                        size: 14.sp,
                        color: AppColors.white,
                      )
                    : active
                        ? SizedBox(
                            width: 10.w,
                            height: 10.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: color,
                            ),
                          )
                        : null,
          ),
          SizedBox(width: AppSpacing.small.w),
          CustomText(
            label,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }
}
