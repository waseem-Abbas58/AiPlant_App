import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class GardenEmptyState extends StatelessWidget {
  const GardenEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.icon,
    this.illustration,
    this.onAction,
    this.filledAction = false,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData? icon;
  final Widget? illustration;
  final VoidCallback? onAction;
  final bool filledAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.large.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          illustration ??
              Icon(
                icon ?? Icons.local_florist_outlined,
                size: 56.sp,
                color: AppColors.mutedText,
              ),
          SizedBox(height: AppSpacing.large.h),
          CustomText(
            title,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
            textAlign: TextAlign.center,
            letterSpacing: -0.4,
          ),
          SizedBox(height: AppSpacing.small.h),
          CustomText(
            subtitle,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.secondaryText,
            textAlign: TextAlign.center,
            height: 1.4,
          ),
          if (onAction != null) ...[
            SizedBox(height: AppSpacing.large.h),
            CustomContainer(
              onTap: onAction,
              color: filledAction ? AppColors.primaryGreen : AppColors.white,
              borderRadius: AppRadius.circular,
              shadow: filledAction ? AppShadows.soft : null,
              border: filledAction
                  ? null
                  : Border.all(color: AppColors.primaryGreen),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.extraLarge.w,
                vertical: AppSpacing.small.h + 6.h,
              ),
              child: CustomText(
                actionLabel,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: filledAction ? AppColors.white : AppColors.primaryGreen,
              ),
            ),
          ],
          if (secondaryLabel != null && onSecondary != null) ...[
            SizedBox(height: AppSpacing.small.h),
            CustomContainer(
              onTap: onSecondary,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.medium.w,
                vertical: AppSpacing.small.h,
              ),
              child: CustomText(
                secondaryLabel!,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GardenTasksEmptyArt extends StatelessWidget {
  const GardenTasksEmptyArt({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      width: 88,
      height: 88,
      color: AppColors.white,
      borderRadius: AppRadius.circular,
      shadow: AppShadows.diffused,
      alignment: Alignment.center,
      child: Icon(
        Icons.notifications_none_rounded,
        size: 36.sp,
        color: AppColors.primaryGreen.withValues(alpha: 0.7),
      ),
    );
  }
}

class GardenEmptyArt extends StatelessWidget {
  const GardenEmptyArt({super.key});

  static const _photos = [
    'assets/images/home/trending/trending_monstera.png',
    'assets/images/home/trending/trending_snake_plant.png',
    'assets/images/home/trending/trending_peace_lily.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112.h,
      width: 176.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _photo(_photos[0], offset: Offset(-38.w, 8.h), size: 72),
          _photo(_photos[2], offset: Offset(38.w, 8.h), size: 72),
          _photo(_photos[1], offset: Offset.zero, size: 88),
        ],
      ),
    );
  }

  Widget _photo(String path, {required Offset offset, required double size}) {
    return Transform.translate(
      offset: offset,
      child: CustomContainer(
        width: size,
        height: size,
        color: AppColors.white,
        borderRadius: AppRadius.circular,
        shadow: AppShadows.diffused,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.all(3.r),
        child: ClipOval(
          child: Image.asset(path, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
