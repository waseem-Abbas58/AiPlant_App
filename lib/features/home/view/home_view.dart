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
import '../model/gardening_tip.dart';
import '../model/home_remedy.dart';
import '../model/plant_disease.dart';
import '../model/suggestion_article.dart';
import '../model/trending_plant.dart';
import '../widgets/category_card.dart';
import 'category_plants_view.dart';
import 'gardening_tips_list_view.dart';
import 'home_remedy_view.dart';
import 'plant_disease_view.dart';
import '../widgets/disease_grid_item.dart';
import '../widgets/home_section_header.dart';
import '../widgets/home_greeting_header.dart';
import '../widgets/horizontal_content_card.dart';
import '../widgets/plant_tool_card.dart';
import '../widgets/trending_card.dart';
import '../widgets/vertical_image_card.dart';
import '../../chatbot/data/botanist_navigator.dart';
import '../../quiz/model/weekly_quiz.dart';
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

  static void _openGardeningTipsList() {
    HapticFeedback.selectionClick();
    NavigationHelper.to(() => const GardeningTipsListView());
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

  static const _homeRemedies = HomeRemedy.catalog;

  static const _gardeningTips = GardeningTip.catalog;

  static const _plantDiseases = PlantDisease.catalog;

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
              124.h,
            ),
            children: [
              const HomeGreetingHeader(),
                SizedBox(height: AppSpacing.medium.h),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.large.r),
                    boxShadow: AppShadows.soft,
                  ), 
                  child: CustomSearchField(
                    hintText: 'Search plants, flowers, trees, tips',
                    fillColor: AppColors.white,
                    borderRadius: AppRadius.large,
                    height: 48,
                    readOnly: true,
                    enableVoice: true,
                    onTap: () => NavigationHelper.toNamed(RouteNames.search),
                    onVoiceResult: (spoken) => NavigationHelper.toNamed(
                      RouteNames.search,
                      arguments: spoken,
                    ),
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
                const HomeSectionHeader(' Plant Tools'),          
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
                          borderRadius: AppRadius.medium,  
                          shadow: AppShadows.soft,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
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
                SizedBox(height: AppSpacing.large.h),
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
                        SizedBox(height: AppSpacing.large.h),
                const HomeSectionHeader(
                  'Browse by Category',    
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
                      SizedBox(height: AppSpacing.small.h),
                      CustomContainer(
                        onTap: controller.toggleCategories,
                        color: AppColors.white,
                        borderRadius: AppRadius.medium,
                        shadow: AppShadows.soft, 
                        alignment: Alignment.center, 
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                        ),
                        child: CustomText(
                          expanded ? 'Show less' : 'Show more',
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  );
                }),
                        SizedBox(height: AppSpacing.large.h),
                        const HomeSectionHeader(
                          'Home Remedies',
                        ),
                        SizedBox(
                          height: VerticalImageCard.extent, 
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemCount: _homeRemedies.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(width: AppSpacing.small.w),
                            itemBuilder: (_, index) {
                              final remedy = _homeRemedies[index];
                              return VerticalImageCard(
                                imagePath: remedy.imagePath,
                                title: remedy.cardTitle ?? remedy.title,
                                heroTag: remedy.imagePath,
                                chip: remedy.problemLabel,
                                onTap: () => NavigationHelper.to(
                                  () => HomeRemedyView(remedy: remedy),
                                  fullscreenDialog: true,
                                  transition: Transition.downToUp,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: AppSpacing.large.h),
                        Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.small.h),
                          child: Row(
                            children: [
                              const Expanded(
                                child: HomeSectionHeader(
                                  'Gardening Tips',
                                  bottom: 0,
                                ),
                              ),
                              GestureDetector(
                                onTap: _openGardeningTipsList,
                                behavior: HitTestBehavior.opaque,
                                child: const CustomText(
                                  'See all',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: HorizontalContentCard.extent,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemCount: _gardeningTips.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(width: AppSpacing.small.w),
                            itemBuilder: (_, index) {
                              final tip = _gardeningTips[index];
                              return HorizontalContentCard(
                                imagePath: tip.imagePath,
                                title: tip.listTitle,
                                subtitle: tip.cardLine,
                                color: AppColors.sageBackground,
                                titleMaxLines: 1,
                                subtitleMaxLines: 3,
                                onTap: _openGardeningTipsList,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: AppSpacing.large.h),
                        const HomeSectionHeader('Weekly Quiz'),
                        Obx(() {
                          final score = controller.quizScore.value;
                          final played = score != null;
                          return HorizontalContentCard(
                            expand: true,
                            imagePath: AppImages.weeklyQuiz,
                            imageFit: BoxFit.cover,
                            eyebrow: WeeklyQuiz.weekLabel,
                            title: played
                                ? WeeklyQuiz.resultTitle(
                                    score,
                                    WeeklyQuiz.questions.length,
                                  )
                                : WeeklyQuiz.prompt,
                            actionLabel:
                                played ? 'See your score' : 'Take the Quiz!',
                            chip: played
                                ? '$score/${WeeklyQuiz.questions.length}'
                                : null,
                            onTap: () => NavigationHelper.toNamed(
                              RouteNames.weeklyQuiz,
                              arguments: AppImages.weeklyQuiz,
                            ),
                          );
                        }), 
                        SizedBox(height: AppSpacing.large.h),
                        const HomeSectionHeader('Common Plant Diseases'),
                        CustomContainer(
                          color: AppColors.white,
                          borderRadius: AppRadius.extraLarge,
                          shadow: AppShadows.diffused,
                          padding: EdgeInsets.all(AppSpacing.medium.w),
                          child: Column(
                            children: [
                              for (var row = 0; row < 2; row++) ...[
                                if (row > 0)
                                  SizedBox(height: AppSpacing.medium.h),
                                SizedBox(
                                  height: 118.h,
                                  child: Row(
                                    children: [
                                      for (var col = 0; col < 3; col++) ...[
                                        if (col > 0)
                                          SizedBox(
                                            width: AppSpacing.small.w,
                                          ),
                                        Expanded(
                                          child: DiseaseGridItem(
                                            imagePath: _plantDiseases[
                                                    row * 3 + col]
                                                .imagePath,
                                            title: _plantDiseases[row * 3 + col]
                                                .title,
                                            onTap: () => PlantDiseaseView.open(
                                              _plantDiseases[row * 3 + col],
                                              heroTag: _plantDiseases[
                                                      row * 3 + col]
                                                  .imagePath,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.large.h),
                        const HomeSectionHeader('Suggestions'),
                        for (final article in SuggestionArticle.samples) ...[
                          HorizontalContentCard(
                            expand: true,
                            height: 136,
                            imagePath: article.imagePath,
                            eyebrow: article.category,
                            title: article.title,
                            titleFontSize: 16,
                            titleFontWeight: FontWeight.w700,
                            pinActionToBottom: false,
                            actionLabel: 'Go to learn >',
                            onTap: () => SuggestionDetailView.open(
                              article, 
                              heroTag: article.imagePath,
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
