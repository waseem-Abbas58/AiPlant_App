import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_borders.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_spacing.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
    this.style,
    this.hintStyle,
    this.onTap,
    this.focusedBorderColor,
    this.cursorColor,
    this.autovalidateMode,
    this.isDense = false,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextCapitalization textCapitalization;
  final Color? fillColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final VoidCallback? onTap;
  final Color? focusedBorderColor;
  final Color? cursorColor;
  final AutovalidateMode? autovalidateMode;
  final bool isDense;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(
      (borderRadius ?? AppRadius.large).r,
    );

    final defaultFill =
        fillColor ?? (isDark ? AppColors.darkSurface : AppColors.surface);
    final hintColor =
        isDark ? AppColors.darkTextSecondary : AppColors.mutedText;

    OutlineInputBorder buildBorder(Color color, {double? width}) {
      return OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(
          color: color,
          width: width ?? AppBorders.widthRegular,
        ),
      );
    }

    final subtleBorder = buildBorder(
      (isDark ? AppColors.darkBorder : AppColors.border).withValues(alpha: 0.45),
      width: AppBorders.widthThin,
    );

    final effectivePadding = contentPadding ??
        EdgeInsets.symmetric(
          horizontal: AppSpacing.medium.w,
          vertical: AppSpacing.medium.h + AppSpacing.extraSmall.h,
        );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      autofocus: autofocus,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      textCapitalization: textCapitalization,
      textAlignVertical: TextAlignVertical.center,
      onTap: onTap,
      autofillHints: autofillHints,
      style: style ??
          theme.textTheme.bodyLarge?.copyWith(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.primaryText,
          ),
      cursorColor: cursorColor ?? AppColors.blue,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        isDense: isDense,
        filled: true,
        fillColor: enabled
            ? defaultFill
            : (isDark ? AppColors.darkBackground : AppColors.background),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixIconConstraints: BoxConstraints(
          minWidth: AppSizes.iconLg.w,
          minHeight: AppSizes.textFieldHeight.h,
        ),
        suffixIconConstraints: BoxConstraints(
          minWidth: AppSizes.iconLg.w,
          minHeight: AppSizes.textFieldHeight.h,
        ),
        contentPadding: effectivePadding,
        hintStyle: hintStyle ??
            theme.textTheme.bodyLarge?.copyWith(color: hintColor),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.secondaryText,
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.error,
          height: 1.2,
        ),
        counterText: maxLength == null ? '' : null,
        border: subtleBorder,
        enabledBorder: subtleBorder, 
        focusedBorder: buildBorder(
          focusedBorderColor ?? AppColors.blue,
          width: AppBorders.widthThick,
        ),
        errorBorder: buildBorder(AppColors.error),
        focusedErrorBorder: buildBorder(
          AppColors.error,
          width: AppBorders.widthThick,
        ),
        disabledBorder: subtleBorder,
      ),
    );
  }
}
