import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import 'custom_svg.dart';

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

  static const int _scanIndex = 2;
  static const Duration _kMotion = Duration(milliseconds: 180);
  static const double _scanLift = 22;
  static const double _barHeight = 56;

  static double barClearance(BuildContext context) {
    return _scanLift.r +
        _barHeight.h +
        MediaQuery.paddingOf(context).bottom;
  }

  static final Color _inactiveColor =
      Color.lerp(AppColors.mutedText, AppColors.primaryGreen, 0.16) ??
          AppColors.mutedText;

  void _handleTap(int index) {
    if (index == currentIndex) return;
    HapticFeedback.selectionClick();
    onTap?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = selectedColor ?? AppColors.primaryGreen;
    final inactiveColor = unselectedColor ?? _inactiveColor;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final scanSize = 60.r;
    final scanLift = _scanLift.r;
    final barHeight = height?.h ?? _barHeight.h;
    final topRadius = AppRadius.large.r;
    final glassColor =
        (backgroundColor ?? AppColors.white).withValues(alpha: 0.94);

    return SizedBox(
      height: scanLift + barHeight + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(topRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(topRadius),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: ColoredBox(
                    color: glassColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ColoredBox(
                          color: AppColors.divider,
                          child: SizedBox(height: 1.h, width: double.infinity),
                        ),
                        SizedBox(
                          height: barHeight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.extraSmall.w,
                            ),
                            child: _DockTabs(
                              items: items,
                              currentIndex: currentIndex,
                              scanIndex: _scanIndex,
                              activeColor: activeColor,
                              inactiveColor: inactiveColor,
                              selectedFontSize: (selectedFontSize ?? 11).sp,
                              unselectedFontSize: (unselectedFontSize ?? 10).sp,
                              showSelectedLabels: showSelectedLabels,
                              showUnselectedLabels: showUnselectedLabels,
                              motion: _kMotion,
                              onTap: _handleTap,
                            ),
                          ),
                        ),
                        SizedBox(height: bottomInset),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _ScanActionButton(
                icon: items[_scanIndex].icon,
                selected: currentIndex == _scanIndex,
                size: scanSize,
                motion: _kMotion,
                onTap: () => _handleTap(_scanIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DockTabs extends StatelessWidget {
  const _DockTabs({
    required this.items,
    required this.currentIndex,
    required this.scanIndex,
    required this.activeColor,
    required this.inactiveColor,
    required this.selectedFontSize,
    required this.unselectedFontSize,
    required this.showSelectedLabels,
    required this.showUnselectedLabels,
    required this.motion,
    required this.onTap,
  });

  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final int scanIndex;
  final Color activeColor;
  final Color inactiveColor;
  final double selectedFontSize;
  final double unselectedFontSize;
  final bool showSelectedLabels;
  final bool showUnselectedLabels;
  final Duration motion;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < items.length; index++)
          Expanded(
            child: index == scanIndex
                ? const SizedBox.expand()
                : _BottomNavItem(
                    item: items[index],
                    selected: index == currentIndex,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    selectedFontSize: selectedFontSize,
                    unselectedFontSize: unselectedFontSize,
                    showLabel: index == currentIndex
                        ? showSelectedLabels
                        : showUnselectedLabels,
                    motion: motion,
                    onTap: () => onTap(index),
                  ),
          ),
      ],
    );
  }
}

class _ScanActionButton extends StatefulWidget {
  const _ScanActionButton({
    required this.icon,
    required this.selected,
    required this.size,
    required this.motion,
    required this.onTap,
  });

  final Widget icon;
  final bool selected;
  final double size;
  final Duration motion;
  final VoidCallback onTap;

  @override
  State<_ScanActionButton> createState() => _ScanActionButtonState();
}

class _ScanActionButtonState extends State<_ScanActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.96 : (widget.selected ? 1.0 : 0.98);

    return Semantics(
      button: true,
      selected: widget.selected,
      label: 'Scan',
      child: Listener(
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: scale,
            duration: widget.motion,
            curve: Curves.easeOutCubic,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: 2.5.r,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _NavIcon(
                  icon: widget.icon,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.item,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.selectedFontSize,
    required this.unselectedFontSize,
    required this.showLabel,
    required this.motion,
    required this.onTap,
  });

  final BottomNavigationBarItem item;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final double selectedFontSize;
  final double unselectedFontSize;
  final bool showLabel;
  final Duration motion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;
    final label = item.label ?? '';
    final baseStyle = Theme.of(context).textTheme.labelSmall;
    final iconSlot = 28.r;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: iconSlot,
            height: iconSlot,
            child: AnimatedScale(
              scale: selected ? 1.04 : 1.0,
              duration: motion,
              curve: Curves.easeOutCubic,
              child: TweenAnimationBuilder<Color?>(
                duration: motion,
                curve: Curves.easeOutCubic,
                tween: ColorTween(end: color),
                builder: (context, animatedColor, _) {
                  return Center(
                    child: _NavIcon(
                      icon: item.icon,
                      color: animatedColor ?? color,
                    ),
                  );
                },
              ),
            ),
          ),
          if (showLabel && label.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: AnimatedDefaultTextStyle(
                duration: motion,
                curve: Curves.easeOutCubic,
                style: (baseStyle ?? const TextStyle()).copyWith(
                  color: color,
                  fontSize: selected ? selectedFontSize : unselectedFontSize,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.1,
                  height: 1.0,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.color});

  final Widget icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = 22.r;

    if (icon is Icon) {
      return Icon((icon as Icon).icon, size: size, color: color);
    }

    final assetPath = icon is CustomSVG ? (icon as CustomSVG).assetPath : null;
    if (assetPath != null) {
      return SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          theme: SvgTheme(currentColor: color),
          semanticsLabel:
              icon is CustomSVG ? (icon as CustomSVG).semanticsLabel : null,
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        child: icon,
      ),
    );
  }
}
