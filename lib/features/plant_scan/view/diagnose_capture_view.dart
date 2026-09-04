import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../core/helpers/plant_image_store.dart';
import 'diagnose_symptom_view.dart';

class DiagnoseCaptureView extends StatefulWidget {
  const DiagnoseCaptureView({
    super.key,
    required this.plantName,
    required this.symptomId,
  });

  final String plantName;
  final String symptomId;

  @override
  State<DiagnoseCaptureView> createState() => _DiagnoseCaptureViewState();
}

class _DiagnoseCaptureViewState extends State<DiagnoseCaptureView> {
  List<_CaptureStep> get _steps {
    return switch (widget.symptomId) {
      'brown_spots' => const [
          _CaptureStep(
            title: 'Whole plant',
            hint: 'Step back so the full plant and spotted leaves are visible.',
            required: true,
          ),
          _CaptureStep(
            title: 'Close-up of spotted leaf',
            hint: 'Fill the frame with one brown or spotted leaf.',
            required: true,
          ),
          _CaptureStep(
            title: 'Leaf underside',
            hint: 'Optional — check the back of the leaf for more spots.',
            required: false,
          ),
        ],
      'yellow_leaves' => const [
          _CaptureStep(
            title: 'Whole plant',
            hint: 'Step back so yellowing and the full plant are visible.',
            required: true,
          ),
          _CaptureStep(
            title: 'Close-up of yellow leaf',
            hint: 'Fill the frame with one yellowing leaf.',
            required: true,
          ),
          _CaptureStep(
            title: 'Stem or soil',
            hint: 'Optional — stem base or soil surface can help.',
            required: false,
          ),
        ],
      'pests' => const [
          _CaptureStep(
            title: 'Affected area',
            hint: 'Show the leaves or stems where you see pests.',
            required: true,
          ),
          _CaptureStep(
            title: 'Pest close-up',
            hint: 'Get as close as you can to the insect or damage.',
            required: true,
          ),
          _CaptureStep(
            title: 'Leaf underside',
            hint: 'Optional — pests often hide under leaves.',
            required: false,
          ),
        ],
      'drooping' => const [
          _CaptureStep(
            title: 'Whole plant',
            hint: 'Step back so the drooping shape is clear.',
            required: true,
          ),
          _CaptureStep(
            title: 'Stem / base',
            hint: 'Photograph the stem and where it meets the soil.',
            required: true,
          ),
          _CaptureStep(
            title: 'Soil surface',
            hint: 'Optional — wet, dry, or moldy soil can help.',
            required: false,
          ),
        ],
      'holes' => const [
          _CaptureStep(
            title: 'Whole plant',
            hint: 'Show how widespread the holes or bites are.',
            required: true,
          ),
          _CaptureStep(
            title: 'Close-up of damaged leaf',
            hint: 'Fill the frame with one chewed or holed leaf.',
            required: true,
          ),
          _CaptureStep(
            title: 'Leaf underside',
            hint: 'Optional — look for insects under the leaf.',
            required: false,
          ),
        ],
      'white_coating' => const [
          _CaptureStep(
            title: 'Whole plant',
            hint: 'Step back so the white coating is easy to see.',
            required: true,
          ),
          _CaptureStep(
            title: 'Close-up of coating',
            hint: 'Fill the frame with the powdery or white area.',
            required: true,
          ),
          _CaptureStep(
            title: 'Leaf underside',
            hint: 'Optional — coating often starts under leaves.',
            required: false,
          ),
        ],
      _ => const [
          _CaptureStep(
            title: 'Whole plant',
            hint: 'Step back so the full plant is visible.',
            required: true,
          ),
          _CaptureStep(
            title: 'Affected area',
            hint: 'Move close to the damaged leaf or spot.',
            required: true,
          ),
          _CaptureStep(
            title: 'Leaf underside',
            hint: 'Optional — helps with pests and mildew.',
            required: false,
          ),
        ],
    };
  }

  final _paths = <String>[];
  final _picker = ImagePicker();

  String get _symptomLabel => DiagnoseSymptom.labelFor(widget.symptomId);

  bool get _canAnalyze {
    final requiredSteps = _steps.where((step) => step.required).length;
    return _paths.length >= requiredSteps;
  }

