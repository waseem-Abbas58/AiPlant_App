import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_durations.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/my_garden_controller.dart';
import '../data/plant_care_engine.dart';
import '../model/my_garden_model.dart';
import '../widgets/garden_empty_state.dart';
import '../widgets/garden_filter_chip.dart';
import '../widgets/garden_plant_image.dart';
import '../widgets/garden_subpage_header.dart';
import '../widgets/last_watered_sheet.dart';
import '../widgets/snooze_sheet.dart';
import '../widgets/water_level_gauge.dart';
import '../widgets/water_status_chip.dart';

class WaterMeterView extends StatefulWidget {
  const WaterMeterView({super.key, this.plantId});

  final String? plantId;

  @override
  State<WaterMeterView> createState() => _WaterMeterViewState();
}

class _WaterMeterViewState extends State<WaterMeterView> {
  late String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.plantId;
  }

  GardenPlant? _plantFor(
    MyGardenController garden,
    List<GardenPlant> ranked,
  ) {
    final id = _selectedId;
    if (id != null) {
      return garden.plantById(id) ??
          (ranked.isEmpty ? null : ranked.first);
    }
    return ranked.isEmpty ? null : ranked.first;
  }

  @override
  Widget build(BuildContext context) {
    final garden = Get.isRegistered<MyGardenController>()
        ? Get.find<MyGardenController>()
        : null;

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
              const GardenSubpageHeader(title: 'Water Meter'),
              Expanded(
                child: garden == null
                    ? const SizedBox.shrink()
                    : Obx(() {
                        final ranked = PlantCareEngine.rankedForWater(
                          garden.plants.toList(),
                        );
                        if (ranked.isEmpty) {
                          return GardenEmptyState(
                            illustration: const GardenEmptyArt(),
                            title: 'No plants yet',
                            subtitle:
                                'Add a plant to set when and how much to water.',
                            actionLabel: 'Add a plant',
                            filledAction: true,
                            onAction: () => garden.openAddPlantSheet(context),
                          );
                        }
                        final plant = _plantFor(garden, ranked);
                        if (plant == null) {
                          return const SizedBox.shrink();
                        }
                        final dueCount = ranked
                            .where(
                              (item) => PlantCareEngine.waterDueOn(
                                item,
                                garden.today,
                              ),
                            )
                            .length;
                        return _MeterBody(
                          garden: garden,
                          plant: plant,
                          ranked: ranked,
                          dueCount: dueCount,
                          onSelect: (id) => setState(() => _selectedId = id),
                        );
                      }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeterBody extends StatelessWidget {
  const _MeterBody({
    required this.garden,
    required this.plant,
    required this.ranked,
    required this.dueCount,
    required this.onSelect,
  });

  final MyGardenController garden;
  final GardenPlant plant;
  final List<GardenPlant> ranked;
  final int dueCount;
  final ValueChanged<String> onSelect;

  String get _headline {
    final status = PlantCareEngine.waterStatus(plant);
    final next = garden.nextWaterLabel(plant);
    return switch (status) {
      PlantWaterStatus.fresh => 'Rested until $next',
      PlantWaterStatus.due => next == 'Today' ? 'Water today' : 'Water overdue',
      PlantWaterStatus.dry => 'Water soon · $next',
      PlantWaterStatus.ok => 'Next water $next',
    };
  }

  @override
  Widget build(BuildContext context) {
    final level = PlantCareEngine.moistureLevel(plant);
    final status = PlantCareEngine.waterStatus(plant);
    final interval = garden.waterIntervalFor(plant);
    final showPicker = ranked.length > 1;
    final justWatered = status == PlantWaterStatus.fresh;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium.w,
        AppSpacing.small.h,
        AppSpacing.medium.w,
        AppSpacing.large.h,
      ),
      children: [
        if (showPicker) ...[
          SizedBox(
            height: 102.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: ranked.length,
              separatorBuilder: (_, __) => SizedBox(width: AppSpacing.small.w),
              itemBuilder: (context, index) {
                final item = ranked[index];
                return _PlantPickChip(
                  plant: item,
                  selected: item.id == plant.id,
                  due: PlantCareEngine.waterDueOn(item, garden.today),
                  onTap: () => onSelect(item.id),
                );
              },
            ),
          ),
          if (dueCount >= 2) ...[
            SizedBox(height: AppSpacing.small.h),
            CustomContainer(
              onTap: () {
                HapticFeedback.mediumImpact();
                garden.markAllDueWatered();
              },
              pressScale: 0.98,
              color: AppColors.white,
              borderRadius: AppRadius.large,
              shadow: AppShadows.soft,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.small.h + 6.h),
              child: CustomText(
                'Water all due · $dueCount',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.medium.h),
        ],
        Center(
          child: Column(
            children: [
              CustomContainer(
                width: 56,
                height: 56,
                color: AppColors.white,
                borderRadius: AppRadius.circular,
                shadow: AppShadows.soft,
                clipBehavior: Clip.antiAlias,
                padding: EdgeInsets.all(3.w),
                child: ClipOval(
                  child: SizedBox.expand(
                    child: GardenPlantImage(
                      path: plant.imagePath,
                      isAsset: plant.isAssetImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.small.h),
              CustomText(
                plant.name,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
                textAlign: TextAlign.center,
              ),
              if (plant.displayScientific.isNotEmpty)
                CustomText(
                  plant.displayScientific,
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.large.h),
        Center(
          child: WaterLevelGauge(
            key: ValueKey(plant.id),
            level: level,
            centerLabel: '${PlantCareEngine.moisturePercent(plant)}%',
            centerSub: PlantCareEngine.daysLeftLabel(plant),
          ),
        ),
        SizedBox(height: AppSpacing.large.h),
        CustomContainer(
          color: AppColors.white,
          borderRadius: AppRadius.extraLarge,
          shadow: AppShadows.soft,
          padding: EdgeInsets.all(AppSpacing.medium.w),
          child: Column(
            children: [
              WaterStatusChip(status: status),
              SizedBox(height: AppSpacing.small.h + 4.h),
              CustomText(
                _headline,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
                textAlign: TextAlign.center,
                letterSpacing: -0.3,
              ),
              SizedBox(height: 4.h),
              CustomText(
                justWatered
                    ? 'Next pour · ${PlantCareEngine.waterAmountLabel(plant.care)}'
                    : 'Give ${PlantCareEngine.waterAmountLabel(plant.care)}',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.blue,
                textAlign: TextAlign.center,
              ),
              CustomText(
                'Every $interval days · ${PlantCareEngine.daysLeftLabel(plant)}',
                fontSize: 13,
                color: AppColors.secondaryText,
                textAlign: TextAlign.center,
              ),
              CustomText(
                PlantCareEngine.waterWhy(plant),
                fontSize: 13,
                color: AppColors.secondaryText,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.medium.h),
              CustomContainer(
                onTap: () async {
                  final days = await showLastWateredSheet(context);
                  if (days == null) return;
                  garden.setLastWateredDaysAgo(plant, days);
                },
                color: AppColors.sageBackground,
                borderRadius: AppRadius.large,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.medium.w,
                  vertical: AppSpacing.small.h + 2.h,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 18.sp,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(width: AppSpacing.small.w),
                    Expanded(
                      child: CustomText(
                        'Last watered · ${garden.lastWateredLabel(plant)}',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18.sp,
                      color: AppColors.mutedText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.medium.h),
        const CustomText(
          'How much',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.secondaryText,
        ),
        SizedBox(height: AppSpacing.small.h),
        Wrap(
          spacing: AppSpacing.small.w,
          runSpacing: AppSpacing.small.h,
          children: [
            for (final amount in GardenCareSchedule.waterAmounts)
              GardenFilterChip(
                label:
                    '$amount · ${PlantCareEngine.waterAmountMl(plant.care.copyWith(waterAmount: amount))} ml',
                selected: plant.care.waterAmount == amount,
                onTap: () => garden.updateCare(
                  plant,
                  plant.care.copyWith(waterAmount: amount),
                ),
              ),
          ],
        ),
        if (!justWatered) ...[
          SizedBox(height: AppSpacing.medium.h),
          CustomContainer(
            color: AppColors.white,
            borderRadius: AppRadius.large,
            shadow: AppShadows.soft,
            padding: EdgeInsets.all(AppSpacing.medium.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.front_hand_outlined,
                  size: 20.sp,
                  color: AppColors.primaryGreen,
                ),
                SizedBox(width: AppSpacing.small.w),
                const Expanded(
                  child: CustomText(
                    'Finger check · 2cm down. Dry? Water. Damp? Wait.',
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.large.h),
          CustomButton(
            text: 'I watered',
            backgroundColor: AppColors.primaryGreen,
            textColor: AppColors.white,
            leadingIcon: Icon(
              Icons.water_drop_rounded,
              color: AppColors.white,
              size: 18.sp,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              garden.markWatered(plant);
            },
          ),
          SizedBox(height: AppSpacing.small.h),
          CustomContainer(
            onTap: () async {
              final days = await showSnoozeSheet(context);
              if (days == null) return;
              garden.snoozeWater(plant, days);
            },
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.small.h + 4.h),
            child: CustomText(
              'Still moist?',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ],
    );
  }
}

class _PlantPickChip extends StatelessWidget {
  const _PlantPickChip({
    required this.plant,
    required this.selected,
    required this.due,
    required this.onTap,
  });

  final GardenPlant plant;
  final bool selected;
  final bool due;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final level = PlantCareEngine.moistureLevel(plant);
    final fill = Color.lerp(AppColors.warning, AppColors.blue, level) ??
        AppColors.blue;

    return CustomContainer(
      onTap: onTap,
      pressScale: 0.97,
      width: 76,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: selected ? AppShadows.medium : AppShadows.soft,
      border: Border.all(
        color: selected ? AppColors.primaryGreen : Colors.transparent,
        width: 1.5,
      ),
      padding: EdgeInsets.fromLTRB(
        6.w,
        6.h,
        6.w,
        6.h,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 44.h,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.medium.r),
                    child: GardenPlantImage(
                      path: plant.imagePath,
                      isAsset: plant.isAssetImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (due)
                  Positioned(
                    top: 4.h,
                    right: 4.w,
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.circular.r),
            child: SizedBox(
              height: 4.h,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      const ColoredBox(
                        color: AppColors.sageBackground,
                        child: SizedBox.expand(),
                      ),
                      AnimatedContainer(
                        duration: AppDurations.normal,
                        curve: Curves.easeOutCubic,
                        width: constraints.maxWidth * level.clamp(0.08, 1),
                        color: fill,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 4.h),
          CustomText(
            plant.name,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? AppColors.primaryGreen : AppColors.primaryText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
