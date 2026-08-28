import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import 'garden_sheet.dart';

Future<void> showPlantMoreSheet(
  BuildContext context, {
  required VoidCallback onEditName,
  required VoidCallback onChangeGroup,
  required VoidCallback onAskBotanist,
  required VoidCallback onDelete,
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
          children: [
            CustomContainer(
              width: 36,
              height: 4,
              color: AppColors.divider,
              borderRadius: AppRadius.circular,
            ),
            SizedBox(height: AppSpacing.small.h),
            _MoreRow(
              icon: Icons.edit_outlined,
              label: 'Edit Name',
              onTap: () {
                Navigator.of(context).pop();
                onEditName();
              },
            ),
            Divider(color: AppColors.divider, height: 1.h),
            _MoreRow(
              icon: Icons.folder_outlined,
              label: 'Change Group',
              onTap: () {
                Navigator.of(context).pop();
                onChangeGroup();
              },
            ),
            Divider(color: AppColors.divider, height: 1.h),
            _MoreRow(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Ask Botanist',
              onTap: () {
                Navigator.of(context).pop();
                onAskBotanist();
              },
            ),
            Divider(color: AppColors.divider, height: 1.h),
            _MoreRow(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Plant',
              color: AppColors.error,
              onTap: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        ),
      );
    },
  );
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primaryText,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.medium.h),
      child: Row(
        children: [
          Icon(icon, size: 22.sp, color: color),
          SizedBox(width: AppSpacing.medium.w),
          CustomText(
            label,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }
}
