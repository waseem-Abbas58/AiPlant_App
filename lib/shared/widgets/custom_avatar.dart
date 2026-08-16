import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_borders.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';

class CustomAvatar extends StatelessWidget {
  const CustomAvatar({
    super.key,
    this.image,
    this.networkUrl,
    this.assetPath,
    this.child,
    this.icon,
    this.size,
    this.radius,
    this.backgroundColor,
    this.border,
    this.borderColor,
    this.placeholder,
    this.fit = BoxFit.cover,
  });

  final ImageProvider? image;
  final String? networkUrl;
  final String? assetPath;
  final Widget? child;
  final IconData? icon;
  final double? size;
  final double? radius;
  final Color? backgroundColor;
  final BoxBorder? border;
  final Color? borderColor;
  final Widget? placeholder;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dimension = (size ?? AppSizes.avatarMd).r;
    final resolvedRadius = radius?.r ?? dimension / 2;

    ImageProvider? provider = image;
    if (provider == null && networkUrl != null) {
      provider = NetworkImage(networkUrl!);
    } else if (provider == null && assetPath != null) {
      provider = AssetImage(assetPath!);
    }

    Widget content;
    if (child != null) {
      content = child!;
    } else if (provider != null) {
      content = Image(
        image: provider,
        fit: fit,
        width: dimension,
        height: dimension,
        errorBuilder: (_, __, ___) =>
            placeholder ?? _fallbackIcon(isDark, dimension),
      );
    } else {
      content = placeholder ??
          Icon(
            icon ?? Icons.person_outline_rounded,
            size: dimension * 0.5,
            color: isDark ? AppColors.darkTextSecondary : AppColors.mutedText,
          );
    }

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? AppColors.darkSurface : AppColors.background),
        shape: radius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            radius == null ? null : BorderRadius.circular(resolvedRadius),
        border: border ??
            Border.all(
              color: borderColor ??
                  (isDark ? AppColors.darkBorder : AppColors.border),
              width: AppBorders.widthRegular,
            ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: content,
    );
  }

  Widget _fallbackIcon(bool isDark, double dimension) {
    return Icon(
      icon ?? Icons.person_outline_rounded,
      size: dimension * 0.5,
      color: isDark ? AppColors.darkTextSecondary : AppColors.mutedText,
    );
  }
}
