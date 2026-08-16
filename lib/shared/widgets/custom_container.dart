import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_radius.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.alignment,
    this.color,
    this.decoration,
    this.borderRadius,
    this.border,
    this.shadow,
    this.constraints,
    this.clipBehavior = Clip.none,
    this.onTap,
  });

  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;
  final Color? color;
  final Decoration? decoration;
  final double? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? shadow;
  final BoxConstraints? constraints;
  final Clip clipBehavior;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius != null
        ? BorderRadius.circular(borderRadius!.r)
        : null;

    final effectiveDecoration = decoration ??
        ((color != null || border != null || shadow != null || radius != null)
            ? BoxDecoration(
                color: color,
                borderRadius: radius,
                border: border,
                boxShadow: shadow,
              )
            : null);

    final container = Container(
      width: width?.w,
      height: height?.h,
      padding: padding,
      margin: margin,
      alignment: alignment,
      constraints: constraints,
      clipBehavior: clipBehavior,
      decoration: effectiveDecoration,
      color: effectiveDecoration == null ? color : null,
      child: child,
    );

    if (onTap == null) return container;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius ?? BorderRadius.circular(AppRadius.medium.r),
        child: container,
      ),
    );
  }
}
