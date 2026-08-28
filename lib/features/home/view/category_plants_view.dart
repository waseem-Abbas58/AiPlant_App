import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_search_field.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';
import '../model/browse_category.dart';
import '../widgets/category_plant_row.dart';
import '../widgets/choose_garden_sheet.dart';
import 'trending_plant_view.dart';

class CategoryPlantsView extends StatefulWidget {
  const CategoryPlantsView({super.key, required this.category});

  final BrowseCategory category;

  @override
  State<CategoryPlantsView> createState() => _CategoryPlantsViewState();
}

class _CategoryPlantsViewState extends State<CategoryPlantsView> {
  var _query = '';

  List<CategoryPlant> get _visible {
    final plants = widget.category.plants;
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return plants;
    return plants
        .where(
          (plant) =>
              plant.name.toLowerCase().contains(q) ||
              plant.scientificName.toLowerCase().contains(q),
        )
        .toList();
  }

  void _openDetail(CategoryPlant plant) {
    HapticFeedback.selectionClick();
    NavigationHelper.to(
      () => TrendingPlantView(plant: plant.toDetail(widget.category.id)),
      fullscreenDialog: true,
      transition: Transition.downToUp,
    );
  }

  @override
  Widget build(BuildContext context) {
    final plants = _visible;

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
          child: Column(
            children: [
              GardenSubpageHeader(title: widget.category.title),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.medium.w,
                  AppSpacing.small.h,
                  AppSpacing.medium.w,
                  AppSpacing.small.h,
                ),
                child: CustomSearchField(
                  hintText: 'Search a plant',
                  fillColor: AppColors.sageBackground,
                  borderRadius: AppRadius.large,
                  height: 44,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: plants.isEmpty
                    ? const Center(
                        child: CustomText(
                          'No plant by that name',
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.only(bottom: AppSpacing.large.h),
                        itemCount: plants.length + 1,
                        separatorBuilder: (_, index) {
                          if (index >= plants.length) {
                            return const SizedBox.shrink();
                          }
                          return Divider(
                            height: 1.h,
                            color: AppColors.divider,
                          );
                        },
                        itemBuilder: (_, index) {
                          if (index == plants.length) {
                            return Padding(
                              padding: EdgeInsets.fromLTRB(
                                AppSpacing.medium.w,
                                AppSpacing.medium.h,
                                AppSpacing.medium.w,
                                0,
                              ),
                              child: const CustomText(
                                'Preview library · full catalog when connected.',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.mutedText,
                              ),
                            );
                          }
                          return CategoryPlantRow(
                            plant: plants[index],
                            onTap: () => _openDetail(plants[index]),
                            onAdd: () => showChooseGardenSheet(
                              context,
                              plant: plants[index],
                            ),
                          );
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
