import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class DiseaseGridItem extends StatelessWidget {
  const DiseaseGridItem({
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
      pressScale: 0.98,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium.r),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.extraSmall.h),
          CustomText(
            title,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
