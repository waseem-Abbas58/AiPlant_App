import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class ProfileSettingRow extends StatelessWidget {
  const ProfileSettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.destructive = false,
    this.showChevron = true,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool destructive;
  final bool showChevron;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AppColors.error : AppColors.primaryGreen;
    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      border: Border.all(color: AppColors.border),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium.w,
        vertical: 10.h,
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: destructive
                  ? AppColors.error.withValues(alpha: 0.10)
                  : const Color(0xFFE8F0E6),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18.sp, color: accent),
          ),
          SizedBox(width: AppSpacing.small.w + 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: destructive ? AppColors.error : AppColors.primaryText,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  subtitle,
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (showChevron)
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: destructive ? AppColors.error : AppColors.mutedText,
            ),
        ],
      ),
    );
  }
}
