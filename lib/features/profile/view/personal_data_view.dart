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
import '../../../shared/widgets/user_avatar.dart';
import '../../my_garden/widgets/garden_pop_in.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';
import '../controller/profile_controller.dart';
import 'change_password_view.dart';
import 'edit_profile_view.dart';

class PersonalDataView extends GetView<ProfileController> {
  const PersonalDataView({super.key});

  void _openEdit() {
    NavigationHelper.to(() => const EditProfileView());
  }

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
              const GardenSubpageHeader(title: 'Personal data'),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                    AppSpacing.medium.w,
                    AppSpacing.large.h,
                  ),
                  children: [
                    GardenPopIn(
                      child: Center(
                        child: UserAvatar(
                          size: 72,
                          elevated: true,
                          onTap: _openEdit,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    const GardenPopIn(
                      child: Center(
                        child: CustomText(
                          'Tap photo to edit profile',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.large.h),
                    GardenPopIn(
                      delay: const Duration(milliseconds: 40),
                      child: CustomContainer(
                        color: AppColors.white,
                        borderRadius: AppRadius.large,
                        border: Border.all(color: AppColors.border),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.medium.w,
                          vertical: 4.h,
                        ),
                        child: Obx(() {
                          return Column(
                            children: [
                              _DataRow(
                                label: 'Name',
                                value: controller.displayName.value,
                                onTap: _openEdit,
                              ),
                              const _RowDivider(),
                              _DataRow(
                                label: 'Email',
                                value: controller.unsetOr(controller.email.value),
                                onTap: _openEdit,
                              ),
                              const _RowDivider(),
                              _DataRow(
                                label: 'Password',
                                value: '••••••••',
                                trailing: 'Change',
                                onTap: () => NavigationHelper.to(
                                  () => const ChangePasswordView(),
                                ),
                              ),
                              const _RowDivider(),
                              _DataRow(
                                label: 'Garden name',
                                value: controller.unsetOr(
                                  controller.gardenName.value,
                                ),
                                onTap: _openEdit,
                              ),
                              const _RowDivider(),
                              _DataRow(
                                label: 'Location',
                                value: controller.unsetOr(
                                  controller.location.value,
                                ),
                                onTap: _openEdit,
                              ),
                            ],
                          );
                        }),
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

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: AppColors.border.withValues(alpha: 0.7),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          SizedBox(
            width: 108.w,
            child: CustomText(
              label,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          Expanded(
            child: CustomText(
              value,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null)
            CustomText(
              trailing!,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            )
          else
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: AppColors.mutedText,
            ),
        ],
      ),
    );
  }
}
