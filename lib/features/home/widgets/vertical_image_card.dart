import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_image.dart';
import '../../../shared/widgets/custom_text.dart';
class VerticalImageCard extends StatelessWidget {
  const VerticalImageCard({
    super.key,
    required this.imagePath,
    required this.title,
    this.expand = false,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final bool expand;
  final VoidCallback? onTap;

  static const double cardWidth = 278;
  static const double imageHeight = 108;
  static const double titleBand = 40; 
  static const double cardHeight = imageHeight + titleBand;
  static double get extent => cardHeight.h;

  @override
  Widget build(BuildContext context) {    
    return CustomContainer(
      onTap: onTap,
      width: expand ? null : cardWidth,
      height: cardHeight,
      color: AppColors.white,
      borderRadius: AppRadius.medium,
      shadow: AppShadows.diffused,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: imageHeight.h,
            width: double.infinity,
            child: CustomImage(
              assetPath: imagePath,
              width: expand ? null : cardWidth,
              height: imageHeight,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              borderRadius: 0,
            ),
          ),
          SizedBox(
            height: titleBand.h,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.medium.w,
                AppSpacing.small.h,
                AppSpacing.medium.w,
                AppSpacing.extraSmall.h,
              ),
              child: CustomText(
                title,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
                textAlign: TextAlign.center,
                height: 1.2,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
