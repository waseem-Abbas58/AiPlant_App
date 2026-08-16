import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/constants/app_durations.dart';
import '../../core/constants/app_strings.dart';

enum CustomSnackbarType { success, error, warning, info }

class CustomSnackbar {
  CustomSnackbar._();

  static void show({
    String? title,
    String? message,
    CustomSnackbarType type = CustomSnackbarType.info,
    IconData? icon,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colors = _colorsFor(type);

    Get.snackbar(
      title ?? _titleFor(type),
      message ?? '',
      icon: Icon(
        icon ?? _iconFor(type),
        color: AppColors.white,
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: colors,
      colorText: AppColors.white,
      margin: EdgeInsets.all(AppSpacing.small),
      borderRadius: AppRadius.medium,
      duration: duration ?? const Duration(seconds: 3),
      animationDuration: AppDurations.normal,
      mainButton: actionLabel == null
          ? null
          : TextButton(
              onPressed: () {
                onAction?.call();
                if (Get.isSnackbarOpen) {
                  Get.back();
                }
              },
              child: Text(
                actionLabel,
                style: const TextStyle(color: AppColors.white),
              ),
            ),
    );
  }

  static void success({
    String? title,
    String? message,
    IconData? icon,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      title: title,
      message: message,
      type: CustomSnackbarType.success,
      icon: icon,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void error({
    String? title,
    String? message,
    IconData? icon,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      title: title,
      message: message ?? AppStrings.errorGeneric,
      type: CustomSnackbarType.error,
      icon: icon,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void warning({
    String? title,
    String? message,
    IconData? icon,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      title: title,
      message: message,
      type: CustomSnackbarType.warning,
      icon: icon,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void info({
    String? title,
    String? message,
    IconData? icon,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      title: title,
      message: message,
      type: CustomSnackbarType.info,
      icon: icon,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static Color _colorsFor(CustomSnackbarType type) {
    switch (type) {
      case CustomSnackbarType.success:
        return AppColors.success;
      case CustomSnackbarType.error:
        return AppColors.error;
      case CustomSnackbarType.warning:
        return AppColors.warning;
      case CustomSnackbarType.info:
        return AppColors.info;
    }
  }

  static IconData _iconFor(CustomSnackbarType type) {
    switch (type) {
      case CustomSnackbarType.success:
        return Icons.check_circle_outline;
      case CustomSnackbarType.error:
        return Icons.error_outline;
      case CustomSnackbarType.warning:
        return Icons.warning_amber_rounded;
      case CustomSnackbarType.info:
        return Icons.info_outline;
    }
  }

  static String _titleFor(CustomSnackbarType type) {
    switch (type) {
      case CustomSnackbarType.success:
        return AppStrings.success;
      case CustomSnackbarType.error:
        return AppStrings.failed;
      case CustomSnackbarType.warning:
        return 'Warning';
      case CustomSnackbarType.info:
        return 'Info';
    }
  }
}
