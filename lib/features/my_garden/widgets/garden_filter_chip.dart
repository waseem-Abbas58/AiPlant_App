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
    this.expand = false,
    this.borderRadius,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool outlined;
  final bool expand;
  final double? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.circular;
    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: expand ? double.infinity : null,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primaryGreen
            : outlined
                ? Colors.transparent
                : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(radius.r),
        border: outlined && !selected
            ? Border.all(color: AppColors.primaryGreen)
            : null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: expand ? AppSpacing.extraSmall.w : AppSpacing.medium.w,
        vertical: AppSpacing.small.h,
      ),
      child: CustomText(
        label,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        color: selected
            ? AppColors.white
            : outlined
                ? AppColors.primaryGreen
                : AppColors.primaryText,
      ),
    );

    final child = CustomContainer(
      onTap: onTap,
      child: chip,
    );
    if (!expand) return child;
    return SizedBox(width: double.infinity, child: child);
  }
}
