import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class HorizontalContentCard extends StatelessWidget {
  const HorizontalContentCard({
    super.key,
    required this.imagePath,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.actionLabel,
    this.expand = false,
    this.imageFit = BoxFit.cover,
    this.heroTag,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final String? subtitle;
  final String? eyebrow;
  final String? actionLabel;
  final bool expand;
  final BoxFit imageFit;
  final String? heroTag;
  final VoidCallback? onTap;

  static const double cardWidth = 278;
  static const double cardHeight = 120;
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
      padding: EdgeInsets.all(AppSpacing.small.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.extraSmall.w,
                right: AppSpacing.small.w,
                top: AppSpacing.extraSmall.h,
                bottom: AppSpacing.extraSmall.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null) ...[
                    CustomText(
                      eyebrow!,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(height: AppSpacing.extraSmall.h),
                  ],
                  CustomText(
                    title,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                    height: 1.2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.extraSmall.h),
                    Expanded(
                      child: CustomText(
                        subtitle!,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                        height: 1.35,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else if (actionLabel != null) ...[
                    const Spacer(),
                    CustomText(
                      actionLabel!,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ],
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: _cardImage(),
          ),
        ],
      ),
    );
  }

  Widget _cardImage() {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.medium.r),
      child: Image.asset(
        imagePath,
        fit: imageFit,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
      ),
    );

    if (heroTag == null) return image;

    return Hero(
      tag: heroTag!,
      child: image,
    );
  }
}
