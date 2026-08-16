import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/custom_text.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    this.title,
    this.content,
    this.contentWidget,
    this.icon,
    this.actions,
    this.backgroundColor,
    this.borderRadius,
    this.insetPadding,
  });

  final String? title;
  final String? content;
  final Widget? contentWidget;
  final Widget? icon;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsets? insetPadding;

  static Future<T?> show<T>({
    String? title,
    String? content,
    Widget? contentWidget,
    Widget? icon,
    List<Widget>? actions,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsets? insetPadding,
    bool barrierDismissible = true,
  }) {
    return Get.dialog<T>(
      CustomDialog(
        title: title,
        content: content,
        contentWidget: contentWidget,
        icon: icon,
        actions: actions,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        insetPadding: insetPadding,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dialogTheme = theme.dialogTheme;
    final radius = BorderRadius.circular(
      (borderRadius ?? AppRadius.large).r,
    );

    return Dialog(
      backgroundColor: backgroundColor ?? dialogTheme.backgroundColor,
      insetPadding: insetPadding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.large.w,
            vertical: AppSpacing.large.h,
          ),
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.large.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              SizedBox(height: AppSpacing.medium.h),
            ],
            if (title != null)
              CustomText(
                title!,
                style: dialogTheme.titleTextStyle ?? theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w600,
              ),
            if (contentWidget != null) ...[
              SizedBox(height: AppSpacing.small.h),
              contentWidget!,
            ] else if (content != null) ...[
              SizedBox(height: AppSpacing.small.h),
              CustomText(
                content!,
                style: dialogTheme.contentTextStyle ??
                    theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
                color: AppColors.secondaryText,
              ),
            ],
            if (actions != null && actions!.isNotEmpty) ...[
              SizedBox(height: AppSpacing.large.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!
                    .map(
                      (action) => Padding(
                        padding: EdgeInsets.only(left: AppSpacing.small.w),
                        child: action,
                      ),
                    )
                    .toList(),
              ),
            ] else ...[
              SizedBox(height: AppSpacing.large.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: Get.back,
                  child: Text(AppStrings.ok),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
