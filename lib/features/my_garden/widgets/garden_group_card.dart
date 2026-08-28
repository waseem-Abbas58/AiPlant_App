import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import 'garden_plant_image.dart';

class GardenGroupCard extends StatelessWidget {
  const GardenGroupCard({
    super.key,
    required this.title,
    required this.plantCount,
    this.coverImagePath,
    this.coverIsAsset = true,
    this.selected = false,
    this.outlined = false,
    this.onTap,
    this.onLongPress,
  });

  final String title;
  final int plantCount;
  final String? coverImagePath;
  final bool coverIsAsset;
  final bool selected;
  final bool outlined;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  static const double cardWidth = 120;
  static const double cardHeight = 108;
  static double get extent => cardHeight.h;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: CustomContainer(
        onTap: onTap,
        width: cardWidth,
        height: cardHeight,
        color: outlined ? AppColors.white : AppColors.sageBackground,
        borderRadius: AppRadius.large,
        shadow: AppShadows.soft,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        border: selected
            ? Border.all(color: AppColors.primaryGreen, width: 2)
            : outlined
                ? Border.all(color: AppColors.primaryGreen)
                : null,
        child: outlined
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 22.sp,
                    color: AppColors.primaryGreen,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    title,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  if (coverImagePath == null)
                    ColoredBox(
                      color: AppColors.sageBackground,
                      child: Center(
                        child: Icon(
                          Icons.eco_outlined,
                          size: 28.sp,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: GardenPlantImage(
                        path: coverImagePath!,
                        isAsset: coverIsAsset,
                        fit: BoxFit.cover,
                      ),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.small.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomText(
                          title,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        CustomText(
                          plantCount == 1 ? '1 plant' : '$plantCount plants',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white.withValues(alpha: 0.86),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
