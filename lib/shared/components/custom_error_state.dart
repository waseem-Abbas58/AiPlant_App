import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';

class CustomErrorState extends StatelessWidget {
  const CustomErrorState({
    super.key,
    this.icon,
    this.image,
    this.title,
    this.message,
    this.retryText,
    this.onRetry,
    this.alignment = MainAxisAlignment.center,
    this.iconColor,
    this.iconSize,
  });

  final IconData? icon;
  final Widget? image;
  final String? title;
  final String? message;
  final String? retryText;
  final VoidCallback? onRetry;
  final MainAxisAlignment alignment;
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
        mainAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (image != null)
            image!
          else
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: (iconSize ?? AppSizes.iconXl).sp,
              color: iconColor ?? AppColors.error,
            ),
          SizedBox(height: AppSpacing.medium.h),
          CustomText(
            title ?? AppStrings.failed,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: AppSpacing.small.h),
          CustomText(
            message ?? AppStrings.errorGeneric,
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
