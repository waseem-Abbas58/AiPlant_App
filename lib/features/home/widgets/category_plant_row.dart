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
    required this.categoryId,
    this.inGarden = false,
    this.onTap,
    this.onAdd,
  });

  final CategoryPlant plant;
  final String categoryId;
  final bool inGarden;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final detail = plant.toDetail(categoryId);

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
                width: 68.w,
                height: 68.w, 
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
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      _EasyChip(label: detail.difficultyChip),
                      SizedBox(width: 8.w),
                      _CareIcon(
                        icon: Icons.wb_sunny_outlined,
                        color: const Color(0xFFF9A825),
                        label: detail.lightChip, 
                      ),
                      SizedBox(width: 8.w), 
                      _CareIcon(
                        icon: Icons.opacity_outlined,
                        color: const Color(0xFF1E88E5), 
                        label: detail.waterChip,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.small.w),
            GestureDetector(
              onTap: onAdd,
              behavior: HitTestBehavior.opaque,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGreen,
                      width: 1.5,
                    ),
                  ), 
                  child: Icon(
                    inGarden ? Icons.check_rounded : Icons.add_rounded,
                    size: 18.sp,
                    color: AppColors.primaryGreen,  
                  ), 
                ),  
              ),  
            ),  
          ], 
        ),
      ),
    );
  }
}

class _EasyChip extends StatelessWidget {
  const _EasyChip({required this.label});

  final String label;

  Color get _color {
    switch (label) {
      case 'Medium':
        return const Color(0xFF6A1B9A);
      case 'High':
        return AppColors.warning;
      default:
        return AppColors.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return SizedBox(
      width: 72.w,
      height: 24.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: CustomText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _CareIcon extends StatelessWidget {
  const _CareIcon({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Icon(icon, size: 16.sp, color: color),
    );
  }
}
