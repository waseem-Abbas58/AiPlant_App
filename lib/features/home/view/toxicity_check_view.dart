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
import '../../../shared/widgets/custom_search_field.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../main_navigation/controller/main_navigation_controller.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';
import '../../plant_scan/controller/plant_scan_controller.dart';
import '../../plant_scan/model/plant_identify_result.dart';
import '../../plant_scan/widgets/toxicity_sheet.dart';

class ToxicityCheckView extends StatefulWidget {
  const ToxicityCheckView({super.key});

  @override
  State<ToxicityCheckView> createState() => _ToxicityCheckViewState();
}

class _ToxicityCheckViewState extends State<ToxicityCheckView> {
  var _query = '';

  static const _plants = <_ToxicityPlant>[
    _ToxicityPlant(
      name: 'Snake Plant',
      scientific: 'Dracaena trifasciata',
      imageAsset: 'assets/images/home/trending/trending_snake_plant.png',
      toxicity: PlantToxicity(
        toxicToPets: true,
        toxicToKids: true,
        summary:
            'Mildly toxic if chewed — keep away from pets and small children.',
        petsDetail:
            'Can irritate cats and dogs if leaves are chewed. Call a vet if they eat any.',
        kidsDetail: 'Sap can irritate skin and mouths. Wash hands after pruning.',
      ),
    ),
    _ToxicityPlant(
      name: 'Peace Lily',
      scientific: 'Spathiphyllum wallisii',
      imageAsset: 'assets/images/home/trending/trending_peace_lily.png',
      toxicity: PlantToxicity(
        toxicToPets: true,
        toxicToKids: true,
        summary: 'Contains calcium oxalate. Not a snack for pets or kids.',
        petsDetail: 'Chewing can cause drooling and mouth pain in cats and dogs.',
        kidsDetail: 'Keep berries and leaves out of reach. Wash hands after handling.',
      ),
    ),
    _ToxicityPlant(
      name: 'Monstera',
      scientific: 'Monstera deliciosa',
      imageAsset: 'assets/images/home/trending/trending_monstera.png',
      toxicity: PlantToxicity(
        toxicToPets: true,
        toxicToKids: true,
        summary: 'Leaves are irritating if chewed. Ripe fruit is a different story.',
        petsDetail: 'Keep cats and dogs from chewing the leaves.',
        kidsDetail: 'Unripe fruit and sap can irritate. Supervise around the plant.',
      ),
    ),
    _ToxicityPlant(
      name: 'Aloe',
      scientific: 'Aloe vera',
      imageAsset: 'assets/images/home/trending/trending_aloe.png',
      toxicity: PlantToxicity(
        toxicToPets: true,
        toxicToKids: false,
        summary: 'The latex is risky for pets. Inner gel is used on skin, not as food.',
        petsDetail: 'The yellow latex can upset a cat or dog’s stomach.',
        kidsDetail: 'Not a snack. Gel on a scrape is fine; don’t let them eat the leaf.',
      ),
    ),
    _ToxicityPlant(
      name: 'Jade',
      scientific: 'Crassula ovata',
      imageAsset: 'assets/images/home/trending/trending_jade.png',
      toxicity: PlantToxicity(
        toxicToPets: true,
        toxicToKids: false,
        summary: 'Mildly toxic to pets if chewed. Usually safe around kids.',
        petsDetail: 'Can cause vomiting in cats and dogs if they eat the leaves.',
        kidsDetail: 'Not typically a kids hazard. Still don’t let them nibble plants.',
      ),
    ),
    _ToxicityPlant(
      name: 'Orchid',
      scientific: 'Phalaenopsis',
      imageAsset: 'assets/images/home/trending/trending_orchid.png',
      toxicity: PlantToxicity(
        toxicToPets: false,
        toxicToKids: false,
        summary: 'Phalaenopsis orchids are generally non-toxic to pets and kids.',
        petsDetail: 'A nibble is unlikely to poison a cat or dog.',
        kidsDetail: 'Not considered toxic. Still keep soil and pots off the floor.',
      ),
    ),
    _ToxicityPlant(
      name: 'Fiddle Leaf Fig',
      scientific: 'Ficus lyrata',
      imageAsset: 'assets/images/home/trending/trending_fiddle_leaf.png',
      toxicity: PlantToxicity(
        toxicToPets: true,
        toxicToKids: true,
        summary: 'Sap and leaves can irritate pets and kids if chewed.',
        petsDetail: 'Keep cats and dogs from chewing the large leaves.',
        kidsDetail: 'Sap can irritate skin. Wash hands after wiping dust.',
      ),
    ),
    _ToxicityPlant(
      name: 'Rubber Plant',
      scientific: 'Ficus elastica',
      imageAsset: 'assets/images/home/trending/trending_rubber_plant.png',
      toxicity: PlantToxicity(
        toxicToPets: true,
        toxicToKids: true,
        summary: 'The milky sap is irritating. Not a chew toy.',
        petsDetail: 'Can upset a cat or dog if they chew the leaves.',
        kidsDetail: 'Sap can irritate skin and eyes. Wipe with gloves.',
      ),
    ),
  ];

