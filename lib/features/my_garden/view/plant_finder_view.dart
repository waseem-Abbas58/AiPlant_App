import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/plant_finder_controller.dart';
import '../widgets/garden_filter_chip.dart';
import '../widgets/garden_soil_option.dart';
import '../widgets/garden_subpage_header.dart';
import '../widgets/garden_type_card.dart';

class PlantFinderView extends GetView<PlantFinderController> {
  const PlantFinderView({super.key});

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
              GardenSubpageHeader(
                title: 'Plant Finder',
                trailing: CustomContainer(
                  onTap: controller.reset,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.small.w,
                    vertical: AppSpacing.extraSmall.h,
                  ),
                  child: const CustomText(
                    'Reset',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              Expanded(
                child: Obx(
                  () => ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.medium.w,
                      AppSpacing.small.h,
                      AppSpacing.medium.w,
                      AppSpacing.large.h,
                    ),
                    children: [
                      const _FinderSectionTitle('Light'),
                      Wrap(
                        spacing: AppSpacing.small.w,
                        runSpacing: AppSpacing.small.h,
                        children: [
                          for (final option in PlantFinderController.lights)
                            GardenFilterChip(
                              label: option.label,
                              selected:
                                  controller.selectedLights.contains(option.id),
                              onTap: () => controller.toggle(
                                controller.selectedLights,
                                option.id,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.large.h),
                      const _FinderSectionTitle('Soil Composition'),
                      SizedBox(
                        height: 104.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: PlantFinderController.soils.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: AppSpacing.medium.w),
                          itemBuilder: (context, index) {
                            final option = PlantFinderController.soils[index];
                            return GardenSoilOption(
                              imagePath: option.imagePath!,
                              label: option.label,
                              selected: controller.selectedSoils
                                  .contains(option.id),
                              onTap: () => controller.toggle(
                                controller.selectedSoils,
                                option.id,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: AppSpacing.large.h),
                      const _FinderSectionTitle('Soil pH'),
                      Wrap(
                        spacing: AppSpacing.small.w,
                        runSpacing: AppSpacing.small.h,
                        children: [
                          for (final option in PlantFinderController.phLevels)
                            GardenFilterChip(
                              label: option.label,
                              selected:
                                  controller.selectedPh.contains(option.id),
                              onTap: () => controller.toggle(
                                controller.selectedPh,
                                option.id,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.large.h),
                      const _FinderSectionTitle('Plant Type'),
                      SizedBox(
                        height: GardenTypeCard.extent,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount: PlantFinderController.plantTypes.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: AppSpacing.small.w),
                          itemBuilder: (context, index) {
                            final option =
                                PlantFinderController.plantTypes[index];
                            return GardenTypeCard(
                              imagePath: option.imagePath!,
                              title: option.label,
                              selected: controller.selectedTypes
                                  .contains(option.id),
                              onTap: () => controller.toggle(
                                controller.selectedTypes,
                                option.id,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: AppSpacing.large.h),
                      const _FinderSectionTitle('Lifecycle'),
                      Wrap(
                        spacing: AppSpacing.small.w,
                        runSpacing: AppSpacing.small.h,
                        children: [
                          for (final option
                              in PlantFinderController.lifecycles)
                            GardenFilterChip(
                              label: option.label,
                              selected: controller.selectedLifecycles
                                  .contains(option.id),
                              onTap: () => controller.toggle(
                                controller.selectedLifecycles,
                                option.id,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.medium.w,
                  AppSpacing.small.h,
                  AppSpacing.medium.w,
                  AppSpacing.medium.h,
                ),
                child: CustomButton(
                  text: 'Done',
                  backgroundColor: AppColors.primaryGreen,
                  textColor: AppColors.white,
                  borderRadius: AppRadius.large,
                  onPressed: controller.apply,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinderSectionTitle extends StatelessWidget {
  const _FinderSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.small.h),
      child: CustomText(
        title,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText,
        letterSpacing: -0.28,
      ),
    );
  }
}
