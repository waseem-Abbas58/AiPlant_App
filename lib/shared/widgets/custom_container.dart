import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    this.pressScale,
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
  final double? pressScale;

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

    return _IosTap(
      onTap: onTap!,
      pressScale: pressScale ?? 1,
      child: container,
    );
  }
}

class _IosTap extends StatefulWidget {
  const _IosTap({
    required this.onTap,
    required this.child,
    this.pressScale = 1,
  });

  final VoidCallback onTap;
  final Widget child;
  final double pressScale;

  @override
  State<_IosTap> createState() => _IosTapState();
}

class _IosTapState extends State<_IosTap> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed && widget.pressScale != 1 ? widget.pressScale : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 90),
          opacity: _pressed ? 0.86 : 1,
          child: widget.child,
        ),
      ),
    );
  }
}
