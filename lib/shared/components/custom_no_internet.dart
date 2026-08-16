import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';

class CustomNoInternet extends StatelessWidget {
  const CustomNoInternet({
    super.key,
    this.icon,
    this.title,
    this.description,
    this.retryText,
    this.onRetry,
    this.iconColor,
    this.iconSize,
  });

  final IconData? icon;
  final String? title;
  final String? description;
  final String? retryText;
  final VoidCallback? onRetry;
  final Color? iconColor;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted =
        isDark ? AppColors.darkTextSecondary : AppColors.mutedText;

    return Padding(
      padding: EdgeInsets.all(AppSpacing.large.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.wifi_off_rounded,
            size: (iconSize ?? AppSizes.iconXl).sp,
            color: iconColor ?? muted,
          ),
          SizedBox(height: AppSpacing.medium.h),
          CustomText(
            title ?? AppStrings.errorNetwork,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: AppSpacing.small.h),
          CustomText(
            description ?? 'Please check your connection and try again.',
            style: theme.textTheme.bodyMedium,
            color: muted,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: AppSpacing.medium.h),
            CustomButton(
              text: retryText ?? AppStrings.retry,
              onPressed: onRetry,
              width: 180.w,
              height: AppSizes.buttonHeightMd,
            ),
          ],
        ],
      ),
    );
  }
}
