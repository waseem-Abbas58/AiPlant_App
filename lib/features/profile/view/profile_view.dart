import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/components/custom_snackbar.dart';
import '../../../shared/widgets/custom_bottom_navigation.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../home/view/plant_statistics_view.dart';
import '../../my_garden/controller/my_garden_controller.dart';
import '../../my_garden/widgets/garden_pop_in.dart'; 
import '../controller/profile_controller.dart';
import '../widgets/profile_setting_row.dart';
import 'edit_profile_view.dart';
import 'notifications_view.dart';
import 'privacy_view.dart';
import 'about_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

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
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.medium.w,
              AppSpacing.small.h,
              AppSpacing.medium.w,
              CustomBottomNavigation.barClearance(context) + AppSpacing.large.h,
            ),
            children: [
              const SizedBox(
                width: double.infinity,
                child: CustomText(
                  'Profile',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  letterSpacing: -0.6,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppSpacing.medium.h),
              GardenPopIn(child: _IdentityCard(controller: controller)),
              SizedBox(height: AppSpacing.large.h),  
              GardenPopIn(
                delay: const Duration(milliseconds: 40),
                child: ProfileSettingRow(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Subscription',
                  subtitle: 'Manage plan and scans',
                  onTap: controller.openSubscription,
                ),
              ),
              SizedBox(height: AppSpacing.small.h),
              GardenPopIn(
                delay: const Duration(milliseconds: 80),
                child: ProfileSettingRow(
                  icon: Icons.bar_chart_rounded,
                  title: 'Plant Statistics',
                  subtitle: 'Identifies, care, and diagnosis',
                  onTap: () => NavigationHelper.to(
                    () => const PlantStatisticsView(),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.small.h),
              GardenPopIn(
                delay: const Duration(milliseconds: 100),
                child: ProfileSettingRow(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Care, plan, and tips',
                  onTap: () => NavigationHelper.to(
                    () => const NotificationsView(),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.small.h),
              GardenPopIn(
                delay: const Duration(milliseconds: 120),
                child: ProfileSettingRow(
                  icon: Icons.lock_outline_rounded,
                  title: 'Privacy',
                  subtitle: 'Data, lock, and permissions',
                  onTap: () => NavigationHelper.to(() => const PrivacyView()),
                ),
              ),
              SizedBox(height: AppSpacing.small.h),
              GardenPopIn(
                delay: const Duration(milliseconds: 160),
                child: ProfileSettingRow(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  subtitle: 'Version, FAQ, rate us',
                  onTap: () => NavigationHelper.to(() => const AboutView()),
                ),
              ),
              SizedBox(height: AppSpacing.small.h),
              GardenPopIn(
                delay: const Duration(milliseconds: 180),
                child: Obx(() {
                  return ProfileSettingRow(
                    icon: Icons.person_outline_rounded,
                    title: 'User ID',
                    subtitle: controller.userIdLabel,
                    showChevron: false,
                    trailing: Icon(
                      Icons.copy_rounded,
                      size: 18.sp,
                      color: AppColors.mutedText,
                    ),
                    onTap: () => _copyUserId(controller.userId.value),
                  );
                }),
              ),
              SizedBox(height: AppSpacing.small.h),
              GardenPopIn(
                delay: const Duration(milliseconds: 200),
                child: ProfileSettingRow(
                  icon: Icons.logout_rounded,
                  title: 'Log out',
                  subtitle: 'Sign out of your account',
                  destructive: true,
                  onTap: () => _confirmLogOut(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyUserId(String id) async {
    if (id.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: id));
    CustomSnackbar.success(
      title: 'Copied',
      message: 'User ID copied',
      icon: Icons.copy_rounded,
    );
  }

  Future<void> _confirmLogOut(BuildContext context) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Log out?'),
          content: const Text('You can sign back in anytime.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );
    if (ok == true) controller.logOut();
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.controller});

  final ProfileController controller;

  void _openEdit() {
    NavigationHelper.to(() => const EditProfileView());
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Column(
        children: [
          Row(
            children: [
              UserAvatar(
                size: 64,
                elevated: true,
                onTap: _openEdit,
              ),
              SizedBox(width: AppSpacing.medium.w),
              Expanded(
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        controller.displayName.value,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                        letterSpacing: -0.3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      CustomText(
                        controller.emailLabel,
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      CustomContainer(
                        onTap: controller.openSubscription,
                        color: const Color(0xFFE8F0E6),
                        borderRadius: AppRadius.circular,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        child: const CustomText(
                          'Free plan',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              CustomContainer(
                onTap: _openEdit,
                color: const Color(0xFFE8F0E6),
                borderRadius: AppRadius.circular,
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18.sp,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.medium.h),
          Obx(() {
            final count = Get.isRegistered<MyGardenController>()
                ? Get.find<MyGardenController>().plants.length
                : 0;
            final label = count == 1 ? '1 plant' : '$count plants';
            return CustomContainer(
              onTap: controller.openGarden,
              color: AppColors.sageBackground,
              borderRadius: AppRadius.medium,
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_florist_outlined,
                    size: 20.sp,
                    color: AppColors.primaryGreen,
                  ),
                  SizedBox(width: AppSpacing.small.w),
                  Expanded(
                    child: CustomText(
                      label,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.sp,
                    color: AppColors.mutedText,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
