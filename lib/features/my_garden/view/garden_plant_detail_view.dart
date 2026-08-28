import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../chatbot/data/botanist_navigator.dart';
import '../../chatbot/widgets/ask_ai_fab.dart';
import '../controller/my_garden_controller.dart';
import '../data/plant_care_engine.dart';
import '../model/my_garden_model.dart';
import '../widgets/edit_care_task_sheet.dart';
import '../widgets/garden_hero.dart';
import '../widgets/garden_plant_image.dart';
import '../widgets/snooze_sheet.dart';
import 'garden_plant_settings_view.dart';

class GardenPlantDetailView extends StatelessWidget {
  const GardenPlantDetailView({super.key, required this.plantId});

  final String plantId;

  @override
  Widget build(BuildContext context) {
    final garden = Get.find<MyGardenController>();

    return Obx(() {
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

      return Scaffold(
        backgroundColor: AppColors.sageBackground,
        floatingActionButton: AskAiFab(
          semanticsLabel: 'Ask about ${current.name}',
          onTap: () => openBotanistChat(
            plantName: current.name,
            imagePath: current.imagePath,
            isAssetImage: current.isAssetImage,
            plantId: current.id,
          ),
        ),
        body: _PlantDetailScroll(plant: current, garden: garden),
      );
    });
  }
}

class _PlantDetailScroll extends StatefulWidget {
  const _PlantDetailScroll({required this.plant, required this.garden});

  final GardenPlant plant;
  final MyGardenController garden;

  @override
  State<_PlantDetailScroll> createState() => _PlantDetailScrollState();
}

