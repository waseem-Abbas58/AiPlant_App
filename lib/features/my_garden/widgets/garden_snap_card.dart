import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import 'garden_plant_image.dart';

class GardenSnapCard extends StatelessWidget {
  const GardenSnapCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.scientificName,
    required this.dateLabel,
    this.inGarden = false,
    this.onWishlist = false,
    this.onDelete,
    this.onAdd,
    this.onOpen,
    this.onSaveWishlist,
  });

  final String imagePath;
  final String name;
  final String scientificName;
  final String dateLabel;
  final bool inGarden;
  final bool onWishlist;
  final VoidCallback? onDelete;
  final VoidCallback? onAdd;
  final VoidCallback? onOpen;
  final VoidCallback? onSaveWishlist;

  @override
  Widget build(BuildContext context) {
    final isAsset = imagePath.startsWith('assets/');

    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.small.w + 2.w),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomContainer(
                  onTap: onOpen,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GardenPlantImage(
                        path: imagePath,
                        isAsset: isAsset,
                        width: 64.w,
                        height: 64.w,
                        borderRadius:
                            BorderRadius.circular(AppRadius.medium.r),
                      ),
                      SizedBox(width: AppSpacing.small.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              name,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            CustomText(
                              scientificName,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            CustomText(
                              dateLabel,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.mutedText,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomContainer(
                onTap: onDelete,
                padding: EdgeInsets.all(AppSpacing.extraSmall.w),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 20.sp,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.small.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (inGarden)
                const CustomText(
                  'In garden',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                )
              else ...[
                if (onWishlist)
                  const CustomText(
                    'On wishlist',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  )
                else if (onSaveWishlist != null)
                  CustomContainer(
                    onTap: onSaveWishlist,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.small.w,
                      vertical: 6.h,
                    ),
                    child: const CustomText(
                      'Wishlist',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                    ),
                  ),
                SizedBox(width: AppSpacing.small.w),
                CustomContainer(
                  onTap: onAdd,
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: AppRadius.circular,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium.w,
                    vertical: 6.h,
                  ),
                  child: const CustomText(
                    'Add to garden',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