  List<_ToxicityPlant> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _plants;
    return _plants
        .where(
          (plant) =>
              plant.name.toLowerCase().contains(q) ||
              plant.scientific.toLowerCase().contains(q),
        )
        .toList();
  }

  void _openScan() {
    NavigationHelper.back();
    if (Get.isRegistered<PlantScanController>()) {
      Get.find<PlantScanController>().selectCategory(0, toxicity: true);
    }
    if (!Get.isRegistered<MainNavigationController>()) return;
    Get.find<MainNavigationController>()
        .onTabTapped(MainNavigationController.scanIndex);
  }

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
              const GardenSubpageHeader(title: 'Toxicity'),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                    AppSpacing.medium.w,
                    AppSpacing.large.h,
                  ),
                  children: [
                    const CustomText(
                      'Check a plant before you bring it home. Preview list · library when connected.',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(height: AppSpacing.medium.h),
                    CustomSearchField(
                      hintText: 'Search a plant name',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    SizedBox(height: AppSpacing.medium.h),
                    Row(
                      children: [
                        Expanded(
                          child: _WhoChip(
                            icon: Icons.pets_rounded,
                            label: 'Pets',
                            onTap: _openScan,
                          ),
                        ),
                        SizedBox(width: AppSpacing.small.w),
                        Expanded(
                          child: _WhoChip(
                            icon: Icons.child_care_rounded,
                            label: 'Kids',
                            onTap: _openScan,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.large.h),
                    const CustomText(
                      'Common plants',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                    SizedBox(height: AppSpacing.small.h),
                    if (_visible.isEmpty)
                      const CustomText(
                        'No plant by that name · try Scan a plant',
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      )
                    else
                      for (final plant in _visible) ...[
                        _PlantRow(
                          plant: plant,
                          onTap: () => ToxicitySheet.show(
                            context,
                            toxicity: plant.toxicity,
                            plantName: plant.name,
                          ),
                        ),
                        SizedBox(height: AppSpacing.small.h),
                      ],
                  ],
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
                  text: 'Scan a plant',
                  backgroundColor: AppColors.primaryGreen,
                  textColor: AppColors.white,
                  onPressed: _openScan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToxicityPlant {
  const _ToxicityPlant({
    required this.name,
    required this.scientific,
    required this.imageAsset,
    required this.toxicity,
  });

  final String name;
  final String scientific;
  final String imageAsset;
  final PlantToxicity toxicity;
}

class _WhoChip extends StatelessWidget {
  const _WhoChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium.w,
        vertical: AppSpacing.medium.h,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22.sp, color: AppColors.primaryGreen),
          SizedBox(width: AppSpacing.small.w),
          CustomText(
            label,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ],
      ),
    );
  }
}

class _PlantRow extends StatelessWidget {
  const _PlantRow({required this.plant, required this.onTap});

  final _ToxicityPlant plant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.small.w),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium.r),
            child: Image.asset(
              plant.imageAsset,
              width: 64.w,
              height: 64.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: AppSpacing.medium.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  plant.name,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                CustomText(
                  plant.scientific,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          _Flag(
            icon: Icons.pets_rounded,
            risk: plant.toxicity.toxicToPets,
          ),
          SizedBox(width: 8.w),
          _Flag(
            icon: Icons.child_care_rounded,
            risk: plant.toxicity.toxicToKids,
          ),
        ],
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag({required this.icon, required this.risk});

  final IconData icon;
  final bool risk;

  @override
  Widget build(BuildContext context) {
    final color = risk ? AppColors.error : AppColors.primaryGreen;
    return CustomContainer(
      width: 36,
      height: 36,
      color: color.withValues(alpha: 0.12),
      borderRadius: AppRadius.circular,
      alignment: Alignment.center,
      child: Icon(icon, size: 18.sp, color: color),
    );
  }
}
