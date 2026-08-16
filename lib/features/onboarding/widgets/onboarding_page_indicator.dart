import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_borders.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_sizes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_durations.dart';

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentIndex,
  });

  final int pageCount;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final size = AppSizes.iconXs.w;
    final activeWidth = size + AppSpacing.small.w;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(pageCount, (index) {
        final isActive = index == currentIndex;

        return AnimatedContainer(
          duration: AppDurations.fast,
          curve: Curves.easeOutCubic,
          width: isActive ? activeWidth : size,
          height: size,
          margin: EdgeInsets.symmetric(horizontal: AppSpacing.extraSmall.w),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGreen : null,
            borderRadius: BorderRadius.circular(AppRadius.circular.r),
            border: Border.all(
              color: isActive ? AppColors.primaryGreen : AppColors.border,
              width: AppBorders.widthRegular,
            ),
          ),
        );
      }),
    );
  }
}
