import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../chatbot/data/botanist_navigator.dart';
import '../../my_garden/controller/my_garden_controller.dart';
import '../../plant_scan/view/identify_disease_view.dart';
import '../../suggestions/view/suggestion_detail_view.dart';
import '../model/suggestion_article.dart';
import '../model/trending_plant.dart';
import '../widgets/horizontal_content_card.dart';
import '../widgets/trending_card.dart';

class _CareTint {
  static const sun = Color(0xFFF9A825);
  static const water = Color(0xFF1E88E5);
  static const soil = Color(0xFF6D4C41);
  static const place = Color(0xFF00897B);
}

class TrendingPlantView extends StatefulWidget {
  const TrendingPlantView({super.key, required this.plant});

  final TrendingPlant plant;

  @override
  State<TrendingPlantView> createState() => _TrendingPlantViewState();
}

class _TrendingPlantViewState extends State<TrendingPlantView> {
  static const _tabs = [
    'Overview',
    'Requirements',
    'Culture',
    'FAQ',
    'Articles',
  ];

  var _tab = 0;

  TrendingPlant get _plant => widget.plant;

  void _save() {
    if (!Get.isRegistered<MyGardenController>()) return;
    final garden = Get.find<MyGardenController>();
    if (garden.hasPlantNamed(_plant.name)) {
      HapticFeedback.selectionClick();
      return;
    }
    HapticFeedback.mediumImpact();
    garden.addPickedPlant(
      _plant.imagePath,
      name: _plant.name,
      scientificName: _plant.scientificName,
    );
  }

  void _openPest(TrendingPest pest) {
    HapticFeedback.selectionClick();
    NavigationHelper.to(
      () => IdentifyDiseaseView(
        imagePath: pest.imagePath,
        plantName: _plant.name,
      ),
    );
  }

  void _openWaterMeter() {
    HapticFeedback.selectionClick();
    if (!Get.isRegistered<MyGardenController>()) return;
    final garden = Get.find<MyGardenController>();
    String? plantId;
    for (final plant in garden.plants) {
      if (plant.name.toLowerCase() == _plant.name.toLowerCase()) {
        plantId = plant.id;
        break;
      }
    }
    plantId ??= () {
      for (final plant in garden.plants) {
        if (plant.imagePath == _plant.imagePath) return plant.id;
      }
      return null;
    }();
    garden.openWaterMeter(plantId: plantId);
  }

  void _openChat() {
    HapticFeedback.selectionClick();
    openBotanistChat(
      plantName: _plant.name,
      imagePath: _plant.imagePath,
      isAssetImage: true,
    );
  }

  void _openSimilar(TrendingPlant plant) {
    HapticFeedback.selectionClick();
    NavigationHelper.to(
      () => TrendingPlantView(plant: plant),
      fullscreenDialog: true,
      transition: Transition.downToUp,
    );
  }

  void _openArticle(SuggestionArticle article) {
    HapticFeedback.selectionClick();
    NavigationHelper.to(
      () => SuggestionDetailView(article: article),
      transition: Transition.fadeIn,
    );
  }

