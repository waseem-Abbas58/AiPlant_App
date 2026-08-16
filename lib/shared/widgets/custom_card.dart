import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_borders.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.border,
    this.borderRadius,
    this.elevation,
    this.shadow,
    this.alignment,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BoxBorder? border;
  final double? borderRadius;
  final double? elevation;
  final List<BoxShadow>? shadow;
  final AlignmentGeometry? alignment;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(
      (borderRadius ?? AppRadius.medium).r,
    );

    final card = Container(
      width: width?.w,
      height: height?.h,
      alignment: alignment,
      margin: margin ?? EdgeInsets.all(AppSpacing.small.r),
      padding: padding ?? EdgeInsets.all(AppSpacing.medium.r),
      decoration: BoxDecoration(
        color: color ??
            (isDark ? AppColors.darkSurface : AppColors.card),
        borderRadius: radius,
        border: border ??
            Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: AppBorders.widthRegular,
            ),
        boxShadow: shadow ??
            (elevation != null && elevation! > 0
                ? AppShadows.soft
                : AppShadows.none),
      ),
      clipBehavior: clipBehavior,
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: card,
      ),
    );
  }
}
