import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_sizes.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode,
    this.semanticsLabel,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Alignment alignment;
  final Color? color;
  final BlendMode? colorBlendMode;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(
      (borderRadius ?? AppRadius.medium).r,
    );

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        url,
        width: width?.w,
        height: height?.h,
        fit: fit,
        alignment: alignment,
        color: color,
        colorBlendMode: colorBlendMode,
        semanticLabel: semanticsLabel,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return placeholder ?? _defaultPlaceholder(context);
        },
        errorBuilder: (_, __, ___) =>
            errorWidget ?? _defaultError(context),
      ),
    );
  }

  Widget _defaultPlaceholder(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.background,
      child: Center(
        child: SizedBox(
          width: AppSizes.iconMd.w,
          height: AppSizes.iconMd.w,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _defaultError(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.background,
      child: Icon(
        Icons.broken_image_outlined,
        size: AppSizes.iconLg.sp,
        color: AppColors.mutedText,
      ),
    );
  }
}
