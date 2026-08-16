import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text.dart';

class CustomEmptyState extends StatelessWidget {
  const CustomEmptyState({
    super.key,
    this.icon,
    this.image,
    this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.spacing,
    this.alignment = MainAxisAlignment.center,
    this.iconColor,
    this.iconSize,
  });

  final IconData? icon;
  final Widget? image;
  final String? title;
  final String? description;
  final String? actionText;
  final VoidCallback? onAction;
  final double? spacing;
  final MainAxisAlignment alignment;
  final Color? iconColor;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gap = (spacing ?? AppSpacing.medium).h;
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
              icon ?? Icons.inbox_outlined,
              size: (iconSize ?? AppSizes.iconXl).sp,
              color: iconColor ?? muted,
            ),
          SizedBox(height: gap),
          CustomText(
            title ?? AppStrings.errorEmpty,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w600,
          ),
          if (description != null) ...[
            SizedBox(height: AppSpacing.small.h),
            CustomText(
              description!,
              style: theme.textTheme.bodyMedium,
              color: muted,
              textAlign: TextAlign.center,
            ),
          ],
          if (onAction != null) ...[
            SizedBox(height: gap),
            CustomButton(
              text: actionText ?? AppStrings.retry,
              onPressed: onAction,
              width: 180.w,
              height: AppSizes.buttonHeightMd,
            ),
          ],
        ],
      ),
    );
  }
}
