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
    this.scientificName = '',
    this.isAssetImage = true,
    this.heroTag,
    this.onTap,
    this.onStatusTap,
    this.onMore,
  });

  final String imagePath;
  final String name;
  final String status;
  final String scientificName;
  final bool isAssetImage;
  final String? heroTag;
  final VoidCallback? onTap;
  final VoidCallback? onStatusTap;
  final VoidCallback? onMore;

  bool get _needsWater {
    final lower = status.toLowerCase();
    return lower.contains('needs water') || lower.contains('due today');
  }

  @override
  Widget build(BuildContext context) {
    final statusColor =
        _needsWater ? const Color(0xFF1E88E5) : AppColors.primaryGreen;
    final statusIcon = _needsWater
        ? Icons.water_drop_rounded
        : Icons.eco_rounded;

    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
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
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x26000000),
                  Colors.transparent,
                  Color(0x33000000),
                  Color(0xB3000000),
                ],
                stops: [0, 0.38, 0.62, 1],
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
            bottom: 12.h,
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
                if (scientificName.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  CustomText(
                    scientificName,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white.withValues(alpha: 0.82),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 8.h),
                CustomContainer(
                  onTap: onStatusTap,
                  color: statusColor.withValues(alpha: 0.94),
                  borderRadius: AppRadius.circular,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 12.sp,
                        color: AppColors.white,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
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
          ),
        ],
      ),
    );
  }
}
