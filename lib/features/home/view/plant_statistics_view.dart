import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../main_navigation/controller/main_navigation_controller.dart';
import '../../my_garden/controller/my_garden_controller.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';

class PlantStatisticsView extends StatelessWidget {
  const PlantStatisticsView({super.key});

  void _openGarden() {
    NavigationHelper.back();
    if (!Get.isRegistered<MainNavigationController>()) return;
    Get.find<MainNavigationController>()
        .onTabTapped(MainNavigationController.gardenIndex);
  }

  @override
  Widget build(BuildContext context) {
    final garden = Get.isRegistered<MyGardenController>()
        ? Get.find<MyGardenController>()
        : null;

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
              const GardenSubpageHeader(title: 'Statistics'),
              Expanded(
                child: garden == null
                    ? const SizedBox.shrink()
                    : Obx(() {
                        final plants = garden.plants.length;
                        final groups = garden.groups.length;
                        final streak = garden.careStreak.value;
                        final remaining = garden.dailyRemaining;
                        final next = garden.nextAction;

                        return ListView(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.medium.w,
                            AppSpacing.small.h,
                            AppSpacing.medium.w,
                            AppSpacing.large.h,
                          ),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    value: '$plants',
                                    label: 'Plants',
                                  ),
                                ),
                                SizedBox(width: AppSpacing.small.w),
                                Expanded(
                                  child: _StatCard(
                                    value: '$groups',
                                    label: 'Groups',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.small.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    value: '$streak',
                                    label: 'Day streak',
                                  ),
                                ),
                                SizedBox(width: AppSpacing.small.w),
                                Expanded(
                                  child: _StatCard(
                                    value: '$remaining',
                                    label: 'Tasks today',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.large.h),
                            if (plants == 0)
                              CustomContainer(
                                color: AppColors.white,
                                borderRadius: AppRadius.large,
                                shadow: AppShadows.soft,
                                padding: EdgeInsets.all(AppSpacing.medium.w),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      'Garden is empty',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryText,
                                    ),
                                    SizedBox(height: 4),
                                    CustomText(
                                      'Add a plant to see next watering and care here.',
                                      fontSize: 14,
                                      color: AppColors.secondaryText,
                                    ),
                                  ],
                                ),
                              )
                            else
                              CustomContainer(
                                color: AppColors.white,
                                borderRadius: AppRadius.large,
                                shadow: AppShadows.soft,
                                padding: EdgeInsets.all(AppSpacing.medium.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      next == null
                                          ? 'Caught up'
                                          : 'Next · ${next.plantName}',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryText,
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomText(
                                      next == null
                                          ? 'No care due today.'
                                          : '${next.title} · ${next.timeLabel}',
                                      fontSize: 14,
                                      color: AppColors.secondaryText,
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: AppSpacing.large.h),
                            CustomButton(
                              text: plants == 0 ? 'Add a plant' : 'Open garden',
                              backgroundColor: AppColors.primaryGreen,
                              textColor: AppColors.white,
                              onPressed: _openGarden,
                            ),
                          ],
                        );
                      }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.large.h,
        horizontal: AppSpacing.medium.w,
      ),
      child: Column(
        children: [
          CustomText(
            value,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryGreen,
          ),
          SizedBox(height: 4.h),
          CustomText(
            label,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}
