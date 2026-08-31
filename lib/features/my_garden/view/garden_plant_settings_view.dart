import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/my_garden_controller.dart';
import '../model/my_garden_model.dart';
import '../widgets/change_group_sheet.dart';
import '../widgets/edit_care_task_sheet.dart';
import '../widgets/garden_filter_chip.dart';
import '../widgets/garden_plant_image.dart';
import '../widgets/garden_subpage_header.dart';

class GardenPlantSettingsView extends StatelessWidget {
  const GardenPlantSettingsView({super.key, required this.plantId});

  final String plantId;

  @override
  Widget build(BuildContext context) {
    final garden = Get.find<MyGardenController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        body: SafeArea(
          child: Obx(() {
            final _ = garden.plants.length;
            GardenPlant? plant;
            for (final item in garden.plants) {
              if (item.id == plantId) plant = item;
            }
            if (plant == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                NavigationHelper.back();
              });
              return const SizedBox.shrink();
            }
            final current = plant;
            final group = garden.groups.firstWhere(
              (item) => item.id == current.groupId,
              orElse: () => const GardenGroup(
                id: GardenGroup.generalId,
                title: 'General',
              ),
            );

            return Column(
              children: [
                const GardenSubpageHeader(title: 'Settings'),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.medium.w,
                      AppSpacing.small.h,
                      AppSpacing.medium.w,
                      24.h,
                    ),
                    children: [
                      const _SectionTitle('Plant Group'),
                      _GroupCard(
                        plant: current,
                        group: group,
                        count: garden.plantCountFor(group.id),
                        onTap: () => showChangeGroupSheet(
                          context,
                          groups: garden.groups.toList(),
                          selectedId: current.groupId,
                          onSelect: (id) => garden.updatePlant(
                            current.copyWith(groupId: id),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.large.h),
                      const _SectionTitle('Care Schedule'),
                      _GroupedCard(
                        children: [
                          _CareTile(
                            icon: Icons.water_drop_outlined,
                            title: 'Water',
                            subtitle:
                                'Every ${garden.waterIntervalFor(current)} days',
                            onTap: () => garden.openCareTaskEditor(
                              context,
                              current,
                              GardenCareKind.water,
                            ),
                          ),
                          _CareTile(
                            icon: Icons.waves_outlined,
                            title: 'Mist',
                            subtitle: 'Every ${current.care.mistDays} days',
                            onTap: () => garden.openCareTaskEditor(
                              context,
                              current,
                              GardenCareKind.mist,
                            ),
                          ),
                          _CareTile(
                            icon: Icons.science_outlined,
                            title: 'Fertilizer',
                            subtitle:
                                'Every ${current.care.fertilizerMonths} months',
                            onTap: () => garden.openCareTaskEditor(
                              context,
                              current,
                              GardenCareKind.fertilizer,
                            ),
                          ),
                          _CareTile(
                            icon: Icons.rotate_right_outlined,
                            title: 'Rotate',
                            subtitle:
                                'Every ${current.care.rotateMonths} month',
                            onTap: () => garden.openCareTaskEditor(
                              context,
                              current,
                              GardenCareKind.rotate,
                            ),
                          ),
                          _CareTile(
                            icon: Icons.content_cut_rounded,
                            title: 'Cut',
                            subtitle: 'Every ${current.care.cutMonths} months',
                            onTap: () => garden.openCareTaskEditor(
                              context,
                              current,
                              GardenCareKind.cut,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.large.h),
                      const _SectionTitle('Pot size'),
                      _ChoiceCard(
                        options: GardenCareSchedule.potSizes,
                        selected: current.care.potSize,
                        onSelect: (value) => garden.updateCare(
                          current,
                          current.care.copyWith(potSize: value),
                        ),
                      ),
                      SizedBox(height: AppSpacing.medium.h),
                      const _SectionTitle('Light'),
                      _ChoiceCard(
                        options: GardenCareSchedule.lightLevels,
                        selected: current.care.lightLevel,
                        onSelect: (value) => garden.updateCare(
                          current,
                          current.care.copyWith(lightLevel: value),
                        ),
                      ),
                      SizedBox(height: AppSpacing.medium.h),
                      const _SectionTitle('Water amount'),
                      _ChoiceCard(
                        options: GardenCareSchedule.waterAmounts,
                        selected: current.care.waterAmount,
                        onSelect: (value) => garden.updateCare(
                          current,
                          current.care.copyWith(waterAmount: value),
                        ),
                      ),
                      SizedBox(height: AppSpacing.medium.h),
                      const _SectionTitle('Location'),
                      _ChoiceCard(
                        options: GardenCareSchedule.locations,
                        selected: current.care.location,
                        onSelect: (value) => garden.updateCare(
                          current,
                          current.care.copyWith(location: value),
                        ),
                      ),
                      SizedBox(height: AppSpacing.large.h),
                      CustomContainer(
                        color: AppColors.white,
                        borderRadius: AppRadius.large,
                        padding: EdgeInsets.all(AppSpacing.medium.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CustomText(
                                    'Care calendar',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryText,
                                  ),
                                  CustomText(
                                    current.care.syncCalendar
                                        ? 'Next: ${garden.nextWaterLabel(current)} · ${current.care.waterTime}'
                                        : 'Keep the next watering date on the Care calendar',
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                  ),
                                ],
                              ),
                            ),
                            CupertinoSwitch(
                              value: current.care.syncCalendar,
                              activeTrackColor: AppColors.primaryGreen,
                              onChanged: (value) =>
                                  garden.setCalendarSync(current, value),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.extraLarge.h),
                      CustomButton(
                        text: 'Remove this plant',
                        backgroundColor: AppColors.error,
                        textColor: AppColors.white,
                        borderRadius: AppRadius.large,
                        onPressed: () async {
                          if (await garden.confirmDeletePlant(current)) {
                            NavigationHelper.back();
                            NavigationHelper.back();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
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

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.plant,
    required this.group,
    required this.count,
    required this.onTap,
  });

  final GardenPlant plant;
  final GardenGroup group;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        children: [
          GardenPlantImage(
            path: plant.imagePath,
            isAsset: plant.isAssetImage,
            width: 48.w,
            height: 48.w,
            borderRadius: BorderRadius.circular(AppRadius.medium.r),
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  group.title,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                CustomText(
                  '$count ${count == 1 ? 'plant' : 'plants'}',
                  fontSize: 13,
                  color: AppColors.secondaryText,
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

class _GroupedCard extends StatelessWidget {
  const _GroupedCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.divider,
                indent: 68.w,
              ),
          ],
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: GardenFilterChip(
              label: options[i],
              selected: options[i] == selected,
              expand: true,
              borderRadius: AppRadius.medium,
              onTap: () => onSelect(options[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _CareTile extends StatelessWidget {
  const _CareTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: Colors.transparent,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        children: [
          CustomContainer(
            width: 40,
            height: 40,
            color: AppColors.sageBackground,
            borderRadius: AppRadius.medium,
            alignment: Alignment.center,
            child: Icon(icon, size: 20.sp, color: AppColors.primaryGreen),
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                if (subtitle.isNotEmpty)
                  CustomText(
                    subtitle,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen,
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
