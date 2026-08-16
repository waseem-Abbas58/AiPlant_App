import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_sizes.dart';
import '../../core/constants/app_strings.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
    this.semanticsLabel,
  });

  final double? size;
  final Color? color;
  final double? strokeWidth;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;
    final dimension = (size ?? AppSizes.iconLg).w;

    return Center(
      child: SizedBox(
        width: dimension,
        height: dimension,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          semanticsLabel: semanticsLabel ?? AppStrings.loading,
          backgroundColor: indicatorColor.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}
