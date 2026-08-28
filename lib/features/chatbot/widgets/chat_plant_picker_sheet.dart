import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../my_garden/model/my_garden_model.dart';
import '../../my_garden/widgets/garden_plant_image.dart';
import '../../my_garden/widgets/garden_sheet.dart';

Future<GardenPlant?> showChatPlantPicker(
  BuildContext context, {
  required List<GardenPlant> plants,
}) {
  return showGardenSheet<GardenPlant>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.large.w,
          AppSpacing.small.h,
          AppSpacing.large.w,
          AppSpacing.large.h + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CustomContainer(
                width: 36,
                height: 4,
                color: AppColors.divider,
                borderRadius: AppRadius.circular,
              ),
            ),
            SizedBox(height: AppSpacing.medium.h),
            const CustomText(
              'Ask about a plant',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              letterSpacing: -0.28,
            ),
            SizedBox(height: AppSpacing.small.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 360.h),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: plants.length,
                separatorBuilder: (_, __) =>
                    Divider(color: AppColors.divider, height: 1.h),
                itemBuilder: (context, index) {
                  final plant = plants[index];
                  return CustomContainer(
                    onTap: () => Navigator.of(context).pop(plant),
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.small.h),
                    child: Row(
                      children: [
                        GardenPlantImage(
                          path: plant.imagePath,
                          isAsset: plant.isAssetImage,
                          width: 44.w,
                          height: 44.w,
                          borderRadius: BorderRadius.circular(AppRadius.medium.r),
                        ),
                        SizedBox(width: AppSpacing.medium.w),
                        Expanded(
                          child: CustomText(
                            plant.name,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.mutedText,
                          size: 22.sp,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