  void _onTab(int index) {
    HapticFeedback.selectionClick();
    setState(() => _tab = index);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final overlap = 20.0;
    final headerHeight = (media.width * 210 / 148)
        .clamp(media.height * 0.42, media.height * 0.56)
        .toDouble();
    final sheetRest = ((media.height - headerHeight + overlap) / media.height)
        .clamp(0.44, 0.56)
        .toDouble();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: Hero(
                tag: _plant.imagePath,
                child: Image.asset(
                  _plant.imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: headerHeight,
                ),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: sheetRest,
              minChildSize: sheetRest,
              maxChildSize: 1,
              snap: true,
              snapSizes: [sheetRest, 1],
              builder: (context, scrollController) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.sageBackground,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.extraLarge.r),
                    ),
                    boxShadow: AppShadows.medium,
                  ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: CustomScrollView(
                            controller: scrollController,
                            slivers: [
                              SliverToBoxAdapter(child: _sheetHandle()),
                              SliverToBoxAdapter(child: _sheetTitle()),
                              SliverToBoxAdapter(child: _sheetTabs()),
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  AppSpacing.large.w,
                                  AppSpacing.medium.h,    
                                  AppSpacing.large.w, 
                                  AppSpacing.medium.h,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildListDelegate(
                                    _tabChildren(),
                                  ),
                                ),  
                              ), 
                            ],
                          ),
                        ),
                        CustomContainer(
                          color: AppColors.white,
                          shadow: AppShadows.soft, 
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.medium.w,
                            AppSpacing.small.h,
                            AppSpacing.medium.w,
                            AppSpacing.small.h + bottomInset,
                          ),
                          child: Obx(() {
                            final inGarden =
                                Get.isRegistered<MyGardenController>() &&
                                    Get.find<MyGardenController>()
                                        .hasPlantNamed(_plant.name);
                            return CustomButton(
                              text: inGarden
                                  ? 'In garden'
                                  : 'Save to My Garden',
                              backgroundColor: AppColors.primaryGreen,
                              textColor: AppColors.white,
                              borderRadius: AppRadius.medium,
                              enabled: !inGarden,
                              onPressed: inGarden ? null : _save,
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.medium.w),
                  child: GestureDetector(
                    onTap: NavigationHelper.back,
                    behavior: HitTestBehavior.opaque,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.soft,
                      ),
                      child: SizedBox(
                        width: 36.r,
                        height: 36.r,
                        child: Center(
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.secondaryText,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetHandle() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.small.h),
      child: Center(
        child: Container(
          width: 36.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(AppRadius.circular),
          ),
        ),
      ),
    );
  }

  Widget _sheetTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.large.w,
        AppSpacing.extraSmall.h,
        AppSpacing.large.w,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            _plant.name,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
            height: 1.15,
            letterSpacing: -0.4,
          ),
          SizedBox(height: AppSpacing.extraSmall.h),
          CustomText(
            _plant.scientificName,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _sheetTabs() {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.medium.h),
      child: SizedBox(
        height: 34.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.large.w),
          itemCount: _tabs.length,
          separatorBuilder: (_, __) => SizedBox(width: AppSpacing.small.w),
          itemBuilder: (_, index) {
            final selected = index == _tab;
            return CustomContainer(
              onTap: () => _onTab(index),
              pressScale: 0.98,
              color: selected ? AppColors.primaryGreen : AppColors.white,
              borderRadius: AppRadius.medium,
              border: selected
                  ? null
                  : Border.all(color: AppColors.border),
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 6.h,
              ),
              alignment: Alignment.center,
              child: CustomText(
                _tabs[index],
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.secondaryText,
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _tabChildren() {
    switch (_tab) {
      case 0:
        final similar = _plant.similar();
        return [
          CustomContainer(
            color: AppColors.white,
            borderRadius: AppRadius.large,
            shadow: AppShadows.soft,
            padding: EdgeInsets.all(AppSpacing.medium.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  'About',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                SizedBox(height: AppSpacing.small.h),
                CustomText(
                  _plant.aboutText,
                  fontSize: 14,
                  color: AppColors.secondaryText,
                  height: 1.45,
                ),
                SizedBox(height: AppSpacing.medium.h),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.small.w,
                    runSpacing: AppSpacing.small.h,
                    children: [
                    _NeedChip(
                      icon: Icons.spa_outlined,
                      label: _plant.difficultyChip,
                      iconColor: _plant.difficultyChip == 'Medium'
                          ? const Color(0xFF6A1B9A)
                          : AppColors.primaryGreen,
                    ),
                    _NeedChip(
                      icon: Icons.wb_sunny_outlined,
                      label: _plant.lightChip,
                      iconColor: _CareTint.sun,
                    ),
                    _NeedChip(
                      icon: Icons.opacity_outlined,
                      label: _plant.waterChip,
                      iconColor: _CareTint.water,
                    ),
                    _NeedChip(
                      icon: Icons.grass_outlined,
                      label: _plant.soilChip,
                      iconColor: _CareTint.soil,
                    ),
                    _NeedChip(
                      icon: Icons.home_outlined,
                      label: _plant.placeChip,
                      iconColor: _CareTint.place,
                    ),
                  ],
                ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.small.h),
          _FunFactCard(text: _plant.funFact),
          SizedBox(height: AppSpacing.small.h),
          const _AttentionBox(),
          SizedBox(height: AppSpacing.small.h),
          _PoisonCard(
            poisonous: _plant.toxicity.toxicToPets ||
                _plant.toxicity.toxicToKids,
          ),
          SizedBox(height: AppSpacing.small.h),
          _NextCareCard(
            line: _plant.nextWaterLine,
            season: _plant.seasonLine(),
            onTap: _openWaterMeter,
          ),
          _AlreadyInGardenNote(name: _plant.name),
          SizedBox(height: AppSpacing.medium.h),
          const _SectionLabel('Similar'),
          SizedBox(height: AppSpacing.small.h),
          SizedBox(
            height: 176.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: similar.length,
              separatorBuilder: (_, __) =>
                  SizedBox(width: AppSpacing.small.w),
              itemBuilder: (_, index) {
                final plant = similar[index];
                return TrendingCard(
                  imagePath: plant.imagePath,
                  title: plant.name,
                  badgeText: '',
                  width: 124,
                  height: 176,
                  onTap: () => _openSimilar(plant),
                );
              },
            ),
          ),
        ];
      case 1:
        return [
          const _SectionLabel('Care Requirements'),
          SizedBox(height: AppSpacing.small.h),
          Row(
            children: [
              Expanded(
                child: _SpecCard(
                  title: 'Temperature',
                  value: _plant.temperature,
                ),
              ),
              SizedBox(width: AppSpacing.small.w),
              Expanded(
                child: _SpecCard(
                  title: 'Hardiness Zone',
                  value: _plant.hardiness,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.small.h),
          _NeedRow(
            icon: Icons.opacity_outlined,
            title: 'Water',
            value: _plant.waterNote,
            iconColor: _CareTint.water,
          ),
          SizedBox(height: AppSpacing.small.h),
          _NeedRow(
            icon: Icons.wb_sunny_outlined,
            title: 'Sunlight',
            value: _plant.lightNote,
            iconColor: _CareTint.sun,
          ),
          SizedBox(height: AppSpacing.small.h),
          _NeedRow(
            icon: Icons.grass_outlined,
            title: 'Soil',
            value: _plant.soilNote,
            iconColor: _CareTint.soil,
          ),
          SizedBox(height: AppSpacing.small.h),
          _NeedRow(
            icon: Icons.place_outlined,
            title: 'Location',
            value: _plant.placeChip,
            iconColor: _CareTint.place,
          ),
          SizedBox(height: AppSpacing.medium.h),
          const _SectionLabel('Scientific Classifications'),
          SizedBox(height: AppSpacing.small.h),
          _ClassList(
            rows: [
              ('Order', _plant.order),
              ('Genus', _plant.genus),
              ('Family', _plant.family),
              ('Class', _plant.taxonClass),
            ],
          ),
          SizedBox(height: AppSpacing.medium.h),
          _OurToolsCard(
            onWater: _openWaterMeter,
            onChat: _openChat,
          ),
        ];
      case 2:
        return [
          _CultureBlock(
            icon: Icons.menu_book_outlined,
            title: 'Name Story',
            text: _plant.nameStory,
          ),
          SizedBox(height: AppSpacing.small.h),
          _CultureBlock(
            icon: Icons.yard_outlined,    
            title: 'Garden Use',
            text: _plant.gardenUse,
          ),
          SizedBox(height: AppSpacing.small.h),
          _CultureBlock(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Interesting Facts',
            text: _plant.interestingFacts,
          ),
          SizedBox(height: AppSpacing.small.h),
          _CultureBlock(
            icon: Icons.eco_outlined,
            title: 'Symbolism',
            text: _plant.symbolism,
          ),
        ];
      case 3:
        return [
          for (final item in _faqs) ...[
            _FaqTile(question: item.$1, answer: item.$2),
            SizedBox(height: AppSpacing.small.h),
          ],
        ];
      default:
        return [
          const _SectionLabel('Pests and Diseases'),
          SizedBox(height: AppSpacing.extraSmall.h),
          const CustomText(
            'Tap a photo to diagnose',
            fontSize: 12,
            color: AppColors.mutedText,
          ),
          SizedBox(height: AppSpacing.small.h),
          SizedBox(
            height: 118.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _plant.pests.length,
              separatorBuilder: (_, __) =>
                  SizedBox(width: AppSpacing.small.w),
              itemBuilder: (_, index) {
                final pest = _plant.pests[index];
                return _PestCard(
                  pest: pest,
                  onTap: () => _openPest(pest),
                );
              },
            ),
          ),
          SizedBox(height: AppSpacing.medium.h),
          const _SectionLabel('Articles'),
          SizedBox(height: AppSpacing.small.h),
          for (final article in _relatedArticles) ...[
            HorizontalContentCard(
              expand: true,
              imagePath: article.imagePath,
              eyebrow: article.category,
              title: article.title,
              actionLabel: 'Go to learn >',
              onTap: () => _openArticle(article),
              heroTag: article.imagePath,
            ),
            SizedBox(height: AppSpacing.small.h),
          ],
          const CustomText(
            'Is the information for this plant incorrect or inaccurate? Let us know when the library is connected.',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.mutedText,
          ),
        ];
    }
  }

  List<(String, String)> get _faqs => [
        ('How often should I water it?', _plant.waterNote),
        ('What light does it need?', _plant.lightNote),
        ('Is it safe for pets and kids?', _plant.toxicity.summary),
        ('What soil should I use?', _plant.soilNote),
      ];

  static final _relatedArticles = [
    SuggestionArticle.samples[3],
    SuggestionArticle.samples[4],
  ];
}

class _AlreadyInGardenNote extends StatelessWidget {
  const _AlreadyInGardenNote({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MyGardenController>()) {
      return const SizedBox.shrink();
    }
    return Obx(() {
      final inGarden =
          Get.find<MyGardenController>().hasPlantNamed(name);
      if (!inGarden) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(top: AppSpacing.medium.h),
        child: CustomContainer(
          color: AppColors.white,
          borderRadius: AppRadius.large,
          shadow: AppShadows.soft,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.medium.w,
            vertical: 10.h,
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 18.sp,
              ),
              SizedBox(width: AppSpacing.small.w),
              const CustomText(
                'Already in garden',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _NeedChip extends StatelessWidget {
  const _NeedChip({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.sageBackground,
      borderRadius: AppRadius.medium,
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14.sp),
          SizedBox(width: 6.w),
          CustomText(
            label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ],
      ),
    );
  }
}

class _SpecCard extends StatelessWidget {
  const _SpecCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            fontSize: 13,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 4.h),
          CustomText(
            value,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ],
      ),
    );
  }
}

class _ClassList extends StatelessWidget {
  const _ClassList({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium.w),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.medium.h),
              child: Row(
                children: [
                  CustomText(
                    rows[i].$1,
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                  const Spacer(),
                  CustomText(
                    rows[i].$2,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(height: 1.h, color: AppColors.divider),
          ],
        ],
      ),
    );
  }
}

class _NeedRow extends StatelessWidget {
  const _NeedRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            width: 40,
            height: 40,
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: AppRadius.circular,
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  value,
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PoisonCard extends StatelessWidget {
  const _PoisonCard({required this.poisonous});

  final bool poisonous;

  @override
  Widget build(BuildContext context) {
    final accent = poisonous ? AppColors.error : AppColors.success;
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium.w,
        vertical: 10.h,
      ),
      child: Row(
        children: [
          CustomContainer(
            width: 36,
            height: 36,
            color: accent.withValues(alpha: 0.1),
            borderRadius: AppRadius.medium,
            alignment: Alignment.center,
            child: Icon(
              poisonous ? Icons.dangerous_outlined : Icons.verified_outlined,
              color: accent,
              size: 18.sp,
            ),
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  poisonous ? 'Poisonous' : 'Generally safe',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                CustomText(
                  poisonous
                      ? 'Pets and kids — check before you bring it home'
                      : 'Pets and kids',
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextCareCard extends StatelessWidget {
  const _NextCareCard({
    required this.line,
    required this.season,
    required this.onTap,
  });

  final String line;
  final String season;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      pressScale: 0.98,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium.w,
        vertical: 10.h,
      ),
      child: Row(
        children: [
          CustomContainer(
            width: 36,
            height: 36,
            color: _CareTint.water.withValues(alpha: 0.12),
            borderRadius: AppRadius.medium,
            alignment: Alignment.center,
            child: Icon(
              Icons.opacity_outlined,
              color: _CareTint.water,
              size: 18.sp,
            ),
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  line,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                CustomText(
                  season,
                  fontSize: 12,
                  color: AppColors.mutedText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.small.w),
          CustomContainer(
            color: AppColors.primaryGreen.withValues(alpha: 0.12),
            borderRadius: AppRadius.medium,
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 6.h,
            ),
            child: const CustomText(
              'Meter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionBox extends StatelessWidget {
  const _AttentionBox();

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            width: 36,
            height: 36,
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: AppRadius.medium,
            alignment: Alignment.center,
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColors.error,
              size: 18.sp,
            ),
          ),
          SizedBox(width: AppSpacing.small.w),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  'Attention',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
                CustomText(
                  'Toxicity information may be subject to error. Do not use this app as the only source and do not eat a plant without consulting an expert.',
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryText,
      letterSpacing: -0.2,
    );
  }
}

class _SafetyFlag extends StatelessWidget {
  const _SafetyFlag({
    required this.icon,
    required this.label,
    required this.alert,
  });

  final IconData icon;
  final String label;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final color = alert ? AppColors.error : AppColors.success;
    return Expanded(
      child: CustomContainer(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.medium,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 6.w),
            Expanded(
              child: CustomText(
                label,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      clipBehavior: Clip.antiAlias,
      border: Border.all(color: AppColors.border),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: AppColors.primaryGreen.withValues(alpha: 0.08),
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: AppSpacing.medium.w),
          childrenPadding: EdgeInsets.fromLTRB(
            AppSpacing.medium.w,
            0,
            AppSpacing.medium.w,
            AppSpacing.medium.h,
          ),
          iconColor: AppColors.primaryGreen,
          collapsedIconColor: AppColors.mutedText,
          onExpansionChanged: (_) => HapticFeedback.selectionClick(),
          title: CustomText(
            question,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          children: [
            CustomText(
              answer,
              fontSize: 13,
              color: AppColors.secondaryText,
              height: 1.45,
            ),
          ],
        ),
      ),
    );
  }
}

class _OurToolsCard extends StatelessWidget {
  const _OurToolsCard({required this.onWater, required this.onChat});

  final VoidCallback onWater;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: AppColors.primaryGreen,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.medium.w,
                AppSpacing.medium.h,
                AppSpacing.medium.w,
                AppSpacing.medium.h,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    'Our Tools',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                  CustomText(
                    'Care tools for this plant',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ),
          _ToolRow(
            icon: Icons.opacity_outlined,
            title: 'Water Meter',
            subtitle: 'See who is due to drink',
            onTap: onWater,
            padded: true,
          ),
          Divider(height: 1.h, color: AppColors.divider),
          _ToolRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Ask Botanist',
            subtitle: 'Care questions about this plant',
            onTap: onChat,
            padded: true,
          ),
        ],
      ),
    );
  }
}

class _FunFactCard extends StatelessWidget {
  const _FunFactCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.celebration_outlined,
            color: AppColors.primaryGreen,
            size: 20.sp,
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  'Fun Fact',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text,
                  fontSize: 14,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CultureBlock extends StatelessWidget {
  const _CultureBlock({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 18.sp),
              SizedBox(width: AppSpacing.small.w),
              CustomText(
                title,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.small.h),
          CustomText(
            text,
            fontSize: 14,
            color: AppColors.secondaryText,
            height: 1.45,
          ),
        ],
      ),
    );
  }
}

class _PestCard extends StatelessWidget {
  const _PestCard({required this.pest, required this.onTap});

  final TrendingPest pest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      pressScale: 0.98,
      width: 96,
      height: 118,
      clipBehavior: Clip.none,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium.r),
              child: Image.asset(
                pest.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.extraSmall.h),
          CustomText(
            pest.title,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.padded = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      pressScale: 0.98,
      color: AppColors.white,
      borderRadius: padded ? 0 : AppRadius.large,
      shadow: padded ? null : AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        children: [
          CustomContainer(
            width: 40,
            height: 40,
            color: AppColors.sageBackground,
            borderRadius: AppRadius.circular,
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.primaryGreen, size: 20.sp),
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                CustomText(
                  subtitle,
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          if (padded)
            const CustomText(
              'Use',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            )
          else
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedText,
              size: 22.sp,
            ),
        ],
      ),
    );
  }
}
