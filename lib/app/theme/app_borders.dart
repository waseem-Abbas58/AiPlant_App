import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppBorders {
  AppBorders._();

  static const double widthThin = 0.5;
  static const double widthRegular = 1;
  static const double widthThick = 2;

  static const double dividerWidth = widthRegular;

  static const BorderSide thin = BorderSide(
    color: AppColors.border,
    width: widthThin,
  );

  static const BorderSide regular = BorderSide(
    color: AppColors.border,
    width: widthRegular,
  );

  static const BorderSide thick = BorderSide(
    color: AppColors.border,
    width: widthThick,
  );

  static const BorderSide primary = BorderSide(
    color: AppColors.primaryGreen,
    width: widthRegular,
  );

  static const BorderSide error = BorderSide(
    color: AppColors.error,
    width: widthRegular,
  );
}
