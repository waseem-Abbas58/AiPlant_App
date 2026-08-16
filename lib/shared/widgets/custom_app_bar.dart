import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_sizes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle,
    this.elevation,
    this.toolbarHeight,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.flexibleSpace,
    this.systemOverlayStyle,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool? centerTitle;
  final double? elevation;
  final double? toolbarHeight;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  Size get preferredSize {
    final height = toolbarHeight ?? AppSizes.appBarHeight;
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(height.h + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      title: titleWidget ??
          (title == null
              ? null
              : Text(
                  title!,
                  style: appBarTheme.titleTextStyle?.copyWith(
                    color: foregroundColor,
                  ),
                )),
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: centerTitle,
      elevation: elevation,
      scrolledUnderElevation: elevation,
      toolbarHeight: (toolbarHeight ?? AppSizes.appBarHeight).h,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      flexibleSpace: flexibleSpace,
      systemOverlayStyle: systemOverlayStyle,
    );
  }
}
