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
    this.eyebrow,
    this.expand = false,
    this.onTap,
    this.heroTag,
    this.chip,
  });

  final String imagePath;
  final String title;
  final String? eyebrow;
  final bool expand;
  final VoidCallback? onTap;
  final String? heroTag;
  final String? chip;

  static const double cardWidth = 196;
  static const double imageHeight = 132;
  static const double titleBand = 40;
  static const double cardHeight = imageHeight + titleBand;
  static double get extent => cardHeight.h;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      pressScale: 0.98,
      width: expand ? null : cardWidth,
      height: cardHeight,
      color: AppColors.white,
      borderRadius: AppRadius.medium,
      shadow: AppShadows.soft,
      border: Border.all(
        color: AppColors.black.withValues(alpha: 0.06),
        width: 0.5,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: imageHeight.h,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: heroTag ?? imagePath,
                  child: CustomImage(
                    assetPath: imagePath,
                    width: expand ? null : cardWidth,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    borderRadius: 0,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 56.h,
                  child: const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x42000000),
                            Color(0x00000000),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (chip != null)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        child: CustomText(
                          chip!,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.small.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  title,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  textAlign: TextAlign.left,
                  height: 1.2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
