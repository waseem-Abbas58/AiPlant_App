import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import 'garden_hero.dart';
import 'garden_plant_image.dart';

class GardenPlantCard extends StatelessWidget {
  const GardenPlantCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.status,
    this.isAssetImage = true,
    this.heroTag,
    this.onTap,
    this.onStatusTap,
    this.onMore,
  });

  final String imagePath;
  final String name;
  final String status;
  final bool isAssetImage;
  final String? heroTag;
  final VoidCallback? onTap;
  final VoidCallback? onStatusTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final needsWater = status.toLowerCase().contains('needs water');
    final statusColor =
        needsWater ? const Color(0xFF1E88E5) : AppColors.primaryGreen;

    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.diffused,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: heroTag ?? gardenPhotoHeroTag(imagePath),
            child: Material(
              type: MaterialType.transparency,
              child: GardenPlantImage(
                path: imagePath,
                isAsset: isAssetImage,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000),
                  Colors.transparent,
                  Colors.transparent,
                  Color(0xCC000000),
                ],
                stops: [0, 0.22, 0.48, 1],
              ),
            ),
          ),
          if (onMore != null)
            Positioned(
              top: 10.h,
              right: 10.w,
              child: CustomContainer(
                onTap: onMore,
                color: AppColors.white.withValues(alpha: 0.94),
                borderRadius: AppRadius.circular,
                padding: EdgeInsets.all(6.r),
                child: Icon(
                  Icons.more_horiz_rounded,
                  size: 18.sp,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 14.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  name,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                CustomContainer(
                  onTap: onStatusTap,
                  color: statusColor.withValues(alpha: 0.92),
                  borderRadius: AppRadius.circular,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  child: CustomText(
                    status,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
