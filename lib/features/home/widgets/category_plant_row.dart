import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_text.dart';
import '../model/browse_category.dart';

class CategoryPlantRow extends StatelessWidget {
  const CategoryPlantRow({
    super.key,
    required this.plant,
    this.onTap,
    this.onAdd,
  });

  final CategoryPlant plant;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium.w,
        vertical: 10.h,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium.r),
            child: Image.asset(
              plant.imagePath,
              width: 52.w,
              height: 52.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: AppSpacing.medium.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  plant.name,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  plant.scientificName,
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.small.w),
          GestureDetector(
            onTap: onAdd,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 36.r,
              height: 36.r,
              child: Icon(
                Icons.add_rounded,
                size: 26.sp,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
