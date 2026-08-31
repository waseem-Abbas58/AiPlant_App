import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/components/custom_snackbar.dart';
import '../../../shared/widgets/custom_search_field.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../my_garden/controller/my_garden_controller.dart';
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
  var _filter = 'all';

  List<CategoryPlant> get _visible {
    var plants = widget.category.plants;
    if (_filter != 'all') {
      plants = plants.where((plant) {
        final detail = plant.toDetail(widget.category.id);
        switch (_filter) {
          case 'easy':
            return detail.difficultyChip == 'Easy';
          case 'indoor':
            return detail.placeChip.toLowerCase().contains('indoor');
          case 'outdoor':
            return detail.placeChip.toLowerCase().contains('outdoor');
          default:
            return true;
        }
      }).toList();
    }
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
                  enableVoice: true,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                  ),
                  child: Row(
                    children: [
                      for (final item in const [
                        ('all', 'All'),
                        ('easy', 'Easy'),
                        ('indoor', 'Indoor'),
                        ('outdoor', 'Outdoor'),
                      ]) ...[
                        if (item.$1 != 'all') SizedBox(width: 6.w),
                        Expanded(
                          child: _EqualFilterChip(
                            label: item.$2,
                            selected: _filter == item.$1,
                            onTap: () => setState(() => _filter = item.$1),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              Expanded(
                child: plants.isEmpty
                    ? Center(
                        child: CustomText(
                          _query.trim().isNotEmpty
                              ? 'No plant by that name'
                              : 'No plant matches this filter',
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
                                'Preview · full catalog when the library is connected.',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.mutedText,
                              ),
                            );
                          }
                          return Obx(() {
                            final inGarden =
                                Get.isRegistered<MyGardenController>() &&
                                    Get.find<MyGardenController>()
                                        .hasPlantNamed(plants[index].name);
                            return CategoryPlantRow(
                              plant: plants[index],
                              categoryId: widget.category.id,
                              inGarden: inGarden,
                              onTap: () => _openDetail(plants[index]),
                              onAdd: () {
                                if (inGarden) {
                                  CustomSnackbar.info(
                                    title: 'Already in garden',
                                    message: plants[index].name,
                                  );
                                  return;
                                }
                                showChooseGardenSheet(
                                  context,
                                  plant: plants[index],
                                );
                              },
                            );
                          });
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

class _EqualFilterChip extends StatelessWidget {
  const _EqualFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 30.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: CustomText(
          label,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.white : AppColors.primaryText,
        ),
      ),
    );
  }
}

