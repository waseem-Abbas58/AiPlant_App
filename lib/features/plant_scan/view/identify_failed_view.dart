import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import 'identify_tips_view.dart';

class IdentifyFailedView extends StatelessWidget {
  const IdentifyFailedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CustomContainer(
                onTap: NavigationHelper.back,
                padding: EdgeInsets.all(AppSpacing.medium.w),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18.sp,
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.medium.h),
            Icon(
              Icons.document_scanner_outlined,
              size: 52.sp,
              color: AppColors.white,
            ),
            SizedBox(height: AppSpacing.medium.h),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: CustomText(
                "We couldn't identify your plant",
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.small.h),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: CustomText(
                'Use the tips below for improved identification',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFD0D0D0),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.large.h),
            Divider(color: Colors.white24, indent: 40.w, endIndent: 40.w),
            const Expanded(
              child: IdentifyTipsBody(showDone: false),
            ),
          ],
        ),
      ),
    );
  }
}
