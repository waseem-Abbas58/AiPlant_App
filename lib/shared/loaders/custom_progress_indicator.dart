import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/constants/app_strings.dart';

enum CustomProgressType { circular, linear }

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({
    super.key,
    this.type = CustomProgressType.circular,
    this.value,
    this.color,
    this.backgroundColor,
    this.size,
    this.strokeWidth,
    this.minHeight,
    this.semanticsLabel,
  });

  final CustomProgressType type;
  final double? value;
  final Color? color;
  final Color? backgroundColor;
  final double? size;
  final double? strokeWidth;
  final double? minHeight;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;
    final trackColor =
        backgroundColor ?? indicatorColor.withValues(alpha: 0.20);

    if (type == CustomProgressType.linear) {
      return LinearProgressIndicator(
        value: value,
        color: indicatorColor,
        backgroundColor: trackColor,
        minHeight: minHeight ?? AppSpacing.extraSmall.h,
        semanticsLabel: semanticsLabel ?? AppStrings.loading,
      );
    }

    final dimension = (size ?? AppSizes.iconLg).w;
    return SizedBox(
      width: dimension,
      height: dimension,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth ?? 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
        backgroundColor: trackColor,
        semanticsLabel: semanticsLabel ?? AppStrings.loading,
      ),
    );
  }
}
