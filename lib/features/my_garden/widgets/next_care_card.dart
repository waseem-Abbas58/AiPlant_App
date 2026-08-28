import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import 'garden_plant_image.dart';

class NextCareCard extends StatelessWidget {
  const NextCareCard({
    super.key,
    required this.imagePath,
    required this.isAssetImage,
    required this.title,
    required this.subtitle,
    required this.onWatered,
    required this.onSnooze,
    this.onTap,
    this.embedded = false,
  });

  final String imagePath;
  final bool isAssetImage;
  final String title;
  final String subtitle;
  final VoidCallback onWatered;
  final VoidCallback onSnooze;
  final VoidCallback? onTap;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        GardenPlantImage(
          path: imagePath,
          isAsset: isAssetImage,
          width: 56.w,
          height: 56.w,
          borderRadius: BorderRadius.circular(AppRadius.medium.r),
        ),
        SizedBox(width: AppSpacing.small.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                title,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              CustomText(
                subtitle,
                fontSize: 12,
                color: AppColors.secondaryText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        CustomContainer(
          onTap: onSnooze,
          padding: EdgeInsets.all(8.r),
          child: Icon(
            Icons.snooze_rounded,
            size: 20.sp,
            color: AppColors.secondaryText,
          ),
        ),
        CustomContainer(
          onTap: onWatered,
          color: AppColors.primaryGreen,
          borderRadius: AppRadius.circular,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: const CustomText(
            'I watered',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ],
    );

    if (embedded) {
      return CustomContainer(onTap: onTap, child: row);
    }

    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.small.w + 2.w),
      child: row,
    );
  }
}
