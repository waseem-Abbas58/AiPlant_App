import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
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
    this.onAddPlant,
    this.expand = false,
  });

  final String title;
  final int plantCount;
  final String? coverImagePath;
  final bool coverIsAsset;
  final bool selected;
  final bool outlined;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onAddPlant;
  final bool expand;

  static const double cardWidth = 280;
  static const double cardHeight = 100;
  static double get extent => cardHeight.h;

  bool get _photoCard => !outlined && coverImagePath != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: CustomContainer(
        onTap: onTap,
        width: expand ? null : cardWidth,
        height: cardHeight,
        color: AppColors.white,
        borderRadius: AppRadius.large,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        border: Border.all(color: AppColors.border),
        child: _photoCard ? _photoFill() : _plainFill(),
      ),
    );
  }

  Widget _plainFill() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.small.w + 4.w,
        vertical: AppSpacing.small.h,
      ),
      child: Row(
        children: [
          _GroupStackArt(add: outlined),
          SizedBox(width: AppSpacing.small.w + 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  title,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!outlined) ...[
                  SizedBox(height: 2.h),
                  CustomText(
                    plantCount == 1 ? '1 plant' : '$plantCount plants',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                  ),
                  if (onAddPlant != null)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: CustomContainer(
                        onTap: onAddPlant,
                        color: AppColors.white,
                        borderRadius: AppRadius.medium,
                        border: Border.all(color: AppColors.lightGreen),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.small.w + 2.w,
                          vertical: 4.h,
                        ),
                        child: const CustomText(
                          'Add Plant',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoFill() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GardenPlantImage(
            path: coverImagePath!,
            isAsset: coverIsAsset,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x14000000),
                Colors.transparent,
                Color(0x99000000),
              ],
              stops: [0, 0.42, 1],
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
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              CustomText(
                plantCount == 1 ? '1 plant' : '$plantCount plants',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.white.withValues(alpha: 0.86),
              ),
              if (onAddPlant != null)
                GestureDetector(
                  onTap: onAddPlant,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: const CustomText(
                      'Add Plant',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupStackArt extends StatelessWidget {
  const _GroupStackArt({this.add = false});

  final bool add;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.w,
      height: 56.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(-6.w, 3.h),
            child: Transform.rotate(
              angle: -0.18,
              child: _sheet(),
            ),
          ),
          Transform.translate(
            offset: Offset(6.w, 3.h),
            child: Transform.rotate(
              angle: 0.18,
              child: _sheet(),
            ),
          ),
          _sheet(
            child: Icon(
              add ? Icons.add_rounded : Icons.eco_outlined,
              size: 20.sp,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheet({Widget? child}) {
    return CustomContainer(
      width: 36,
      height: 44,
      color: AppColors.white,
      borderRadius: AppRadius.small,
      border: Border.all(color: AppColors.border),
      alignment: Alignment.center,
      child: child,
    );
  }
}
