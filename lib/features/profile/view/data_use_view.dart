import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../my_garden/widgets/garden_pop_in.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';

class DataUseView extends StatelessWidget {
  const DataUseView({super.key});

  static const _points = [
    (
      Icons.phone_iphone_rounded,
      'On this phone',
      'Your profile, garden, and notification choices stay on this device until accounts go live.',
    ),
    (
      Icons.photo_outlined,
      'Photos you share',
      'Identify, disease scan, and Ask Botanist use photos you take or pick. They are not sold.',
    ),
    (
      Icons.notifications_outlined,
      'Alerts',
      'The reminder types and time you pick on Notifications stay on this phone.',
    ),
    (
      Icons.delete_outline_rounded,
      'Delete anytime',
      'Delete account on the Privacy screen removes your profile from this phone.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        body: SafeArea(
          child: Column(
            children: [
              const GardenSubpageHeader(title: 'How we use data'),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                    AppSpacing.medium.w,
                    AppSpacing.large.h,
                  ),
                  children: [
                    for (var i = 0; i < _points.length; i++) ...[
                      if (i > 0) SizedBox(height: AppSpacing.small.h),
                      GardenPopIn(
                        delay: Duration(milliseconds: 40 * i),
                        child: CustomContainer(
                          color: AppColors.white,
                          borderRadius: AppRadius.large,
                          border: Border.all(color: AppColors.border),
                          padding: EdgeInsets.all(AppSpacing.medium.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36.w,
                                height: 36.w,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE8F0E6),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  _points[i].$1,
                                  size: 18.sp,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              SizedBox(width: AppSpacing.small.w + 4.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      _points[i].$2,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryText,
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomText(
                                      _points[i].$3,
                                      fontSize: 13,
                                      color: AppColors.secondaryText,
                                      height: 1.4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
