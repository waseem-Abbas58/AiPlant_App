import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/constants/app_durations.dart';
import 'custom_text.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledBackgroundColor;
  final Color? disabledTextColor;

  bool get _isInteractive => enabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(
      (borderRadius ?? 17).r,
    );

    final bg = (_isInteractive || isLoading) 
        ? (backgroundColor ?? AppColors.blue)
        : (disabledBackgroundColor ?? AppColors.divider);

    final fg = (_isInteractive || isLoading)
        ? (textColor ?? AppColors.white)
        : (disabledTextColor ?? AppColors.mutedText);

    return _PressableScale(
      enabled: _isInteractive,
      child: SizedBox(
        width: width ?? double.infinity,
        height: (height ?? 54).h, 
        child: ElevatedButton(
          onPressed: _isInteractive ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledBackgroundColor: bg,
            disabledForegroundColor: fg,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            padding: padding ??
                EdgeInsets.symmetric(
                  horizontal: AppSpacing.medium.w,
                  vertical: AppSpacing.small.h,
                ),
            shape: RoundedRectangleBorder(borderRadius: radius),
            textStyle: textStyle ?? theme.textTheme.labelLarge,
          ),
          child: isLoading
              ? SizedBox(
                  width: AppSizes.iconMd.w,
                  height: AppSizes.iconMd.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leadingIcon != null) ...[
                      leadingIcon!,
                      SizedBox(width: AppSpacing.small.w),
                    ],
                    Flexible(
                      child: CustomText(
                        text,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle ?? theme.textTheme.labelLarge,
                        color: fg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      SizedBox(width: AppSpacing.small.w),
                      trailingIcon!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  const _PressableScale({
    required this.child,
    required this.enabled,
  });

  final Widget child;
  final bool enabled;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: AppDurations.fast,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.96 : 1,
          duration: AppDurations.fast,
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}
