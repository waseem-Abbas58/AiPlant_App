import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../widgets/custom_text.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    super.key,
    this.child,
    this.title,
    this.showDragHandle = true,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
  });

  final Widget? child;
  final String? title;
  final bool showDragHandle;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  static Future<T?> show<T>({
    Widget? child,
    String? title,
    bool showDragHandle = true,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
  }) {
    final radius = (borderRadius ?? AppRadius.extraLarge).r;

    return Get.bottomSheet<T>(
      CustomBottomSheet(
        title: title,
        showDragHandle: showDragHandle,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        padding: padding,
        child: child,
      ),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = (borderRadius ?? AppRadius.extraLarge).r;

    return Container(
      padding: padding ??
          EdgeInsets.fromLTRB(
            AppSpacing.medium.w,
            AppSpacing.small.h,
            AppSpacing.medium.w,
            AppSpacing.large.h,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? AppColors.darkSurface : AppColors.surface),
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle) ...[
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: AppSpacing.medium.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.circular.r),
                  ),
                ),
              ),
            ],
            if (title != null) ...[
              CustomText(
                title!,
                style: theme.textTheme.titleMedium,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.medium.h),
            ],
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
