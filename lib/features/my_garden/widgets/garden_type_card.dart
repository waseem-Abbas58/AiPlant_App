import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class GardenTypeCard extends StatelessWidget {
  const GardenTypeCard({
    super.key,
    required this.imagePath,
    required this.title,
    this.selected = false,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  static const double cardWidth = 124;
  static const double cardHeight = 152;
  static double get extent => cardHeight.h;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth.w,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CustomContainer(
                  width: cardWidth,
                  height: 104,
                  color: AppColors.white,
                  borderRadius: AppRadius.large,
                  clipBehavior: Clip.antiAlias,
                  padding: EdgeInsets.zero,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                if (selected)
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: CircleAvatar(
                      radius: 11.r,
                      backgroundColor: AppColors.primaryGreen,
                      child: Icon(
                        Icons.check_rounded,
                        size: 14.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.extraSmall.h),
            CustomText(
              title,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
