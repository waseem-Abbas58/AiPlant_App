import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import 'custom_text_field.dart';

class CustomSearchField extends StatefulWidget {
  const CustomSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  TextEditingController? _internalController;

  TextEditingController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isDark ? AppColors.darkTextSecondary : AppColors.mutedText;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;

        return CustomTextField(
          controller: _controller,
          focusNode: widget.focusNode,
          hintText: widget.hintText,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: AppSizes.iconMd.sp,
            color: iconColor,
          ),
          suffixIcon: hasText
              ? IconButton(
                  onPressed: widget.enabled ? _clear : null,
                  tooltip: 'Clear',
                  icon: Icon(
                    Icons.close_rounded,
                    size: AppSizes.iconSm.sp,
                    color: iconColor,
                  ),
                )
              : null,
        );
      },
    );
  }
}
