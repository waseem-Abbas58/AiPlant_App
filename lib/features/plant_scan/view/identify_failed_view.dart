import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../model/plant_identify_result.dart';
import 'identify_tips_view.dart';

class IdentifyFailedView extends StatelessWidget {
  const IdentifyFailedView({
    super.key,
    this.reason = IdentifyFailReason.notPlant,
    this.categoryId = 'plant',
  });

  final IdentifyFailReason reason;
  final String categoryId;

  bool get _notPlant => reason == IdentifyFailReason.notPlant;

  String get _title => _notPlant
      ? 'Please scan a plant'
      : "We couldn't identify this";

  String get _subtitle {
    if (!_notPlant) {
      return 'Fill the frame with one healthy plant in clear light, then try again.';
    }
    return switch (categoryId) {
      'tree' =>
        'We can identify trees and plants — not laptops, chairs, or other objects. Point at a leaf or bark and try again.',
      'mushroom' =>
        'We can identify mushrooms — not household objects. Fill the frame with the cap and stem, then try again.',
      'weed' =>
        'We can identify weeds and plants — not laptops or furniture. Photograph the whole plant and try again.',
      'disease' =>
        'We need a plant leaf in the photo. Household objects can’t be checked. Try again with a damaged leaf.',
      _ =>
        'We can identify plants, trees, mushrooms, and weeds — not laptops, chairs, or other objects. Try again with a plant in the frame.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.large.w),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CustomContainer(
                  onTap: NavigationHelper.back,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.small.h),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.crop_free_rounded,
                size: 52.sp,
                color: AppColors.white,
              ),
              SizedBox(height: AppSpacing.small.h),
              Icon(
                Icons.error_outline_rounded,
                size: 28.sp,
                color: AppColors.lightGreen,
              ),
              SizedBox(height: AppSpacing.large.h),
              CustomText(
                _title,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.small.h),
              CustomText(
                _subtitle,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFD0D0D0),
                textAlign: TextAlign.center,
                height: 1.4,
              ),
              if (!_notPlant) ...[
                SizedBox(height: AppSpacing.large.h),
                Divider(color: Colors.white24, indent: 8.w, endIndent: 8.w),
                const Expanded(
                  child: IdentifyTipsBody(showDone: false, showHeader: false),
                ),
              ] else
                const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.large.h),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomContainer(
                    onTap: NavigationHelper.back,
                    alignment: Alignment.center,
                    borderRadius: AppRadius.large,
                    border: Border.all(color: AppColors.lightGreen),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    child: const CustomText(
                      'Try again',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
