import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_text.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader(
    this.title, {
    super.key,
    this.bottom = AppSpacing.small,
  });

  final String title;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom.h),
      child: CustomText(
        title,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText,
        letterSpacing: -0.28,
        height: 1.2,
      ),
    );
  }
}
