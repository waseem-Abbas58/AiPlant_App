import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import 'garden_plant_image.dart';

class GardenPlantRow extends StatelessWidget {
  const GardenPlantRow({
    super.key,
    required this.imagePath,
    required this.isAssetImage,
    required this.name,
    required this.subtitle,
    this.onTap,
    this.onMore,
  });

  final String imagePath;
  final bool isAssetImage;
  final String name;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      padding: EdgeInsets.all(AppSpacing.small.w + 2.w),
      child: Row(
        children: [
          GardenPlantImage(
            path: imagePath,
            isAsset: isAssetImage,
            width: 56.w,
            height: 56.w,
            borderRadius: BorderRadius.circular(AppRadius.medium.r),
          ),
          SizedBox(width: AppSpacing.small.w + 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  name,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  subtitle,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          CustomContainer(
            onTap: onMore,
            padding: EdgeInsets.all(AppSpacing.extraSmall.w),
            child: Icon(
              Icons.more_horiz_rounded,
              size: 22.sp,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
