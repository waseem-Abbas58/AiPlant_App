import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/my_garden_controller.dart';
import 'next_care_card.dart';
import 'snooze_sheet.dart';

class DailyCareSummary extends StatelessWidget {
  const DailyCareSummary({super.key, required this.garden});

  final MyGardenController garden;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final streak = garden.careStreak.value;
      final remaining = garden.dailyRemaining;
      final next = garden.nextAction;
      final caughtUp = remaining == 0;

      return CustomContainer(
        color: AppColors.white,
        borderRadius: AppRadius.large,
        shadow: AppShadows.soft,
        padding: EdgeInsets.all(AppSpacing.small.w + 2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 18.sp,
                  color: streak > 0 ? AppColors.warning : AppColors.mutedText,
                ),
                SizedBox(width: 4.w),
                CustomText(
                  streak > 0 ? '$streak-day streak' : 'No streak yet',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                const Spacer(),
                CustomText(
                  caughtUp
                      ? 'Caught up'
                      : remaining == 1
                          ? '1 left today'
                          : '$remaining left today',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: caughtUp
                      ? AppColors.primaryGreen
                      : AppColors.secondaryText,
                ),
              ],
            ),
            if (caughtUp) ...[
              SizedBox(height: AppSpacing.small.h),
              const CustomText(
                'All care for today is done.',
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ] else if (next != null && next.kind == 'water') ...[
              SizedBox(height: AppSpacing.small.h),
              NextCareCard(
                imagePath: next.imagePath,
                isAssetImage: next.isAssetImage,
                title: 'Water ${next.plantName}',
                subtitle: next.timeLabel,
                embedded: true,
                onWatered: () {
                  final plant = garden.plantById(next.plantId);
                  if (plant != null) garden.markWatered(plant);
                },
                onSnooze: () async {
                  final days = await showSnoozeSheet(context);
                  if (days == null) return;
                  final plant = garden.plantById(next.plantId);
                  if (plant != null) garden.snoozeWater(plant, days);
                },
                onTap: () {
                  final plant = garden.plantById(next.plantId);
                  if (plant != null) {
                    garden.openWaterMeter(plantId: plant.id);
                  }
                },
              ),
            ] else if (next != null) ...[
              SizedBox(height: AppSpacing.small.h),
              CustomText(
                '${next.title} ${next.plantName}',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ],
          ],
        ),
      );
    });
  }
}
