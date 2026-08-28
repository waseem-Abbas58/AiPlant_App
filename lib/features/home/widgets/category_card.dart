import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_image.dart';
import '../../../shared/widgets/custom_text.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.color = const Color(0xFFF3F5F4),
    this.onTap,
  });

  final String title;
  final String imagePath;
  final Color color;
  final VoidCallback? onTap;

  static double get extent => 108.h;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      height: 108,
      color: AppColors.white,
      borderRadius: AppRadius.medium,
      shadow: AppShadows.soft,
      border: Border.all(
        color: AppColors.black.withValues(alpha: 0.06),
        width: 0.5,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            right: -10.w,
            top: -6.h,
            bottom: -14.h,
            width: 102.w,
            child: CustomImage(
              assetPath: imagePath,
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
              borderRadius: 0,
            ),
          ),
          Positioned(
            left: 12.w,
            top: 16.h,
            right: 48.w,
            child: CustomText(
              title,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              textAlign: TextAlign.left,
              height: 1.25,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryWideCard extends StatelessWidget {
  const CategoryWideCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.color = const Color(0xFFF3F5F4),
    this.onTap,
  });

  final String title;
  final String imagePath;
  final Color color;
  final VoidCallback? onTap;

  static double get extent => 108.h;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      height: 108,
      color: AppColors.white,
      borderRadius: AppRadius.medium,
      shadow: AppShadows.soft,
      border: Border.all(
        color: AppColors.black.withValues(alpha: 0.06),
        width: 0.5,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            right: -10.w,
            top: -6.h,
            bottom: -14.h,
            width: 102.w,
            child: CustomImage(
              assetPath: imagePath,
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
              borderRadius: 0,
            ),
          ),
          Positioned(
            left: 12.w,
            top: 16.h,
            right: 110.w,
            child: CustomText(
              title,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              textAlign: TextAlign.left,
              height: 1.25,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
