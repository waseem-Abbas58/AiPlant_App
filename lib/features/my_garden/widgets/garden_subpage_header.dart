import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class GardenSubpageHeader extends StatelessWidget {
  const GardenSubpageHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.small.w,
        AppSpacing.small.h,
        AppSpacing.medium.w,
        AppSpacing.small.h,
      ),
      child: Row(
        children: [
          CustomContainer(
            onTap: NavigationHelper.back,
            padding: EdgeInsets.all(AppSpacing.small.w),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.sp,
              color: AppColors.primaryText,
            ),
          ),
          Expanded(
            child: CustomText(
              title,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              textAlign: TextAlign.center,
              letterSpacing: -0.28,
            ),
          ),
          trailing ?? SizedBox(width: 34.w),
        ],
      ),
    );
  }
}
