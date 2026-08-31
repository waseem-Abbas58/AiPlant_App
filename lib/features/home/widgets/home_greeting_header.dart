import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../main_navigation/controller/main_navigation_controller.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/view/edit_profile_view.dart';

class HomeGreetingHeader extends GetView<ProfileController> {
  const HomeGreetingHeader({super.key});

  void _openProfile() {
    if (!Get.isRegistered<MainNavigationController>()) return;
    Get.find<MainNavigationController>()
        .onTabTapped(MainNavigationController.profileIndex);
  }

  void _openEditProfile() {
    HapticFeedback.selectionClick();
    NavigationHelper.to(() => const EditProfileView());
  }

  static String _cityLabel(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return '';
    final comma = text.indexOf(',');
    if (comma <= 0) return text;
    return text.substring(0, comma).trim();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final city = _cityLabel(controller.location.value);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserAvatar(size: 48, elevated: true, onTap: _openProfile),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  controller.greeting,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                  letterSpacing: 0.15,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  controller.displayName.value,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  letterSpacing: -0.5,
                  height: 1.15,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (city.isNotEmpty) ...[
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: _openEditProfile,
              behavior: HitTestBehavior.opaque,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 88.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18.sp,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(height: 2.h),
                    CustomText(
                      city,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}
