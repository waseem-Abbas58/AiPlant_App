import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import 'garden_sheet.dart';

Future<int?> showLastWateredSheet(BuildContext context) {
  return showGardenSheet<int>(
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
              'Last watered',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
            SizedBox(height: AppSpacing.small.h),
            _LastWateredRow(
              label: 'Today',
              onTap: () => Navigator.of(context).pop(0),
            ),
            _LastWateredRow(
              label: 'Yesterday',
              onTap: () => Navigator.of(context).pop(1),
            ),
            _LastWateredRow(
              label: '2 days ago',
              onTap: () => Navigator.of(context).pop(2),
            ),
            _LastWateredRow(
              label: '3 days ago',
              onTap: () => Navigator.of(context).pop(3),
            ),
            _LastWateredRow(
              label: 'Not sure',
              onTap: () => Navigator.of(context).pop(-1),
            ),
          ],
        ),
      );
    },
  );
}

class _LastWateredRow extends StatelessWidget {
  const _LastWateredRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.medium.h),
      child: CustomText(
        label,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
    );
  }
}
