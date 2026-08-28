import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';

Future<T?> showGardenSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: isScrollControlled,
    backgroundColor: AppColors.white,
    barrierColor: const Color(0x52000000),
    sheetAnimationStyle: const AnimationStyle(
      curve: Curves.easeOutCubic,
      duration: Duration(milliseconds: 420),
      reverseCurve: Curves.easeInCubic,
      reverseDuration: Duration(milliseconds: 260),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.extraLarge.r),
      ),
    ),
    builder: builder,
  );
}
