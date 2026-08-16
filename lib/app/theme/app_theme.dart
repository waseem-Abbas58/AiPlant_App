import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_borders.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';
import 'app_text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _theme(
        brightness: Brightness.light,
        primary: AppColors.primaryGreen,
        onPrimary: AppColors.white,
        secondary: AppColors.secondaryGreen,
        onSecondary: AppColors.white,
        background: AppColors.background,
        surface: AppColors.surface,
        card: AppColors.card,
        onSurface: AppColors.primaryText,
        onSurfaceVariant: AppColors.secondaryText,
        muted: AppColors.mutedText,
        border: AppColors.border,
        divider: AppColors.divider,
        textTheme: AppTextTheme.light,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        inputFill: AppColors.background,
      );

  static ThemeData get dark => _theme(
        brightness: Brightness.dark,
        primary: AppColors.lightGreen,
        onPrimary: AppColors.nearBlack,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.nearBlack,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        card: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        onSurfaceVariant: AppColors.darkTextSecondary,
        muted: AppColors.darkTextSecondary,
        border: AppColors.darkBorder,
        divider: AppColors.darkBorder,
        textTheme: AppTextTheme.dark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        inputFill: AppColors.darkBackground,
      );

  static ThemeData _theme({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color onSecondary,
    required Color background,
    required Color surface,
    required Color card,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color muted,
    required Color border,
    required Color divider,
    required TextTheme textTheme,
    required SystemUiOverlayStyle systemOverlayStyle,
    required Color inputFill,
  }) {
    final borderRadius = BorderRadius.circular(AppRadius.medium);
    final dialogRadius = BorderRadius.circular(AppRadius.large);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: AppColors.error,
      onError: AppColors.white,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: border,
      outlineVariant: divider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: card,
      dividerColor: divider,
      disabledColor: muted,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(
        color: onSurface,
        size: AppSizes.iconMd,
      ),
      primaryIconTheme: IconThemeData(
        color: primary,
        size: AppSizes.iconMd,
      ),
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: _appBarTheme(
        surface: surface,
        onSurface: onSurface,
        textTheme: textTheme,
        systemOverlayStyle: systemOverlayStyle,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(
        primary: primary,
        onPrimary: onPrimary,
        textTheme: textTheme,
        borderRadius: borderRadius,
      ),
      outlinedButtonTheme: _outlinedButtonTheme(
        primary: primary,
        muted: muted,
        textTheme: textTheme,
        borderRadius: borderRadius,
      ),
      textButtonTheme: _textButtonTheme(
        primary: primary,
        muted: muted,
        textTheme: textTheme,
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: inputFill,
        borderColor: border,
        primary: primary,
        muted: muted,
        onSurface: onSurface,
        textTheme: textTheme,
        borderRadius: borderRadius,
      ),
      cardTheme: _cardTheme(
        card: card,
        border: border,
        borderRadius: borderRadius,
      ),
      dialogTheme: _dialogTheme(
        surface: surface,
        textTheme: textTheme,
        borderRadius: dialogRadius,
      ),
      navigationBarTheme: _navigationBarTheme(
        surface: surface,
        primary: primary,
        muted: muted,
        textTheme: textTheme,
      ),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(
        surface: surface,
        primary: primary,
        muted: muted,
        textTheme: textTheme,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withValues(alpha: 0.20),
        circularTrackColor: primary.withValues(alpha: 0.20),
        refreshBackgroundColor: surface,
      ),
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: AppBorders.dividerWidth,
        space: AppBorders.dividerWidth,
      ),
    );
  }

  static AppBarTheme _appBarTheme({
    required Color surface,
    required Color onSurface,
    required TextTheme textTheme,
    required SystemUiOverlayStyle systemOverlayStyle,
  }) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: surface,
      foregroundColor: onSurface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      iconTheme: IconThemeData(color: onSurface, size: AppSizes.iconMd),
      actionsIconTheme: IconThemeData(color: onSurface, size: AppSizes.iconMd),
      titleTextStyle: textTheme.titleLarge,
      toolbarHeight: AppSizes.appBarHeight,
      systemOverlayStyle: systemOverlayStyle,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme({
    required Color primary,
    required Color onPrimary,
    required TextTheme textTheme,
    required BorderRadius borderRadius,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        disabledBackgroundColor: primary.withValues(alpha: 0.40),
        disabledForegroundColor: onPrimary.withValues(alpha: 0.70),
        minimumSize: const Size(64, AppSizes.buttonHeightMd),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.small,
        ),
        textStyle: textTheme.labelLarge,
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme({
    required Color primary,
    required Color muted,
    required TextTheme textTheme,
    required BorderRadius borderRadius,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        disabledForegroundColor: muted,
        minimumSize: const Size(64, AppSizes.buttonHeightMd),
        side: BorderSide(color: primary, width: AppBorders.widthRegular),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.small,
        ),
        textStyle: textTheme.labelLarge,
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme({
    required Color primary,
    required Color muted,
    required TextTheme textTheme,
  }) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        disabledForegroundColor: muted,
        minimumSize: const Size(48, AppSizes.buttonHeightSm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.small,
          vertical: AppSpacing.extraSmall,
        ),
        textStyle: textTheme.labelLarge,
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required Color fillColor,
    required Color borderColor,
    required Color primary,
    required Color muted,
    required Color onSurface,
    required TextTheme textTheme,
    required BorderRadius borderRadius,
  }) {
    OutlineInputBorder border([
      Color? color,
      double width = AppBorders.widthRegular,
    ]) {
      return OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: color ?? borderColor,
          width: width,
        ),
      );
    }

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.medium,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
      labelStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
      floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: primary),
      errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.error),
      prefixIconColor: muted,
      suffixIconColor: muted,
      border: border(),
      enabledBorder: border(),
      focusedBorder: border(primary, AppBorders.widthThick),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, AppBorders.widthThick),
      disabledBorder: border(borderColor.withValues(alpha: 0.50)),
    );
  }

  static CardThemeData _cardTheme({
    required Color card,
    required Color border,
    required BorderRadius borderRadius,
  }) {
    return CardThemeData(
      color: card,
      elevation: 0,
      shadowColor: AppColors.black.withValues(alpha: 0.06),
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.all(AppSpacing.small),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: border, width: AppBorders.widthRegular),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  static DialogThemeData _dialogTheme({
    required Color surface,
    required TextTheme textTheme,
    required BorderRadius borderRadius,
  }) {
    return DialogThemeData(
      backgroundColor: surface,
      elevation: 0,
      shadowColor: AppColors.black.withValues(alpha: 0.10),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.large,
        vertical: AppSpacing.large,
      ),
    );
  }

  static NavigationBarThemeData _navigationBarTheme({
    required Color surface,
    required Color primary,
    required Color muted,
    required TextTheme textTheme,
  }) {
    return NavigationBarThemeData(
      backgroundColor: surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      indicatorColor: primary.withValues(alpha: 0.14),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelMedium?.copyWith(
          color: selected ? primary : muted,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: AppSizes.iconMd,
          color: selected ? primary : muted,
        );
      }),
    );
  }

  static BottomNavigationBarThemeData _bottomNavigationBarTheme({
    required Color surface,
    required Color primary,
    required Color muted,
    required TextTheme textTheme,
  }) {
    return BottomNavigationBarThemeData(
      backgroundColor: surface,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primary,
      unselectedItemColor: muted,
      selectedIconTheme: IconThemeData(size: AppSizes.iconMd, color: primary),
      unselectedIconTheme: IconThemeData(size: AppSizes.iconMd, color: muted),
      selectedLabelStyle: textTheme.labelMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: textTheme.labelMedium?.copyWith(color: muted),
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }
}
