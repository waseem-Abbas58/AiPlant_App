import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class GardenSoilOption extends StatelessWidget {
  const GardenSoilOption({
    super.key,
    required this.imagePath,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String imagePath;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = 72.r;

    return CustomContainer(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Image.asset(
                  imagePath,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              ),
              if (selected)
                Positioned(
                  right: -2.w,
                  top: -2.h,
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
            label,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
        ],
      ),
    );
  }
}
