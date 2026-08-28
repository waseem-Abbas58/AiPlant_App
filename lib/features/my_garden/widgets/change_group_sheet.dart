import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../model/my_garden_model.dart';
import 'garden_sheet.dart';

Future<void> showChangeGroupSheet(
  BuildContext context, {
  required List<GardenGroup> groups,
  required String selectedId,
  required ValueChanged<String> onSelect,
}) {
  return showGardenSheet<void>(
    context: context,
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
              'Change Group',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              letterSpacing: -0.28,
            ),
            SizedBox(height: AppSpacing.small.h),
            for (final group in groups) ...[
              CustomContainer(
                onTap: () {
                  Navigator.of(context).pop();
                  onSelect(group.id);
                },
                padding: EdgeInsets.symmetric(vertical: AppSpacing.medium.h),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        group.title,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    if (group.id == selectedId)
                      Icon(
                        Icons.check_rounded,
                        size: 20.sp,
                        color: AppColors.primaryGreen,
                      ),
                  ],
                ),
              ),
              if (group.id != groups.last.id)
                Divider(color: AppColors.divider, height: 1.h),
            ],
          ],
        ),
      );
    },
  );
}
