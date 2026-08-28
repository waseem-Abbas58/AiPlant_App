import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../my_garden/widgets/garden_pop_in.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';
import '../controller/profile_controller.dart';
import '../data/profile_notifications.dart';

class NotificationsView extends GetView<ProfileController> {
  const NotificationsView({super.key});

  Future<void> _pickTime(BuildContext context) async {
    var draft = _parseTime(controller.reminderTime.value);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) {
        return Container(
          height: 260.h,
          color: AppColors.white,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  onPressed: () {
                    controller.setReminderTime(DateFormat.jm().format(draft));
                    Navigator.of(popupContext).pop();
                  },
                  child: const Text('Done'),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: draft,
                  onDateTimeChanged: (value) => draft = value,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static DateTime _parseTime(String label) {
    try {
      return DateFormat.jm().parse(label);
    } catch (_) {
      return DateTime(2026, 1, 1, 9);
    }
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
              const GardenSubpageHeader(title: 'Notifications'),
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
                        'Choose which alerts you want for garden care, your plan, Home, and Ask Botanist.',
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: AppSpacing.medium.h),
                    GardenPopIn(
                      delay: const Duration(milliseconds: 40),
                      child: Obx(() {
                        return CustomContainer(
                          color: AppColors.white,
                          borderRadius: AppRadius.large,
                          border: Border.all(color: AppColors.border),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.medium.w,
                            vertical: 4.h,
                          ),
                          child: _ToggleRow(
                            title: 'Allow notifications',
                            subtitle: 'Master switch for all alerts',
                            value: controller.notifyMaster.value,
                            onChanged: controller.setNotifyMaster,
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: AppSpacing.small.h),
                    GardenPopIn(
                      delay: const Duration(milliseconds: 80),
                      child: Obx(() {
                        final on = controller.notifyMaster.value;
                        return Opacity(
                          opacity: on ? 1 : 0.45,
                          child: CustomContainer(
                            onTap: on ? () => _pickTime(context) : null,
                            color: AppColors.white,
                            borderRadius: AppRadius.large,
                            border: Border.all(color: AppColors.border),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.medium.w,
                              vertical: 12.h,
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        'Reminder time',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryText,
                                      ),
                                      CustomText(
                                        'Garden care alerts use this time',
                                        fontSize: 13,
                                        color: AppColors.secondaryText,
                                      ),
                                    ],
                                  ),
                                ),
                                CustomText(
                                  controller.reminderTime.value,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 22.sp,
                                  color: AppColors.mutedText,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    for (var i = 0;
                        i < ProfileNotifications.groups.length;
                        i++) ...[
                      SizedBox(height: AppSpacing.large.h),
                      GardenPopIn(
                        delay: Duration(milliseconds: 120 + 40 * i),
                        child: _NotifyGroupCard(
                          group: ProfileNotifications.groups[i],
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

class _NotifyGroupCard extends StatelessWidget {
  const _NotifyGroupCard({required this.group});

  final ProfileNotifyGroup group;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Obx(() {
      final master = controller.notifyMaster.value;
      final _ = controller.notifyOn.length;
      return Opacity(
        opacity: master ? 1 : 0.45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              group.title,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
            SizedBox(height: AppSpacing.small.h),
            CustomContainer(
              color: AppColors.white,
              borderRadius: AppRadius.large,
              border: Border.all(color: AppColors.border),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.medium.w,
                vertical: 4.h,
              ),
              child: Column(
                children: [
                  for (var i = 0; i < group.items.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        color: AppColors.border.withValues(alpha: 0.7),
                      ),
                    _ToggleRow(
                      title: group.items[i].title,
                      subtitle: group.items[i].subtitle,
                      value: controller.isNotifyOn(group.items[i].id),
                      enabled: master,
                      onChanged: (value) =>
                          controller.setNotify(group.items[i].id, value),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  subtitle,
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.primaryGreen,
            onChanged: enabled
                ? (next) {
                    HapticFeedback.selectionClick();
                    onChanged(next);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
