import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class GardenWeekCalendar extends StatelessWidget {
  const GardenWeekCalendar({
    super.key,
    required this.yearLabel,
    required this.monthLabel,
    required this.dates,
    required this.selected,
    required this.today,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onSelectDate,
    required this.onOpenPicker,
    required this.onPreviousWeek,
    required this.onNextWeek,
    this.hasTaskOn,
  });

  final String yearLabel;
  final String monthLabel;
  final List<DateTime> dates;
  final DateTime selected;
  final DateTime today;
  final bool canGoPrevious;
  final bool canGoNext;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onOpenPicker;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final bool Function(DateTime date)? hasTaskOn;

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.small.w,
        AppSpacing.medium.h,
        AppSpacing.small.w,
        AppSpacing.medium.h,
      ),
      child: Row(
        children: [
          CustomContainer(
            onTap: onOpenPicker,
            padding: EdgeInsets.only(left: 4.w, right: 8.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  yearLabel,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                ),
                CustomText(
                  monthLabel,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  letterSpacing: -0.28,
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -180 && canGoNext) onNextWeek();
                if (velocity > 180 && canGoPrevious) onPreviousWeek();
              },
              child: Row(
                children: [
                  for (final date in dates)
                    Expanded(
                      child: _WeekDayCell(
                        date: date,
                        selected: _isSameDay(date, selected),
                        isToday: _isSameDay(date, today),
                        hasTask: hasTaskOn?.call(date) ?? false,
                        onTap: () => onSelectDate(date),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekDayCell extends StatelessWidget {
  const _WeekDayCell({
    required this.date,
    required this.selected,
    required this.isToday,
    required this.hasTask,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool isToday;
  final bool hasTask;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final letter = DateFormat('EEE').format(date).toUpperCase();
    final letterColor = selected
        ? AppColors.primaryGreen
        : AppColors.mutedText;
    final numberColor = selected
        ? AppColors.white
        : isToday
            ? AppColors.primaryGreen
            : AppColors.secondaryText;

    return CustomContainer(
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: CustomText(
              letter,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: letterColor,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 6.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryGreen : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !selected
                  ? Border.all(color: AppColors.primaryGreen, width: 1.2)
                  : null,
            ),
            child: CustomText(
              '${date.day}',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: numberColor,
            ),
          ),
          SizedBox(height: 4.h),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: hasTask ? 1 : 0,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryGreen : AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
