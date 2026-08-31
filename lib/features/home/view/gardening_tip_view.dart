import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../model/gardening_tip.dart';

class GardeningTipView extends StatelessWidget {
  const GardeningTipView({
    super.key,
    required this.tip,
    this.heroTag,
  });

  final GardeningTip tip;
  final String? heroTag;

  static void open(GardeningTip tip, {required String heroTag}) {
    HapticFeedback.selectionClick();
    NavigationHelper.to(
      () => GardeningTipView(tip: tip, heroTag: heroTag),
      fullscreenDialog: true,
      transition: Transition.downToUp,
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = 0.42.sh;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Hero(
                tag: heroTag ?? tip.imagePath,
                child: Image.asset(
                  tip.imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.medium.w),
                  child: GestureDetector(
                    onTap: NavigationHelper.back,
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.white,
                      size: 26.sp,
                      shadows: const [
                        Shadow(
                          color: Color(0x66000000),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: imageHeight - 28.h,
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.extraLarge.r),
                  ),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: NavigationHelper.back,
                      onVerticalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        if (velocity > 280) NavigationHelper.back();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.small.h,
                        ),
                        child: Center(
                          child: Container(
                            width: 36.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.circular),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.large.w,
                          AppSpacing.small.h,
                          AppSpacing.large.w,
                          AppSpacing.extraLarge.h,
                        ),
                        children: [
                          const CustomText(
                            'Gardening Tips',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                          SizedBox(height: AppSpacing.small.h),
                          CustomText(
                            tip.title,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                            height: 1.25,
                          ),
                          SizedBox(height: AppSpacing.medium.h),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.divider,
                          ),
                          SizedBox(height: AppSpacing.medium.h),
                          const CustomText(
                            'Overview',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                          SizedBox(height: AppSpacing.small.h),
                          CustomText(
                            tip.overview,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondaryText,
                            height: 1.55,
                          ),
                            SizedBox(height: AppSpacing.medium.h),
                            const CustomText(
                              'How to use',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                            SizedBox(height: AppSpacing.small.h),
                            ..._stepRows(tip.steps),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<Widget> _stepRows(List<String> steps) {
    return [
      for (var i = 0; i < steps.length; i++) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomContainer(
              width: 24,
              height: 24,
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: AppRadius.circular,
              alignment: Alignment.center,
              child: CustomText(
                '${i + 1}',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: AppSpacing.small.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: CustomText(
                  steps[i],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.medium.h),
      ],
    ];
  }
}
