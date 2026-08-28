import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/my_garden_controller.dart';
import 'garden_empty_state.dart';
import 'garden_sheet.dart';
import 'garden_task_card.dart';
import 'garden_week_calendar.dart';
import 'snooze_sheet.dart';

class GardenTasksTab extends StatefulWidget {
  const GardenTasksTab({super.key, required this.onAddPlant});

  final VoidCallback onAddPlant;

  @override
  State<GardenTasksTab> createState() => _GardenTasksTabState();
}

class _GardenTasksTabState extends State<GardenTasksTab> {
  final _garden = Get.find<MyGardenController>();

  Future<void> _openMonthYearPicker() async {
    var draft = _garden.selectedTaskDate.value;
    await showGardenSheet<void>(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 320.h,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.medium.w,
                  AppSpacing.medium.h,
                  AppSpacing.medium.w,
                  AppSpacing.small.h,
                ),
                child: Row(
                  children: [
                    CustomContainer(
                      onTap: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.small.w,
                        vertical: AppSpacing.extraSmall.h,
                      ),
                      child: const CustomText(
                        'Cancel',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const Expanded(
                      child: CustomText(
                        'Month & Year',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    CustomContainer(
                      onTap: () {
                        _garden.selectMonthYear(draft);
                        Navigator.of(context).pop();
                      },
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.small.w,
                        vertical: AppSpacing.extraSmall.h,
                      ),
                      child: const CustomText(
                        'Done',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.monthYear,
                  initialDateTime: _garden.selectedTaskDate.value,
                  minimumDate: MyGardenController.minTaskMonth,
                  maximumDate: DateTime(2035, 12, 31),
                  onDateTimeChanged: (value) => draft = value,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => GardenWeekCalendar(
            yearLabel: _garden.taskYearLabel,
            monthLabel: _garden.taskMonthShortLabel,
            dates: _garden.weekDates,
            selected: _garden.selectedTaskDate.value,
            today: _garden.today,
            hasTaskOn: _garden.hasTasksOn,
            canGoPrevious: _garden.canGoPreviousWeek,
            canGoNext: _garden.canGoNextWeek,
            onSelectDate: _garden.selectTaskDate,
            onOpenPicker: _openMonthYearPicker,
            onPreviousWeek: () => _garden.shiftWeek(-1),
            onNextWeek: () => _garden.shiftWeek(1),
          ),
        ),
        SizedBox(height: AppSpacing.medium.h),
        Expanded(
          child: Obx(() {
            final dayTasks = _garden.tasksForSelectedDate;
            final _ = _garden.plants.length;
            final __ = _garden.completedKeys.length;
            final ___ = _garden.selectedTaskDate.value;
            if (dayTasks.isEmpty) {
              final hasPlants = _garden.plants.isNotEmpty;
              return GardenEmptyState(
                illustration: const GardenTasksEmptyArt(),
                title: 'No tasks yet',
                subtitle: hasPlants
                    ? 'Nothing is scheduled for this day.'
                    : 'Add a plant to start a simple care routine.',
                actionLabel: 'Add Plant',
                filledAction: !hasPlants,
                onAction: hasPlants ? null : widget.onAddPlant,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  _garden.selectedTaskHeading,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  letterSpacing: -0.28,
                ),
                SizedBox(height: AppSpacing.small.h + 2.h),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.only(bottom: AppSpacing.small.h),
                    itemCount: dayTasks.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppSpacing.small.h),
                    itemBuilder: (context, index) {
                      final task = dayTasks[index];
                      return GardenTaskCard(
                        imagePath: task.imagePath,
                        title: task.title,
                        plantName: task.plantName,
                        timeLabel: task.timeLabel,
                        done: task.done,
                        isAssetImage: task.isAssetImage,
                        kind: task.kind,
                        onToggle: () => _garden.toggleTask(task),
                        onOpen: task.kind == 'water'
                            ? () {
                                final plant =
                                    _garden.plantById(task.plantId);
                                if (plant != null) {
                                  _garden.openWaterMeter(plantId: plant.id);
                                }
                              }
                            : null,
                        onSnooze: task.kind == 'water' && !task.done
                            ? () async {
                                final days = await showSnoozeSheet(context);
                                if (days == null) return;
                                final plant = _garden.plantById(task.plantId);
                                if (plant != null) {
                                  _garden.snoozeWater(plant, days);
                                }
                              }
                            : null,
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