class _PlantDetailScrollState extends State<_PlantDetailScroll> {
  var _collapsed = false;

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final next = notification.metrics.pixels >= 280.h;
    if (next != _collapsed) setState(() => _collapsed = next);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;
    final garden = widget.garden;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _collapsed
          ? const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            )
          : const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 400.h,
              pinned: true,
              stretch: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              forceMaterialTransparency: !_collapsed,
              backgroundColor: AppColors.sageBackground,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              centerTitle: true,
              titleSpacing: 8.w,
              title: AnimatedOpacity(
                opacity: _collapsed ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: CustomText(
                  plant.name,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              leadingWidth: 56.w,
              leading: Padding(
                padding: EdgeInsets.only(left: AppSpacing.medium.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _HeroButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: NavigationHelper.back,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: AppSpacing.medium.w),
                  child: _HeroButton(
                    icon: Icons.settings_outlined,
                    onTap: () {
                      NavigationHelper.to(
                        () => GardenPlantSettingsView(plantId: plant.id),
                      );
                    },
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                stretchModes: const [StretchMode.zoomBackground],
                background: Hero(
                  tag: gardenPhotoHeroTag(plant.imagePath),
                  child: Material(
                    type: MaterialType.transparency,
                    child: GardenPlantImage(
                      path: plant.imagePath,
                      isAsset: plant.isAssetImage,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: Offset(0, -24.h),
                child: _Body(plant: plant, garden: garden),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      width: 36,
      height: 36,
      color: AppColors.white.withValues(alpha: 0.94),
      borderRadius: AppRadius.circular,
      alignment: Alignment.center,
      child: Icon(icon, size: 18.sp, color: AppColors.primaryText),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.plant, required this.garden});

  final GardenPlant plant;
  final MyGardenController garden;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.sageBackground,
      borderRadius: AppRadius.extraLarge,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium.w,
        AppSpacing.large.h,
        AppSpacing.medium.w,
        40.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            plant.name,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
            letterSpacing: -0.5,
          ),
          if (plant.displayScientific.isNotEmpty) ...[
            SizedBox(height: 4.h),
            CustomText(
              plant.displayScientific,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
            ),
          ],
          SizedBox(height: 6.h),
          CustomText(
            garden.careLabelFor(plant),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryGreen,
          ),
          if (PlantCareEngine.waterDueOn(plant, garden.today)) ...[
            SizedBox(height: AppSpacing.medium.h),
            Row(
              children: [
                Expanded(
                  child: CustomContainer(
                    onTap: () => garden.markWatered(plant),
                    color: AppColors.primaryGreen,
                    borderRadius: AppRadius.medium,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    child: const CustomText(
                      'I watered',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.small.w),
                CustomContainer(
                  onTap: () async {
                    final days = await showSnoozeSheet(context);
                    if (days != null) garden.snoozeWater(plant, days);
                  },
                  color: AppColors.white,
                  borderRadius: AppRadius.medium,
                  shadow: AppShadows.soft,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  child: Icon(
                    Icons.snooze_rounded,
                    color: AppColors.primaryText,
                    size: 22.sp,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: AppSpacing.large.h),
          CustomContainer(
            color: AppColors.white,
            borderRadius: AppRadius.extraLarge,
            shadow: AppShadows.soft,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.small.w,
              vertical: AppSpacing.medium.h,
            ),
            child: Row(
              children: [
                _CareAction(
                  icon: Icons.water_drop_outlined,
                  label: 'Water',
                  subtitle: garden.nextWaterLabel(plant),
                  onTap: () => garden.openWaterMeter(plantId: plant.id),
                ),
                _CareAction(
                  icon: Icons.waves_outlined,
                  label: 'Mist',
                  subtitle: '${plant.care.mistDays}d',
                  onTap: () => garden.openCareTaskEditor(
                    context,
                    plant,
                    GardenCareKind.mist,
                  ),
                ),
                _CareAction(
                  icon: Icons.science_outlined,
                  label: 'Feed',
                  subtitle: '${plant.care.fertilizerMonths}mo',
                  onTap: () => garden.openCareTaskEditor(
                    context,
                    plant,
                    GardenCareKind.fertilizer,
                  ),
                ),
                _CareAction(
                  icon: Icons.rotate_right_outlined,
                  label: 'Rotate',
                  subtitle: '${plant.care.rotateMonths}mo',
                  onTap: () => garden.openCareTaskEditor(
                    context,
                    plant,
                    GardenCareKind.rotate,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.extraLarge.h),
          const CustomText(
            'Care details',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
            letterSpacing: -0.28,
          ),
          SizedBox(height: AppSpacing.small.h),
          _NeedRow(
            icon: Icons.wb_sunny_outlined,
            title: 'Sunlight',
            value: '${plant.care.lightLevel} light',
            onTap: () => NavigationHelper.to(
              () => GardenPlantSettingsView(plantId: plant.id),
            ),
          ),
          SizedBox(height: AppSpacing.small.h),
          _NeedRow(
            icon: Icons.opacity_outlined,
            title: 'Water',
            value: 'Every ${garden.waterIntervalFor(plant)} days',
          ),
          SizedBox(height: AppSpacing.small.h),
          _NeedRow(
            icon: Icons.place_outlined,
            title: 'Location',
            value: plant.care.location,
          ),
          SizedBox(height: AppSpacing.small.h),
          _NeedRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Ask Botanist',
            value: 'Care questions about this plant',
            onTap: () => openBotanistChat(
              plantName: plant.name,
              imagePath: plant.imagePath,
              isAssetImage: plant.isAssetImage,
              plantId: plant.id,
            ),
          ),
          SizedBox(height: AppSpacing.extraLarge.h),
          const CustomText(
            'Notes',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
            letterSpacing: -0.28,
          ),
          SizedBox(height: AppSpacing.small.h),
          _Notes(plant: plant),
          SizedBox(height: AppSpacing.extraLarge.h),
          _GrowthDiary(plant: plant, garden: garden),
        ],
      ),
    );
  }
}

class _GrowthDiary extends StatelessWidget {
  const _GrowthDiary({required this.plant, required this.garden});

  final GardenPlant plant;
  final MyGardenController garden;

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return DateFormat('d MMM y').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entries = garden.diaryFor(plant.id);

      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: CustomText(
                'Growth diary',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
                letterSpacing: -0.28,
              ),
            ),
            CustomContainer(
              onTap: () => garden.addDiaryPhoto(plant),
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              borderRadius: AppRadius.circular,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.medium.w,
                vertical: 6.h,
              ),
              child: const CustomText(
                'Add photo',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.small.h),
        if (entries.isEmpty)
          CustomContainer(
            color: AppColors.white,
            borderRadius: AppRadius.large,
            shadow: AppShadows.soft,
            padding: EdgeInsets.all(AppSpacing.medium.w),
            child: const CustomText(
              'Add a photo to track how this plant grows.',
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          )
        else
          ...entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.small.h),
              child: CustomContainer(
                color: AppColors.white,
                borderRadius: AppRadius.large,
                shadow: AppShadows.soft,
                padding: EdgeInsets.all(AppSpacing.small.w + 2.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GardenPlantImage(
                      path: entry.imagePath,
                      isAsset: entry.isAssetImage,
                      width: 72.w,
                      height: 72.w,
                      borderRadius: BorderRadius.circular(AppRadius.medium.r),
                    ),
                    SizedBox(width: AppSpacing.small.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            _dateLabel(entry.createdAt),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                          if (entry.note.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            CustomText(
                              entry.note,
                              fontSize: 13,
                              color: AppColors.secondaryText,
                            ),
                          ],
                        ],
                      ),
                    ),
                    CustomContainer(
                      onTap: () => garden.deleteDiaryEntry(entry),
                      padding: EdgeInsets.all(AppSpacing.extraSmall.w),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 20.sp,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
    });
  }
}

class _CareAction extends StatelessWidget {
  const _CareAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomContainer(
        onTap: onTap,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.small.h),
        child: Column(
          children: [
            CustomContainer(
              width: 56,
              height: 56,
              color: AppColors.sageBackground,
              borderRadius: AppRadius.circular,
              alignment: Alignment.center,
              child: Icon(icon, size: 24.sp, color: AppColors.primaryGreen),
            ),
            SizedBox(height: 8.h),
            CustomText(
              label,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
            CustomText(
              subtitle,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

class _NeedRow extends StatelessWidget {
  const _NeedRow({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        children: [
          CustomContainer(
            width: 40,
            height: 40,
            color: AppColors.sageBackground,
            borderRadius: AppRadius.medium,
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
                  value,
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          if (onTap != null)
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

class _Notes extends StatefulWidget {
  const _Notes({required this.plant});

  final GardenPlant plant;

  @override
  State<_Notes> createState() => _NotesState();
}

class _NotesState extends State<_Notes> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.plant.notes);
  }

  @override
  void dispose() {
    if (Get.isRegistered<MyGardenController>()) {
      final garden = Get.find<MyGardenController>();
      garden.updatePlant(widget.plant.copyWith(notes: _controller.text));
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: TextField(
        controller: _controller,
        maxLines: 5,
        cursorColor: AppColors.primaryGreen,
        style: TextStyle(
          fontSize: 15.sp,
          color: AppColors.primaryText,
          height: 1.4,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          filled: false,
          isCollapsed: true,
          hintText: 'Write a note for this plant…',
        ),
      ),
    );
  }
}
