import 'package:flutter/cupertino.dart';
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
import '../../my_garden/widgets/garden_pop_in.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';
import '../controller/profile_controller.dart';
import '../widgets/passcode_sheets.dart';
import '../widgets/profile_setting_row.dart';
import 'app_permissions_view.dart';
import 'data_use_view.dart';
import 'personal_data_view.dart';

class PrivacyView extends GetView<ProfileController> {
  const PrivacyView({super.key});

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
              const GardenSubpageHeader(title: 'Privacy'),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                    AppSpacing.medium.w,
                    AppSpacing.large.h,
                  ),
                  children: [
                    const GardenPopIn(
                      child: CustomText(
                        'You control your data, app lock, and what this app can access.',
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: AppSpacing.large.h),
                    const GardenPopIn(
                      delay: Duration(milliseconds: 40),
                      child: _SectionTitle('Data'),
                    ),
                    GardenPopIn(
                      delay: const Duration(milliseconds: 60),
                      child: _Group(
                        children: [
                          ProfileSettingRow(
                            icon: Icons.person_outline_rounded,
                            title: 'Personal data',
                            subtitle: 'Photo, name, email, and garden',
                            onTap: () => NavigationHelper.to(
                              () => const PersonalDataView(),
                            ),
                          ),
                          ProfileSettingRow(
                            icon: Icons.policy_outlined,
                            title: 'How we use data',
                            subtitle: 'What stays on this device',
                            onTap: () => NavigationHelper.to(
                              () => const DataUseView(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.large.h),
                    const GardenPopIn(
                      delay: Duration(milliseconds: 100),
                      child: _SectionTitle('Security'),
                    ),
                    GardenPopIn(
                      delay: const Duration(milliseconds: 120),
                      child: Obx(() {
                        return _Group(
                          children: [
                            ProfileSettingRow(
                              icon: Icons.lock_outline_rounded,
                              title: 'Passcode lock',
                              subtitle: controller.passcodeOn.value
                                  ? 'On · 6-digit code'
                                  : 'Off · Set a 6-digit code',
                              onTap: () => openPasscodeLock(context),
                            ),
                            _BiometricRow(enabled: controller.passcodeOn.value),
                          ],
                        );
                      }),
                    ),
                    SizedBox(height: AppSpacing.large.h),
                    const GardenPopIn(
                      delay: Duration(milliseconds: 160),
                      child: _SectionTitle('Access'),
                    ),
                    GardenPopIn(
                      delay: const Duration(milliseconds: 180),
                      child: ProfileSettingRow(
                        icon: Icons.security_outlined,
                        title: 'App permissions',
                        subtitle: 'Camera, photos, mic, and alerts',
                        onTap: () => NavigationHelper.to(
                          () => const AppPermissionsView(),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.large.h),
                    const GardenPopIn(
                      delay: Duration(milliseconds: 220),
                      child: _SectionTitle('Account'),
                    ),
                    GardenPopIn(
                      delay: const Duration(milliseconds: 240),
                      child: ProfileSettingRow(
                        icon: Icons.delete_outline_rounded,
                        title: 'Delete account',
                        subtitle: 'Remove your profile from this phone',
                        destructive: true,
                        onTap: () => _confirmDelete(context),
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

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Delete account?'),
          content: const Text(
            'This removes your profile from this phone. You can create a new one anytime.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete account'),
            ),
          ],
        );
      },
    );
    if (ok == true) controller.deleteAccount();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.small.h),
      child: CustomText(
        text,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText,
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.small.h),
          children[i],
        ],
      ],
    );
  }
}

class _BiometricRow extends StatelessWidget {
  const _BiometricRow({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final profile = Get.find<ProfileController>();
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: CustomContainer(
        color: AppColors.white,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.medium.w,
          vertical: 10.h,
        ),
        child: Row(
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
                Icons.fingerprint_rounded,
                size: 18.sp,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: AppSpacing.small.w + 4.w),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    'Fingerprint',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                  CustomText(
                    'Unlock with fingerprint after passcode',
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ),
            Obx(() {
              return CupertinoSwitch(
                value: profile.biometricOn.value,
                activeTrackColor: AppColors.primaryGreen,
                onChanged: enabled
                    ? (value) {
                        HapticFeedback.selectionClick();
                        profile.setBiometric(value);
                      }
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
