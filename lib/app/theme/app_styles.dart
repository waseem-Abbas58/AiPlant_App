import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_borders.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';

class AppStyles {
  AppStyles._();

  static EdgeInsets get screenPadding => EdgeInsets.symmetric(
        horizontal: AppSpacing.medium.w,
        vertical: AppSpacing.medium.h,
      );

  static EdgeInsets get horizontalPadding => EdgeInsets.symmetric(
        horizontal: AppSpacing.medium.w,
      );

  static BorderRadius get radiusSm => BorderRadius.circular(AppRadius.small.r);
  static BorderRadius get radiusMd => BorderRadius.circular(AppRadius.medium.r);
  static BorderRadius get radiusLg => BorderRadius.circular(AppRadius.large.r);
  static BorderRadius get radiusXl =>
      BorderRadius.circular(AppRadius.extraLarge.r);

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.card,
        borderRadius: radiusMd,
        border: Border.fromBorderSide(AppBorders.regular),
      );

  static BoxDecoration get cardDecorationDark => BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: radiusMd,
        border: const Border.fromBorderSide(
          BorderSide(
            color: AppColors.darkBorder,
            width: AppBorders.widthRegular,
          ),
        ),
      );

  static List<BoxShadow> get softShadow => AppShadows.soft;

  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: Size(double.infinity, AppSizes.buttonHeightMd.h),
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
        elevation: 0,
      );

  static ButtonStyle get outlinedButton => OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        minimumSize: Size(double.infinity, AppSizes.buttonHeightMd.h),
        side: AppBorders.primary,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      );
}
