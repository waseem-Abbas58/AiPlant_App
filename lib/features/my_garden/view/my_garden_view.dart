import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/my_garden_controller.dart';
import '../widgets/garden_empty_state.dart';
import '../widgets/garden_group_card.dart';
import '../widgets/garden_hero.dart';
import '../widgets/garden_icon_button.dart';
import '../widgets/garden_plant_card.dart';
import '../widgets/garden_pop_in.dart';

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
        backgroundColor: AppColors.sageBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _GardenHomeHeader(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                    AppSpacing.medium.w,
                    130.h,
                  ),
                  child: const _GardenHomeBody(),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium.w,
        AppSpacing.small.h,
        AppSpacing.medium.w,
        AppSpacing.small.h,
      ),
      child: Row(
        children: [
          const Expanded(
            child: CustomText(
              'My Garden',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              letterSpacing: -0.6,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GardenIconButton(
            icon: Icons.calendar_today_rounded,
            semanticLabel: 'Care',
            onTap: controller.openCare,
          ),
          SizedBox(width: AppSpacing.small.w),
          GardenIconButton(
            icon: Icons.photo_library_outlined,
            semanticLabel: 'Collection',
            onTap: controller.openSnapHistory,
          ),
          SizedBox(width: AppSpacing.small.w),
          GardenIconButton(
            icon: Icons.add_rounded,
            semanticLabel: 'Add Plant',
            emphasized: true,
            onTap: () => controller.openAddPlantSheet(context),
          ),
        ],
      ),
    );
  }
}

class _GardenHomeBody extends GetView<MyGardenController> {
  const _GardenHomeBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.plants.isEmpty) {
        return GardenEmptyState(
          illustration: const GardenEmptyArt(),
          title: 'Your garden starts here',
          subtitle:
              'Photograph a plant, save it, and keep care in one place.',
          actionLabel: 'Add Plant',
          filledAction: true,
          onAction: () => controller.openAddPlantSheet(context),
          secondaryLabel: 'Find a plant',
          onSecondary: controller.openPlantFinder,
        );
      }

      final visible = controller.visiblePlants;
      final showChips = controller.showGroupChips;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showChips) ...[
            SizedBox(
              height: GardenGroupCard.extent,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.groups.length + 2,
                separatorBuilder: (_, __) =>
                    SizedBox(width: AppSpacing.small.w),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final cover = controller.plants.isEmpty
                        ? null
                        : controller.plants.first.imagePath;
                    return GardenGroupCard(
                      title: 'All',
                      plantCount: controller.plants.length,
                      coverImagePath: cover,
                      coverIsAsset:
                          controller.plants.firstOrNull?.isAssetImage ?? true,
                      selected: controller.selectedGroupId.value == null,
                      onTap: () => controller.selectGroup(null),
                    );
                  }
                  if (index == controller.groups.length + 1) {
                    return GardenGroupCard(
                      title: 'New Group',
                      plantCount: 0,
                      outlined: true,
                      onTap: () => controller.openNewGroupSheet(context),
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
                    onLongPress: () =>
                        controller.openGroupEditor(context, group),
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.medium.h),
          ],
          Expanded(
            child: visible.isEmpty
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
                              status: controller.careLabelFor(visible.first),
                              heroTag:
                                  gardenPhotoHeroTag(visible.first.imagePath),
                              onTap: () =>
                                  controller.openPlantDetail(visible.first),
                              onStatusTap: controller
                                      .careLabelFor(visible.first)
                                      .toLowerCase()
                                      .contains('needs water')
                                  ? () => controller.openWaterMeter(
                                        plantId: visible.first.id,
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
                        padding: EdgeInsets.only(bottom: AppSpacing.small.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                              status: controller.careLabelFor(plant),
                              heroTag: gardenPhotoHeroTag(plant.imagePath),
                              onTap: () => controller.openPlantDetail(plant),
                              onStatusTap: controller
                                      .careLabelFor(plant)
                                      .toLowerCase()
                                      .contains('needs water')
                                  ? () => controller.openWaterMeter(
                                        plantId: plant.id,
                                      )
                                  : null,
                              onMore: () =>
                                  controller.openPlantMore(context, plant),
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
