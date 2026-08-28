import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import 'garden_sheet.dart';

Future<void> showAddPlantSheet(
  BuildContext context, {
  VoidCallback? onTakePhoto,
  VoidCallback? onChooseGallery,
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
              ),
            ),
            SizedBox(height: AppSpacing.medium.h),
            const CustomText( 
              'Add Plant',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              letterSpacing: -0.28,
            ),
            SizedBox(height: AppSpacing.small.h),
            _AddPlantRow(
              icon: Icons.photo_camera_outlined,
              title: 'Take a Photo',
              subtitle: 'Snap your plant for the garden',
              onTap: () {
                Navigator.of(context).pop();
                onTakePhoto?.call();
              },
            ), 
            Divider(color: AppColors.divider, height: 1.h),
            _AddPlantRow(
              icon: Icons.photo_outlined,
              title: 'Choose from Gallery',
              subtitle: 'Pick a photo from your library',
              onTap: () {
                Navigator.of(context).pop();
                onChooseGallery?.call();
              },
            ),
          ],
        ),
      );
    },
  );
}

class _AddPlantRow extends StatelessWidget {
  const _AddPlantRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.medium.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryText, size: 24.sp),
          SizedBox(width: AppSpacing.medium.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                CustomText(
                  subtitle,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
