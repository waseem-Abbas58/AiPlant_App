import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';
import '../../profile/view/about_view.dart';
import '../../profile/view/notifications_view.dart';
import '../../profile/view/privacy_view.dart';
import '../../profile/widgets/profile_setting_row.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

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
              const GardenSubpageHeader(title: 'Settings'),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                    AppSpacing.medium.w,
                    AppSpacing.extraLarge.h,
                  ),
                  children: [
                    ProfileSettingRow(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Care, plan, and tips',
                      onTap: () => NavigationHelper.to(
                        () => const NotificationsView(),
                      ),
                    ),
                    SizedBox(height: AppSpacing.small.h),
                    ProfileSettingRow(
                      icon: Icons.lock_outline_rounded,
                      title: 'Privacy',
                      subtitle: 'Data, lock, and permissions',
                      onTap: () => NavigationHelper.to(
                        () => const PrivacyView(),
                      ),
                    ),
                    SizedBox(height: AppSpacing.small.h),
                    ProfileSettingRow(
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      subtitle: 'Version, FAQ, rate us',
                      onTap: () => NavigationHelper.to(
                        () => const AboutView(),
                      ),
                    ),
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
