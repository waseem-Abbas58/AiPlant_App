import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_sizes.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    super.key,
    this.assetPath,
    this.networkUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.semanticsLabel,
  }) : assert(
          assetPath != null || networkUrl != null,
          'Provide either assetPath or networkUrl.',
        );

  final String? assetPath;
  final String? networkUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(
      (borderRadius ?? AppRadius.medium).r,
    );

    final image = networkUrl != null
        ? CachedNetworkImage(
            imageUrl: networkUrl!,
            width: width?.w,
            height: height?.h,
            fit: fit,
            placeholder: (_, __) =>
                placeholder ?? _defaultPlaceholder(context),
            errorWidget: (_, __, ___) =>
                errorWidget ?? _defaultError(context),
          )
        : Image.asset(
            assetPath!,
            width: width?.w,
            height: height?.h,
            fit: fit,
            semanticLabel: semanticsLabel,
            errorBuilder: (_, __, ___) =>
                errorWidget ?? _defaultError(context),
          );

    return ClipRRect(
      borderRadius: radius,
      child: semanticsLabel == null || assetPath != null
          ? image
          : Semantics(
              label: semanticsLabel,
              image: true,
              child: image,
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