  Future<void> _addPhoto(ImageSource source) async {
    if (_paths.length >= _steps.length) return;
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (file == null) return;
    final stored = await PlantImageStore.persistCopy(file.path);
    if (!mounted) return;
    setState(() => _paths.add(stored));
  }

  void _removeAt(int index) {
    setState(() => _paths.removeAt(index));
  }

  void _analyze() {
    if (!_canAnalyze) return;
    Navigator.of(context).pop<List<String>>(List.of(_paths));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final nextStep = _paths.length < _steps.length ? _steps[_paths.length] : null;

    return Scaffold(
      backgroundColor: AppColors.sageBackground,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.medium.w,
              top + AppSpacing.small.h,
              AppSpacing.medium.w,
              AppSpacing.small.h,
            ),
            child: Row(
              children: [
                CustomContainer(
                  onTap: NavigationHelper.back,
                  width: 36,
                  height: 36,
                  color: AppColors.white,
                  borderRadius: AppRadius.circular,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16.sp,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(width: AppSpacing.small.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomText(
                        'Health photos',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                      CustomText(
                        '$_symptomLabel · ${_paths.length} of ${_steps.length}',
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.medium.w,
                0,
                AppSpacing.medium.w,
                AppSpacing.medium.h,
              ),
              children: [
                if (nextStep != null) ...[
                  CustomContainer(
                    color: AppColors.white,
                    borderRadius: AppRadius.large,
                    shadow: AppShadows.soft,
                    padding: EdgeInsets.all(AppSpacing.medium.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          nextStep.required ? 'Next photo' : 'Optional photo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedText,
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          nextStep.title,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          nextStep.hint,
                          fontSize: 13,
                          color: AppColors.secondaryText,
                          height: 1.35,
                        ),
                        SizedBox(height: AppSpacing.medium.h),
                        Row(
                          children: [
                            Expanded(
                              child: CustomContainer(
                                onTap: () => _addPhoto(ImageSource.camera),
                                color: AppColors.primaryGreen,
                                borderRadius: AppRadius.large,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: const CustomText(
                                  'Take photo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.small.w),
                            Expanded(
                              child: CustomContainer(
                                onTap: () => _addPhoto(ImageSource.gallery),
                                borderRadius: AppRadius.large,
                                border: Border.all(color: AppColors.primaryGreen),
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: const CustomText(
                                  'Gallery',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                ],
                const CustomText(
                  'Added photos',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedText,
                ),
                SizedBox(height: AppSpacing.small.h),
                for (var i = 0; i < _paths.length; i++) ...[
                  _PhotoRow(
                    label: _steps[i].title,
                    path: _paths[i],
                    onRemove: () => _removeAt(i),
                  ),
                  SizedBox(height: AppSpacing.small.h),
                ],
                if (_paths.isEmpty)
                  CustomContainer(
                    color: AppColors.white,
                    borderRadius: AppRadius.large,
                    shadow: AppShadows.soft,
                    padding: EdgeInsets.all(AppSpacing.medium.w),
                    child: const CustomText(
                      'Use new photos of the problem area. Your identify photo is not reused.',
                      fontSize: 13,
                      color: AppColors.secondaryText,
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
          CustomContainer(
            color: AppColors.white,
            shadow: AppShadows.soft,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.medium.w,
              AppSpacing.small.h,
              AppSpacing.medium.w,
              AppSpacing.small.h + bottom,
            ),
            child: CustomButton(
              text: _paths.isEmpty
                  ? 'Add at least 2 photos'
                  : 'Analyze ${_paths.length} photo${_paths.length == 1 ? '' : 's'}',
              backgroundColor: AppColors.primaryGreen,
              textColor: AppColors.white,
              borderRadius: AppRadius.large,
              enabled: _canAnalyze,
              onPressed: _analyze,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureStep {
  const _CaptureStep({
    required this.title,
    required this.hint,
    required this.required,
  });

  final String title;
  final String hint;
  final bool required;
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({
    required this.label,
    required this.path,
    required this.onRemove,
  });

  final String label;
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.small.w),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium.r),
            child: Image.file(
              File(path),
              width: 56.w,
              height: 56.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: CustomText(
              label,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          CustomContainer(
            onTap: onRemove,
            padding: EdgeInsets.all(6.r),
            child: Icon(
              Icons.close_rounded,
              size: 18.sp,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
