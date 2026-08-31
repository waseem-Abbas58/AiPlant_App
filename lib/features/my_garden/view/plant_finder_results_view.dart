import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../home/model/trending_plant.dart';
import '../../home/view/trending_plant_view.dart';
import '../../home/widgets/horizontal_content_card.dart';
import '../controller/plant_finder_controller.dart';
import '../widgets/garden_subpage_header.dart';

class PlantFinderResultsView extends GetView<PlantFinderController> {
  const PlantFinderResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        body: SafeArea(
          child: Column(
            children: [
              const GardenSubpageHeader(title: 'Results'),
              Expanded(
                child: Obx(() {
                  controller.selectedLights.length;
                  controller.selectedSoils.length;
                  controller.selectedPh.length;
                  controller.selectedTypes.length;
                  controller.selectedLifecycles.length;
                  final plants = controller.matches;
                  final closest = controller.matchesAreClosest;
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.medium.w,
                      AppSpacing.small.h,
                      AppSpacing.medium.w,
                      AppSpacing.large.h,
                    ),
                    itemCount: plants.length + 1,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppSpacing.small.h),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.small.h),
                          child: CustomText(
                            closest
                                ? 'Closest matches · ${plants.length} plants'
                                : '${plants.length} plants',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        );
                      }
                      final plant = plants[index - 1];
                      return HorizontalContentCard(
                        expand: true,
                        imagePath: plant.imageAsset,
                        title: plant.name,
                        subtitle: plant.scientific,
                        eyebrow: closest ? 'Closest' : 'Match',
                        onTap: () {
                          final detail = TrendingPlant.byImagePath(
                            plant.imageAsset,
                          );
                          if (detail == null) return;
                          HapticFeedback.selectionClick();
                          NavigationHelper.to(
                            () => TrendingPlantView(plant: detail),
                            fullscreenDialog: true,
                            transition: Transition.downToUp,
                          );
                        },
                      );
                    },
                  );
                }),
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
                  onPressed: () {
                    NavigationHelper.back();
                    NavigationHelper.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
