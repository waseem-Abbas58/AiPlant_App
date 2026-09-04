import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class DiagnoseSymptom {
  const DiagnoseSymptom({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;

  static const all = [
    DiagnoseSymptom(
      id: 'yellow_leaves',
      label: 'Yellow leaves',
      icon: Icons.wb_sunny_outlined,
    ),
    DiagnoseSymptom(
      id: 'brown_spots',
      label: 'Brown spots',
      icon: Icons.grain_rounded,
    ),
    DiagnoseSymptom(
      id: 'drooping',
      label: 'Drooping',
      icon: Icons.water_drop_outlined,
    ),
    DiagnoseSymptom(
      id: 'holes',
      label: 'Holes / bites',
      icon: Icons.bug_report_outlined,
    ),
    DiagnoseSymptom(
      id: 'white_coating',
      label: 'White coating',
      icon: Icons.blur_on_rounded,
    ),
    DiagnoseSymptom(
      id: 'pests',
      label: 'Pests',
      icon: Icons.pest_control_outlined,
    ),
    DiagnoseSymptom(
      id: 'other',
      label: 'Other / Not sure',
      icon: Icons.help_outline_rounded,
    ),
  ];

  static String labelFor(String id) {
    return all
        .firstWhere(
          (item) => item.id == id,
          orElse: () => const DiagnoseSymptom(
            id: 'other',
            label: 'Health check',
            icon: Icons.help_outline_rounded,
          ),
        )
        .label;
  }
}

class DiagnoseSymptomView extends StatelessWidget {
  const DiagnoseSymptomView({super.key, required this.plantName});

  final String plantName;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

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
                        'What are you noticing?',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                      if (plantName.trim().isNotEmpty)
                        CustomText(
                          plantName.trim(),
                          fontSize: 13,
                          color: AppColors.secondaryText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium.w),
            child: const CustomText(
              'Pick the closest sign. Next you will take new health photos — not your identify photo.',
              fontSize: 13,
              color: AppColors.secondaryText,
              height: 1.35,
            ),
          ),
          SizedBox(height: AppSpacing.medium.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.medium.w,
                0,
                AppSpacing.medium.w,
                AppSpacing.medium.h + bottom,
              ),
              children: [
                for (final symptom in DiagnoseSymptom.all) ...[
                  _SymptomTile(
                    symptom: symptom,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop<String>(symptom.id);
                    },
                  ),
                  SizedBox(height: AppSpacing.small.h),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomTile extends StatelessWidget {
  const _SymptomTile({required this.symptom, required this.onTap});

  final DiagnoseSymptom symptom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        children: [
          CustomContainer(
            width: 44,
            height: 44,
            color: AppColors.sageBackground,
            borderRadius: AppRadius.medium,
            alignment: Alignment.center,
            child: Icon(
              symptom.icon,
              color: AppColors.primaryGreen,
              size: 22.sp,
            ),
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: CustomText(
              symptom.label,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mutedText,
            size: 22.sp,
          ),
        ],
      ),
    );
  }
}
