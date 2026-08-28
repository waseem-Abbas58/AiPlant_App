import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/components/custom_snackbar.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../my_garden/controller/my_garden_controller.dart';
import '../../my_garden/model/my_garden_model.dart';
import '../../my_garden/widgets/garden_sheet.dart';
import '../../my_garden/widgets/new_group_sheet.dart';
import '../model/browse_category.dart';

Future<void> showChooseGardenSheet(
  BuildContext context, {
  required CategoryPlant plant,
}) {
  if (!Get.isRegistered<MyGardenController>()) return Future.value();
  HapticFeedback.selectionClick();
  return showGardenSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ChooseGardenBody(plant: plant),
  );
}

class _ChooseGardenBody extends StatelessWidget {
  const _ChooseGardenBody({required this.plant});

  final CategoryPlant plant;

  void _addTo(BuildContext context, MyGardenController garden, String groupId) {
    Navigator.of(context).pop();
    if (garden.hasPlantNamed(plant.name)) {
      HapticFeedback.selectionClick();
      CustomSnackbar.info(title: 'Already in garden', message: plant.name);
      return;
    }
    HapticFeedback.mediumImpact();
    garden.addPickedPlant(
      plant.imagePath,
      name: plant.name,
      scientificName: plant.scientificName,
      groupId: groupId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final garden = Get.find<MyGardenController>();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.large.w,
        AppSpacing.small.h,
        AppSpacing.large.w,
        AppSpacing.large.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Obx(() {
        final groups = garden.groups.toList();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomContainer(
              width: 36,
              height: 4,
              color: AppColors.divider,
              borderRadius: AppRadius.circular,
            ),
            SizedBox(height: AppSpacing.medium.h),
            const CustomText(
              'Choose a Garden',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              letterSpacing: -0.28,
            ),
            SizedBox(height: AppSpacing.small.h),
            const CustomText(
              'Group your plants by location or care schedule for easier management.',
              fontSize: 14,
              color: AppColors.secondaryText,
              textAlign: TextAlign.center,
              height: 1.4,
            ),
            SizedBox(height: AppSpacing.medium.h),
            Row(
              children: [
                const CustomText(
                  'Group',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                const Spacer(),
                CustomContainer(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    showNewGroupSheet(
                      context,
                      onSave: garden.addGroup,
                    );
                  },
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: AppRadius.circular,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium.w,
                    vertical: 6.h,
                  ),
                  child: const CustomText(
                    'New Group',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.small.h),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.42,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: groups.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: AppSpacing.small.h),
                itemBuilder: (_, index) {
                  final group = groups[index];
                  return _GroupPickCard(
                    group: group,
                    plantCount: garden.plantCountFor(group.id),
                    alreadyInGarden: garden.hasPlantNamed(plant.name),
                    onAdd: () => _addTo(context, garden, group.id),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _GroupPickCard extends StatelessWidget {
  const _GroupPickCard({
    required this.group,
    required this.plantCount,
    required this.alreadyInGarden,
    required this.onAdd,
  });

  final GardenGroup group;
  final int plantCount;
  final bool alreadyInGarden;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      border: Border.all(color: AppColors.border),
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            width: 56,
            height: 56,
            color: AppColors.sageBackground,
            borderRadius: AppRadius.medium,
            alignment: Alignment.center,
            child: Icon(
              Icons.eco_outlined,
              size: 26.sp,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  group.title,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                CustomText(
                  plantCount == 1 ? '1 plant' : '$plantCount plants',
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
                SizedBox(height: AppSpacing.small.h),
                CustomContainer(
                  onTap: alreadyInGarden ? null : onAdd,
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: AppRadius.circular,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium.w,
                    vertical: 6.h,
                  ),
                  child: CustomText(
                    alreadyInGarden ? 'In garden' : 'Add Plant',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
