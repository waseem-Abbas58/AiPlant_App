import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/my_garden_controller.dart';
import '../model/my_garden_model.dart';
import '../widgets/daily_care_summary.dart';
import '../widgets/garden_empty_state.dart';
import '../widgets/garden_group_card.dart';
import '../widgets/garden_hero.dart';
import '../widgets/garden_plant_card.dart';
import '../widgets/garden_pop_in.dart';
import 'garden_care_view.dart';
import 'garden_snap_history_view.dart';

class MyGardenView extends GetView<MyGardenController> {
  const MyGardenView({super.key});

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
        backgroundColor: AppColors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _GardenHomeHeader(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 130.h),
                  child: Obx(
                    () => IndexedStack(
                      index: controller.homeTab.value,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.medium.w,
                            AppSpacing.small.h,
                            AppSpacing.medium.w,
                            0,
                          ),
                          child: const _GardenHomeBody(),
                        ),
                        const GardenCareView(embedded: true),
                        const GardenSnapHistoryView(embedded: true),
                      ],
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

class _GardenHomeHeader extends GetView<MyGardenController> {
  const _GardenHomeHeader();

  static const _tabs = ['My Garden', 'Tasks', 'Snap History'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.homeTab.value;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.medium.w,
          AppSpacing.small.h,
          AppSpacing.medium.w,
          0,
        ),
        child: Row(
          children: [
            for (var i = 0; i < _tabs.length; i++)
              Expanded(
                child: CustomContainer(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.selectHomeTab(i);
                  },
                  padding: EdgeInsets.only(top: AppSpacing.small.h),
                  child: Column(
                    children: [
                      CustomText(
                        _tabs[i],
                        fontSize: 15,
                        fontWeight: selected == i
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected == i
                            ? AppColors.primaryText
                            : AppColors.secondaryText,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10.h),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 2.h,
                        width: selected == i ? 28.w : 0,
                        color: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _GardenHomeBody extends GetView<MyGardenController> {
  const _GardenHomeBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final empty = controller.plants.isEmpty;
      final visible = controller.visiblePlants;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PerfectPlantCard(onTap: controller.openPlantFinder),
          SizedBox(height: AppSpacing.medium.h),
          Row(
            children: [
              const CustomText(
                'Group',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
                letterSpacing: -0.2,
              ),
              const Spacer(),
              CustomContainer(
                onTap: () => controller.openNewGroupSheet(context),
                color: AppColors.white,
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.lightGreen),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.small.w + 4.w,
                  vertical: 6.h,
                ),
                child: const CustomText(
                  'New Group',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.small.h),
          if (empty)
            SizedBox(
              width: double.infinity,
              child: GardenGroupCard(
                title: controller.groups.first.title,
                plantCount: 0,
                expand: true,
                onTap: () =>
                    controller.selectGroup(controller.groups.first.id),
                onAddPlant: () => controller.openAddPlantSheet(
                  context,
                  groupId: controller.groups.first.id,
                ),
              ),
            )
          else
            SizedBox(
              height: GardenGroupCard.extent,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.groups.length + 1,
                separatorBuilder: (_, __) =>
                    SizedBox(width: AppSpacing.small.w),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final cover = controller.plants.last;
                    return GardenGroupCard(
                      title: 'All',
                      plantCount: controller.plants.length,
                      coverImagePath: cover.imagePath,
                      coverIsAsset: cover.isAssetImage,
                      selected: controller.selectedGroupId.value == null,
                      onTap: () => controller.selectGroup(null),
                      onAddPlant: () =>
                          controller.openAddPlantSheet(context),
                    );
                  }
                  final group = controller.groups[index - 1];
                  return GardenGroupCard(
                    title: group.title,
                    plantCount: controller.plantCountFor(group.id),
                    coverImagePath: controller.coverPathFor(group),
                    coverIsAsset: controller.coverIsAssetFor(group),
                    selected: controller.selectedGroupId.value == group.id,
                    onTap: () => controller.selectGroup(group.id),
                    onLongPress: group.id == GardenGroup.generalId
                        ? null
                        : () => controller.openGroupEditor(context, group),
                    onAddPlant: () => controller.openAddPlantSheet(
                      context,
                      groupId: group.id,
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: AppSpacing.medium.h),
          if (!empty) ...[
            DailyCareSummary(garden: controller),
            SizedBox(height: AppSpacing.medium.h),
          ],
          Expanded(
            child: empty
                ? GardenEmptyState(
                    illustration: const GardenEmptyCardsArt(),
                    title: 'Your Garden is Empty',
                    subtitle:
                        'Manage your plant family, view care tips, and track plant growth here.',
                    actionLabel: 'Add First Plant',
                    compact: true,
                    onAction: () => controller.openAddPlantSheet(context),
                  )
                : visible.isEmpty
                    ? const Align(
                        alignment: Alignment.topLeft,
                        child: CustomText(
                          'No plants in this group.',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryText,
                        ),
                      )
                    : visible.length == 1
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              height: 320.h,
                              width: double.infinity,
                              child: GardenPopIn(
                                key: ValueKey(visible.first.id),
                                child: GardenPlantCard(
                                  imagePath: visible.first.imagePath,
                                  isAssetImage: visible.first.isAssetImage,
                                  name: visible.first.name,
                                  scientificName:
                                      visible.first.displayScientific,
                                  status:
                                      controller.careLabelFor(visible.first),
                                  heroTag: gardenPhotoHeroTag(
                                    visible.first.imagePath,
                                  ),
                                  onTap: () => controller
                                      .openPlantDetail(visible.first),
                                  onStatusTap: controller.canQuickWater(
                                    visible.first,
                                  )
                                      ? () => controller.markWatered(
                                            visible.first,
                                          )
                                      : null,
                                  onMore: () => controller.openPlantMore(
                                    context,
                                    visible.first,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding:
                                EdgeInsets.only(bottom: AppSpacing.small.h),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppSpacing.small.w,
                              mainAxisSpacing: AppSpacing.small.h,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: visible.length,
                            itemBuilder: (context, index) {
                              final plant = visible[index];
                              return GardenPopIn(
                                key: ValueKey(plant.id),
                                delay: Duration(
                                  milliseconds: 40 * (index.clamp(0, 7)),
                                ),
                                child: GardenPlantCard(
                                  imagePath: plant.imagePath,
                                  isAssetImage: plant.isAssetImage,
                                  name: plant.name,
                                  scientificName: plant.displayScientific,
                                  status: controller.careLabelFor(plant),
                                  heroTag:
                                      gardenPhotoHeroTag(plant.imagePath),
                                  onTap: () =>
                                      controller.openPlantDetail(plant),
                                  onStatusTap: controller.canQuickWater(plant)
                                      ? () => controller.markWatered(plant)
                                      : null,
                                  onMore: () => controller.openPlantMore(
                                    context,
                                    plant,
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      );
    });
  }
}

class _PerfectPlantCard extends StatelessWidget {
  const _PerfectPlantCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      color: AppColors.sageBackground,
      borderRadius: AppRadius.large,
      border: Border.all(color: AppColors.border),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium.w,
        vertical: AppSpacing.small.h + 4.h,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 26.sp,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: AppSpacing.small.w + 4.w),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  'Perfect Plant',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  letterSpacing: -0.2,
                ),
                CustomText(
                  'Choose the perfect plants for you!',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 22.sp,
            color: AppColors.mutedText,
          ),
        ],
      ),
    );
  }
}
