import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class GardenFilterChip extends StatelessWidget {
  const GardenFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.outlined = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool outlined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGreen
              : outlined
                  ? Colors.transparent
                  : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(AppRadius.circular.r),
          border: outlined && !selected
              ? Border.all(color: AppColors.primaryGreen)
              : null,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.medium.w,
          vertical: AppSpacing.small.h,
        ),
        child: CustomText(
          label,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected
              ? AppColors.white
              : outlined
                  ? AppColors.primaryGreen
                  : AppColors.primaryText,
        ),
      ),
    );
  }
}
