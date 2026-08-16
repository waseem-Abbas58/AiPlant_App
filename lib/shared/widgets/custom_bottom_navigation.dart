import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_spacing.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
    this.height,
    this.elevation,
    this.selectedFontSize,
    this.unselectedFontSize,
    this.type = BottomNavigationBarType.fixed,
    this.showSelectedLabels = true,
    this.showUnselectedLabels = true,
  });

  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? backgroundColor;
  final double? height;
  final double? elevation;
  final double? selectedFontSize;
  final double? unselectedFontSize;
  final BottomNavigationBarType type;
  final bool showSelectedLabels;
  final bool showUnselectedLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navTheme = theme.bottomNavigationBarTheme;
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: (height ?? AppSizes.buttonHeightLg + AppSpacing.small).h,
      child: BottomNavigationBar(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
        type: type,
        elevation: elevation ?? navTheme.elevation ?? 0,
        backgroundColor: backgroundColor ??
            navTheme.backgroundColor ??
            (isDark ? AppColors.darkSurface : AppColors.surface),
        selectedItemColor: selectedColor ??
            navTheme.selectedItemColor ??
            AppColors.primaryGreen,
        unselectedItemColor: unselectedColor ??
            navTheme.unselectedItemColor ??
            AppColors.mutedText,
        selectedFontSize: selectedFontSize ?? 14,
        unselectedFontSize: unselectedFontSize ?? 12,
        showSelectedLabels: showSelectedLabels,
        showUnselectedLabels: showUnselectedLabels,
      ),
    );
  }
}
