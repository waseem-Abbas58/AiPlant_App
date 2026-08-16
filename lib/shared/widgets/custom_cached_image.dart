import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_sizes.dart';
import '../../core/constants/app_durations.dart';

class CustomCachedImage extends StatelessWidget {
  const CustomCachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.alignment = Alignment.center,
    this.fadeInDuration,
    this.fadeOutDuration,
    this.color,
    this.colorBlendMode,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Alignment alignment;
  final Duration? fadeInDuration;
  final Duration? fadeOutDuration;
  final Color? color;
  final BlendMode? colorBlendMode;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(
      (borderRadius ?? AppRadius.medium).r,
    );

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width?.w,
        height: height?.h,
        fit: fit,
        alignment: alignment,
        color: color,
        colorBlendMode: colorBlendMode,
        fadeInDuration: fadeInDuration ?? AppDurations.fast,
        fadeOutDuration: fadeOutDuration ?? AppDurations.fast,
        placeholder: (_, __) => placeholder ?? _defaultPlaceholder(context),
        errorWidget: (_, __, ___) => errorWidget ?? _defaultError(context),
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
