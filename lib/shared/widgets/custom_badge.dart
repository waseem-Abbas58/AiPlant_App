import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

class CustomBadge extends StatelessWidget {
  const CustomBadge({
    super.key,
    this.text,
    this.child,
    this.icon,
    this.color,
    this.textColor,
    this.padding,
    this.radius,
    this.border,
    this.borderColor,
    this.textStyle,
  }) : assert(
          text != null || child != null || icon != null,
          'Provide text, child, or icon.',
        );

  final String? text;
  final Widget? child;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final BoxBorder? border;
  final Color? borderColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = textColor ?? AppColors.white;

    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.small.w,
            vertical: AppSpacing.extraSmall.h,
          ),
      decoration: BoxDecoration(
        color: color ?? AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(
          (radius ?? AppRadius.circular).r,
        ),
        border: border ??
            (borderColor == null
                ? null
                : Border.all(color: borderColor!)),
      ),
      child: child ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14.sp, color: foreground),
                if (text != null) SizedBox(width: AppSpacing.extraSmall.w),
              ],
              if (text != null)
                Text(
                  text!,
                  style: textStyle ??
                      theme.textTheme.labelSmall?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
    );
  }
}
