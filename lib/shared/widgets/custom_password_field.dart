import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../core/constants/app_durations.dart';
import 'custom_text_field.dart';

class CustomPasswordField extends StatefulWidget {
  const CustomPasswordField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Password',
    this.labelText,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction = TextInputAction.done,
    this.fillColor,
    this.focusedBorderColor,
    this.cursorColor,
    this.borderRadius,
    this.contentPadding,
    this.style,
    this.hintStyle,
    this.autovalidateMode,
    this.isDense = false,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;
  final TextInputAction textInputAction;
  final Color? fillColor;
  final Color? focusedBorderColor;
  final Color? cursorColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final AutovalidateMode? autovalidateMode;
  final bool isDense;
  final Iterable<String>? autofillHints;

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isDark ? AppColors.darkTextSecondary : AppColors.mutedText;

    return CustomTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      hintText: widget.hintText,
      labelText: widget.labelText,
      prefixIcon: widget.prefixIcon,
      obscureText: _obscureText,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autocorrect: false,
      enableSuggestions: false,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      fillColor: widget.fillColor,
      focusedBorderColor: widget.focusedBorderColor,
      cursorColor: widget.cursorColor,
      borderRadius: widget.borderRadius,
      contentPadding: widget.contentPadding,
      style: widget.style,
      hintStyle: widget.hintStyle,
      autovalidateMode: widget.autovalidateMode,
      isDense: widget.isDense,
      autofillHints: widget.autofillHints,
      suffixIcon: IconButton(
        onPressed: widget.enabled ? _toggleVisibility : null,
        tooltip: _obscureText ? 'Show password' : 'Hide password',
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: BoxConstraints(
          minWidth: AppSizes.textFieldHeight.w,
          minHeight: AppSizes.textFieldHeight.h,
        ),
        icon: AnimatedSwitcher(
          duration: AppDurations.normal,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            key: ValueKey<bool>(_obscureText),
            size: AppSizes.iconMd.sp,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
