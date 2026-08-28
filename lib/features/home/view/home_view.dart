import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_search_field.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/home_controller.dart';
import '../model/browse_category.dart';
import '../model/suggestion_article.dart';
import '../model/trending_plant.dart';
import '../widgets/category_card.dart';
import 'category_plants_view.dart';
import '../widgets/disease_grid_item.dart';
import '../widgets/home_section_header.dart';
import '../widgets/home_greeting_header.dart';
import '../widgets/horizontal_content_card.dart';
import '../widgets/plant_tool_card.dart';
import '../widgets/trending_card.dart';
import '../widgets/vertical_image_card.dart';
import '../../chatbot/data/botanist_navigator.dart';
import '../../main_navigation/controller/main_navigation_controller.dart';
import '../../my_garden/controller/my_garden_controller.dart';
import '../../my_garden/widgets/daily_care_summary.dart';
import '../../plant_scan/controller/plant_scan_controller.dart';
import '../../suggestions/view/suggestion_detail_view.dart';
import 'plant_statistics_view.dart';
import 'toxicity_check_view.dart';
import 'trending_plant_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static void _openScan(int category) {
    if (Get.isRegistered<PlantScanController>()) {
      Get.find<PlantScanController>().selectCategory(category);
    }
    if (!Get.isRegistered<MainNavigationController>()) return;
    Get.find<MainNavigationController>()
        .onTabTapped(MainNavigationController.scanIndex);
  }

  static void _openCategory(BrowseCategory category) {
    HapticFeedback.selectionClick();
    NavigationHelper.to(() => CategoryPlantsView(category: category));
  }

  static VoidCallback? onPlantToolTap(String title) {
    switch (title) {
      case 'Plant Identifier':
        return () => _openScan(0);
      case 'Disease Identifier':
        return () => _openScan(3);
      case 'Tree Identifier':
        return () => _openScan(4);
      case 'Water Meter':
        return () {
          if (Get.isRegistered<MyGardenController>()) {
            Get.find<MyGardenController>().openWaterMeter();
          }
        };
      case 'Ask Botanist':
        return () => openBotanistChat();
      case 'Mushroom Identifier':
        return () => _openScan(1);
      case 'Weed Identifier':
        return () => _openScan(2);
      case 'Toxicity Identifier':
        return () => NavigationHelper.to(() => const ToxicityCheckView());
      case 'Plant Finder':
        return () => NavigationHelper.toNamed(RouteNames.plantFinder);
      case 'Plant Statistics':
        return () => NavigationHelper.to(() => const PlantStatisticsView());
      default:
        return null;
    }
  }

  static const List<PlantToolCard> _plantTools = [
    PlantToolCard(
      imagePath: 'assets/images/plant_identifier.png',
      title: 'Plant Identifier',
    ),
    PlantToolCard(
      imagePath: 'assets/images/disease_identifier.png', 
      title: 'Disease Identifier',
    ), 
    PlantToolCard(
      imagePath: 'assets/images/tree_identifier.png',
      title: 'Tree Identifier',
    ),
    PlantToolCard(
      imagePath: 'assets/images/water_meter.png',
      title: 'Water Meter',
    ),
    PlantToolCard(
      imagePath: 'assets/images/ask_botanist.png',
      title: 'Ask Botanist',
    ),
    PlantToolCard(
      imagePath: 'assets/images/mushroom_identifier.png',
      title: 'Mushroom Identifier',
    ),
    PlantToolCard(
      imagePath: 'assets/images/weed_identification.png',
      title: 'Weed Identifier',
    ),
    PlantToolCard(
      imagePath: 'assets/images/toxicity_identifier.png',
      title: 'Toxicity Identifier',
    ),
    PlantToolCard(
      imagePath: 'assets/images/plant_finder.png',
      title: 'Plant Finder',
    ),
    PlantToolCard(
      imagePath: 'assets/images/plant_statistics.png',
      title: 'Plant Statistics',
    ),
  ];

  static const _trendingPlants = TrendingPlant.catalog;

  static const _categories = BrowseCategory.grid;

  static const List<VerticalImageCard> _homeRemedies = [
    VerticalImageCard(
      imagePath: 'assets/images/home/remedies/cinnamon_root_rot.png',
      title: 'Cinnamon Shield for Root Rot',
    ),
    VerticalImageCard(
      imagePath: 'assets/images/home/remedies/aloe_sunburn.png',
      title: 'Aloe Gel for Leaf Burn',
    ),
    VerticalImageCard(
      imagePath: 'assets/images/home/remedies/neem_oil_pests.png',
      title: 'Neem Oil Spray for Pests',
    ), 
    VerticalImageCard(
      imagePath: 'assets/images/home/remedies/eggshell_calcium.png',
      title: 'Eggshells for Calcium', 
    ),
    VerticalImageCard(  
      imagePath: 'assets/images/home/remedies/banana_peel_fertilizer.png',
      title: 'Banana Peel Fertilizer',
    ),
  ];

  static const List<HorizontalContentCard> _gardeningTips = [
    HorizontalContentCard(
      imagePath: 'assets/images/home/tips/trim_spent_blooms.png',
      title: 'Trim Spent Blooms',
      subtitle:
          'Deadhead faded flowers on houseplants like begonias and peace lilies so energy goes into new growth.',
    ),
    HorizontalContentCard(
      imagePath: 'assets/images/home/tips/let_soil_dry.png',
      title: 'Let Soil Dry First',
      subtitle:
          'Check the top inch with your finger before watering. Most houseplants prefer a light dry spell over soggy roots.',
    ),
    HorizontalContentCard(
      imagePath: 'assets/images/home/tips/rotate_for_light.png',
      title: 'Rotate for Even Light',
      subtitle:
          'Turn the pot a quarter turn each week so every side gets sun and the plant grows full instead of leaning.',
    ),
    HorizontalContentCard(
      imagePath: 'assets/images/home/tips/wipe_dusty_leaves.png',
      title: 'Wipe Dusty Leaves',
      subtitle:
          'Dust blocks light. Wipe leaves with a soft damp cloth so the plant can photosynthesize and stay glossy.',
    ),
    HorizontalContentCard(
      imagePath: 'assets/images/home/tips/bottom_watering.png',
      title: 'Bottom Watering',
      subtitle:
          'Set the pot in a saucer of water and let the soil drink from below. Stop once the top feels evenly moist.',
    ),
  ];

  static const List<DiseaseGridItem> _plantDiseases = [
    DiseaseGridItem(
      imagePath: 'assets/images/home/diseases/downy_mildew.png',
      title: 'Downy Mildew',
    ),
    DiseaseGridItem(
      imagePath: 'assets/images/home/diseases/anthracnose.png',
      title: 'Anthracnose',
    ),
    DiseaseGridItem(
      imagePath: 'assets/images/home/diseases/spider_mites.png',
      title: 'Spider Mites',
    ),
    DiseaseGridItem(
      imagePath: 'assets/images/home/diseases/botrytis.png',
      title: 'Botrytis',
    ),
    DiseaseGridItem(
      imagePath: 'assets/images/home/diseases/late_blight.png',
      title: 'Late Blight',
    ),
    DiseaseGridItem(
      imagePath: 'assets/images/home/diseases/powdery_mildew.png',
      title: 'Powdery Mildew',
    ),
  ];

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
          child: ListView(
            clipBehavior: Clip.none,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.medium.w,
              AppSpacing.medium.h,
              AppSpacing.medium.w,
              110.h,
            ),
            children: [
              const HomeGreetingHeader(),
                SizedBox(height: AppSpacing.small.h),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.large.r),
                    boxShadow: AppShadows.soft,
                  ), 
                  child: CustomSearchField(
                    hintText: 'Search plants, flowers, trees, tips',
                    fillColor: AppColors.white,
                    borderRadius: AppRadius.large,
                    height: 45,
                    readOnly: true,
                    onTap: () => NavigationHelper.toNamed(RouteNames.search),
                  ),
                ),
                SizedBox(height: AppSpacing.medium.h),   
                if (Get.isRegistered<MyGardenController>()) 
                  Obx(() {
                    final garden = Get.find<MyGardenController>();
                    if (garden.plants.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.medium.h),
                      child: DailyCareSummary(garden: garden),
                    );
                  }),
                const HomeSectionHeader('Plant Tools'),
                Obx(() {
                  final expanded = controller.showAllPlantTools.value;
                  final tools = expanded
                      ? _plantTools
                      : _plantTools.take(4).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GridView.count(
                          shrinkWrap: true, 
                          physics: const NeverScrollableScrollPhysics(),
                          clipBehavior: Clip.none,
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.small.h,
                          crossAxisSpacing: AppSpacing.small.w,
                          childAspectRatio: 1.65, 
                          children: [
                            for (final tool in tools)
                              PlantToolCard(
                                imagePath: tool.imagePath,
                                title: tool.title,
                                onTap: onPlantToolTap(tool.title),
                              ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.small.h),
                        CustomContainer(
                          onTap: controller.togglePlantTools,
                          pressScale: 0.98,
                          color: AppColors.white,
                          borderRadius: AppRadius.large,  
                          shadow: AppShadows.soft,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.medium.h,
                          ),
                          child: CustomText(
                            expanded ? 'Show less' : 'Show more tools',
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                    ],
                  );
                }),
                SizedBox(height: AppSpacing.medium.h),
                const HomeSectionHeader('Trending'),
                        SizedBox(
                          height: 210.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,  
                            clipBehavior: Clip.none,
                            itemCount: _trendingPlants.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(width: AppSpacing.small.w),
                            itemBuilder: (_, index) {
                              final plant = _trendingPlants[index];
                              return TrendingCard(
                                imagePath: plant.imagePath,
                                title: plant.name,
                                onTap: () => NavigationHelper.to(
                                  () => TrendingPlantView(plant: plant),
                                  fullscreenDialog: true,
                                  transition: Transition.downToUp,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: AppSpacing.medium.h),
                const HomeSectionHeader(
                  'Browse by Category',
                  bottom: AppSpacing.medium,
                ),
                Obx(() {
                  final expanded = controller.showAllCategories.value;
                  final categories = expanded
                      ? _categories
                      : _categories.take(4).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        clipBehavior: Clip.none,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: CategoryCard.extent,
                          mainAxisSpacing: 6.h,
                          crossAxisSpacing: 6.w,
                        ),
                        children: [
                          for (final category in categories)
                            CategoryCard(
                              title: category.title,
                              imagePath: category.imagePath,
                              color: category.color,
                              onTap: () => _openCategory(category),
                            ),
                        ],
                      ),
                      if (expanded) ...[
                        SizedBox(height: 6.h),
                        CategoryWideCard(
                          title: BrowseCategory.edible.title,
                          imagePath: BrowseCategory.edible.imagePath,
                          color: BrowseCategory.edible.color,
                          onTap: () => _openCategory(BrowseCategory.edible),
                        ),
                      ],
                      SizedBox(height: AppSpacing.medium.h),
                      CustomContainer(
                        onTap: controller.toggleCategories,
                        color: AppColors.white,
                        borderRadius: AppRadius.large,
                        shadow: AppShadows.soft, 
                        alignment: Alignment.center, 
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.medium.h,
                        ),
                        child: CustomText(
                          expanded ? 'Show Less' : 'Show More',
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  );
                }),
                        SizedBox(height: AppSpacing.large.h),
                        const HomeSectionHeader('Home Remedies'),
                        SizedBox(
                          height: VerticalImageCard.extent, 
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemCount: _homeRemedies.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(width: AppSpacing.small.w),
                            itemBuilder: (_, index) => _homeRemedies[index],
                          ),
                        ),
                        SizedBox(height: AppSpacing.large.h),
                        const HomeSectionHeader('Gardening Tips'),
                        SizedBox(
                          height: HorizontalContentCard.extent,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemCount: _gardeningTips.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(width: AppSpacing.small.w),
                            itemBuilder: (_, index) => _gardeningTips[index],
                          ),
                        ),
                        SizedBox(height: AppSpacing.large.h),
                        const HomeSectionHeader('Weekly Quiz'),
                        HorizontalContentCard(
                          expand: true,
                          imagePath: AppImages.weeklyQuiz,
                          imageFit: BoxFit.cover,
                          eyebrow: 'Week 34',
                          title: 'How much of a botanist are you?',
                          actionLabel: 'Take the Quiz!', 
                          onTap: () => NavigationHelper.toNamed(
                            RouteNames.weeklyQuiz, 
                            arguments: AppImages.weeklyQuiz,    
                                              
                          ),
                        ), 
                        SizedBox(height: AppSpacing.large.h),
                        const HomeSectionHeader('Common Plant Diseases'),
                        CustomContainer(
                          color: AppColors.white, 
                          borderRadius: AppRadius.extraLarge,
                          shadow: AppShadows.diffused,
                          padding: EdgeInsets.all(AppSpacing.medium.w),
                          child: GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisExtent: 118.h,
                              mainAxisSpacing: AppSpacing.medium.h,
                              crossAxisSpacing: AppSpacing.small.w,
                            ),
                            children: _plantDiseases,
                          ),
                        ),
                        SizedBox(height: AppSpacing.large.h),
                        const HomeSectionHeader('Suggestions'),
                        for (final article in SuggestionArticle.samples) ...[
                          HorizontalContentCard(
                            expand: true,
                            imagePath: article.imagePath,
                            eyebrow: article.category,
                            title: article.title,
                            actionLabel: 'Go to learn >',
                            onTap: () => NavigationHelper.to(
                              () => SuggestionDetailView(article: article),
                              transition: Transition.fadeIn,
                            ),
                            heroTag: article.imagePath,
                          ),
                          SizedBox(height: AppSpacing.small.h),
                        ],
            ],
          ),
        ), 
      ),  
    );
  }
}
