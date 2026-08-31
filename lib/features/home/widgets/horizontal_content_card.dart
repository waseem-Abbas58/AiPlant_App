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
    this.color,
    this.titleMaxLines = 2,
    this.subtitleMaxLines = 4,
    this.chip,
    this.height,
    this.titleFontSize = 13,
    this.titleFontWeight = FontWeight.w600,
    this.titleMinLines,
    this.pinActionToBottom = true,
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
  final Color? color;
  final int titleMaxLines;
  final int subtitleMaxLines;
  final String? chip;
  final double? height;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final int? titleMinLines;
  final bool pinActionToBottom;

  static const double cardWidth = 278;
  static const double cardHeight = 120;
  static double get extent => cardHeight.h;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      width: expand ? null : cardWidth,
      height: height ?? cardHeight,
      color: color ?? AppColors.white,
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
                  Builder(
                    builder: (context) {
                      final titleText = CustomText(
                        title,
                        fontSize: titleFontSize,
                        fontWeight: titleFontWeight,
                        color: AppColors.primaryText,
                        height: 1.25,
                        maxLines: titleMaxLines,
                        overflow: TextOverflow.ellipsis,
                      );
                      final minLines = titleMinLines;
                      if (minLines == null) return titleText;
                      return SizedBox(
                        height: titleFontSize.sp * 1.25 * minLines,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: titleText,
                        ),
                      );
                    },
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.extraSmall.h),
                    if (actionLabel == null)
                      Expanded(
                        child: CustomText(
                          subtitle!,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryText,
                          height: 1.35,
                          maxLines: subtitleMaxLines,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      CustomText(
                        subtitle!,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                        height: 1.35,
                        maxLines: subtitleMaxLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                  if (actionLabel != null) ...[
                    if (pinActionToBottom)
                      const Spacer()
                    else
                      SizedBox(height: AppSpacing.small.h),
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
    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.medium.r),
      child: Image.asset(
        imagePath,
        fit: imageFit,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
      ),
    );

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    if (chip == null) return image;

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        Positioned(
          top: 6.h,
          left: 6.w,
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
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
    );
  }
}
