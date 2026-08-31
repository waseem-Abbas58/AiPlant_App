import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_image.dart';
import '../../../shared/widgets/custom_text.dart';

class PlantToolCard extends StatelessWidget {
  const PlantToolCard({
    super.key,
    required this.imagePath,
    required this.title,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      pressScale: 0.97,
      color: AppColors.white,
      borderRadius: AppRadius.medium,
      shadow: AppShadows.soft,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.small.w,
        vertical: AppSpacing.small.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImage(
            assetPath: imagePath,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
            borderRadius: 0,
          ),
          SizedBox(height: AppSpacing.small.h),
          CustomText(
            title,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
