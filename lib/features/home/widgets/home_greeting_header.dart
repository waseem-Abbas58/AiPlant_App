import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../main_navigation/controller/main_navigation_controller.dart';
import '../../profile/controller/profile_controller.dart';

class HomeGreetingHeader extends GetView<ProfileController> {
  const HomeGreetingHeader({super.key});

  void _openProfile() {
    if (!Get.isRegistered<MainNavigationController>()) return;
    Get.find<MainNavigationController>()
        .onTabTapped(MainNavigationController.profileIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(size: 48, elevated: true, onTap: _openProfile),
        SizedBox(width: 12.w),
        Expanded(
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  controller.greeting,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                  letterSpacing: 0.1,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  controller.displayName.value,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  letterSpacing: -0.4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          }),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _openProfile();
          },
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: AppShadows.soft,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.settings_outlined,
              size: 22.sp,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }
}
