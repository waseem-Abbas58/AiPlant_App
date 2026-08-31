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
import '../data/plant_scene_gate.dart';
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
  var _rejected = false;

  String get _detectLabel => switch (widget.categoryId) {
        'tree' => 'Looking at leaf and bark',
        'mushroom' => 'Looking at cap and stem',
        'weed' => 'Looking at the whole plant',
        'disease' => 'Looking for leaf damage',
        _ => 'Looking at the leaf',
      };

  String get _findLabel {
    if (_rejected) return 'No plant in this photo';
    return 'Looking for a plant';
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
    await Future<void>.delayed(const Duration(milliseconds: 380));
    if (!mounted || _finished) return;
    setState(() => _step = 1);
    final plantLike = await PlantSceneGate.looksLikePlant(
      widget.imagePath,
      categoryId: widget.categoryId,
    );
    if (!mounted || _finished) return;
    if (!plantLike) {
      setState(() => _rejected = true);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted || _finished) return;
      _finished = true;
      Navigator.of(context).pop<PlantIdentifyResult>(
        PlantIdentifyResult.notAPlant(widget.imagePath),
      );
      return;
    }
    final result = await _repository.identifyFromImage(
      widget.imagePath,
      categoryId: widget.categoryId,
    );
    if (!mounted || _finished) return;
    if (!result.isIdentified) {
      setState(() => _rejected = true);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted || _finished) return;
      _finished = true;
      Navigator.of(context).pop<PlantIdentifyResult>(result);
      return;
    }
    setState(() => _step = 2);
    await Future<void>.delayed(const Duration(milliseconds: 320));
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
              SizedBox(height: AppSpacing.large.h),
              const CustomText(
                'Identifying',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                letterSpacing: -0.4,
              ),
              SizedBox(height: 6.h),
              const CustomText(
                'Live ID when AI is connected',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8A8A8A),
              ),
              SizedBox(height: AppSpacing.large.h),
              _StepColumn(
                children: [
                  _StepRow(
                    label: 'Reading the photo',
                    done: _step >= 1,
                    active: _step == 0,
                  ),
                  _StepRow(
                    label: _findLabel,
                    done: !_rejected && _step >= 2,
                    active: !_rejected && _step == 1,
                    failed: _rejected,
                  ),
                  _StepRow(
                    label: _detectLabel,
                    done: !_rejected && _step >= 3,
                    active: !_rejected && _step == 2,
                  ),
                  _StepRow(
                    label: 'Picking similar examples',
                    done: !_rejected && _step >= 3,
                    active: !_rejected && _step == 3,
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
