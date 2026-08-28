import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../model/plant_identify_result.dart';

class ToxicitySheet extends StatelessWidget {
  const ToxicitySheet({
    super.key,
    required this.toxicity,
    this.plantName,
  });

  final PlantToxicity toxicity;
  final String? plantName;

  static Future<void> show(
    BuildContext context, {
    required PlantToxicity toxicity,
    String? plantName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.extraLarge.r),
        ),
      ),
      builder: (_) => ToxicitySheet(
        toxicity: toxicity,
        plantName: plantName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.large.w,
        AppSpacing.small.h,
        AppSpacing.large.w,
        AppSpacing.large.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CustomContainer(
              width: 36,
              height: 4,
              color: AppColors.divider,
              borderRadius: AppRadius.circular,
              alignment: Alignment.center,
            ),
          ),
          SizedBox(height: AppSpacing.medium.h),
          CustomText(
            plantName ?? 'Toxicity',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          SizedBox(height: AppSpacing.small.h),
          CustomText(
            toxicity.summary,
            fontSize: 14,
            color: AppColors.secondaryText,
            height: 1.4,
          ),
          if (toxicity.petsDetail.isNotEmpty) ...[
            SizedBox(height: AppSpacing.medium.h),
            const CustomText(
              'Pets',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
            SizedBox(height: 4.h),
            CustomText(
              toxicity.petsDetail,
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ],
          if (toxicity.kidsDetail.isNotEmpty) ...[
            SizedBox(height: AppSpacing.medium.h),
            const CustomText(
              'Kids',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
            SizedBox(height: 4.h),
            CustomText(
              toxicity.kidsDetail,
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ],
        ],
      ),
    );
  }
}
