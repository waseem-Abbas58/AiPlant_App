import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../model/identify_fail_action.dart';
import '../model/plant_identify_result.dart';

class IdentifyFailedView extends StatelessWidget {
  const IdentifyFailedView({
    super.key,
    this.reason = IdentifyFailReason.notPlant,
    this.categoryId = 'plant',
    this.imagePath,
  });

  final IdentifyFailReason reason;
  final String categoryId;
  final String? imagePath;

  bool get _serviceIssue =>
      reason.isRetryable || reason == IdentifyFailReason.aiUnavailable;

  String get _title => switch (reason) {
        IdentifyFailReason.notPlant => 'No plant detected',
        IdentifyFailReason.tooBlurry => 'Photo too blurry',
        IdentifyFailReason.tooDark => 'Not enough light',
        IdentifyFailReason.subjectTooSmall => 'Plant too small in frame',
        IdentifyFailReason.duplicateAngle => 'Very similar photo',
        IdentifyFailReason.multiplePlants => 'Multiple plants detected',
        IdentifyFailReason.aiUnavailable => "We couldn't analyze this photo",
        IdentifyFailReason.offline => "We couldn't analyze this photo",
        IdentifyFailReason.timeout => "We couldn't analyze this photo",
        IdentifyFailReason.serverError => "We couldn't analyze this photo",
        IdentifyFailReason.lowQuality => 'Photo needs a clearer shot',
        IdentifyFailReason.noMatch => "We couldn't identify this",
        IdentifyFailReason.none => "We couldn't identify this",
      };

  String get _subtitle => switch (reason) {
        IdentifyFailReason.tooBlurry =>
          'Hold steady and retake in good light.',
        IdentifyFailReason.tooDark =>
          'Use flash or move to a brighter spot.',
        IdentifyFailReason.subjectTooSmall =>
          'Move closer so the plant fills the frame.',
        IdentifyFailReason.duplicateAngle =>
          'Try a different angle or leaf close-up.',
        IdentifyFailReason.multiplePlants =>
          'Focus on one plant, then retake.',
        IdentifyFailReason.offline =>
          'Phone could not reach the backend. Same Wi-Fi, and keep npm run dev on.',
        IdentifyFailReason.timeout =>
          'The server took too long. Try again on a stable connection.',
        IdentifyFailReason.aiUnavailable ||
        IdentifyFailReason.serverError =>
          'The service is temporarily unavailable.',
        IdentifyFailReason.lowQuality =>
          'Use clear light and one plant in frame.',
        IdentifyFailReason.noMatch =>
          'One healthy plant in clear light works best.',
        IdentifyFailReason.none =>
          'One healthy plant in clear light works best.',
        IdentifyFailReason.notPlant => switch (categoryId) {
            'tree' => 'Point at a leaf or bark, not objects.',
            'mushroom' => 'Fill the frame with cap and stem.',
            'weed' => 'Photograph the whole weed.',
            'disease' => 'Use a plant leaf in clear light.',
            _ => 'Point at a plant, leaf, or flower.',
          },
      };

  bool get _showTips =>
      reason == IdentifyFailReason.noMatch ||
      reason == IdentifyFailReason.lowQuality ||
      reason.isPhotoIssue;

  String get _primaryLabel => _serviceIssue ? 'Try again' : 'Scan again';

  void _onBack() => NavigationHelper.back(IdentifyFailAction.back);

  void _onPrimary() => NavigationHelper.back(
        _serviceIssue
            ? IdentifyFailAction.retrySame
            : IdentifyFailAction.back,
      );

  void _onGallery() =>
      NavigationHelper.back(IdentifyFailAction.pickGallery);

  @override
  Widget build(BuildContext context) {
    final hasPhoto = imagePath != null && imagePath!.isNotEmpty;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.medium.w,
                  AppSpacing.small.h,
                  AppSpacing.medium.w,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomContainer(
                    onTap: _onBack,
                    color: AppColors.white,
                    borderRadius: AppRadius.circular,
                    shadow: AppShadows.soft,
                    padding: EdgeInsets.all(8.r),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18.sp,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final photoSize = math.min(
                      constraints.maxHeight * 0.52,
                      176.w,
                    ).clamp(128.0, 176.w);

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.large.w,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (hasPhoto)
                            _CaptureHero(path: imagePath!, size: photoSize)
                          else
                            _ServiceHero(reason: reason, size: photoSize),
                          SizedBox(height: AppSpacing.medium.h),
                          CustomText(
                            _title,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                            textAlign: TextAlign.center,
                            letterSpacing: -0.3,
                            maxLines: 2,
                          ),
                          SizedBox(height: 6.h),
                          CustomText(
                            _subtitle,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondaryText,
                            textAlign: TextAlign.center,
                            height: 1.35,
                            maxLines: 2,
                          ),
                          if (_showTips) ...[
                            SizedBox(height: AppSpacing.medium.h),
                            const _MiniTipsRow(),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              CustomContainer(
                color: AppColors.white,
                shadow: AppShadows.soft,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.medium.w,
                  AppSpacing.small.h,
                  AppSpacing.medium.w,
                  AppSpacing.small.h + bottomInset,
                ),
                child: Column(
                  children: [
                    CustomButton(
                      text: _primaryLabel,
                      backgroundColor: AppColors.primaryGreen,
                      textColor: AppColors.white,
                      borderRadius: AppRadius.large,
                      height: 50,
                      onPressed: _onPrimary,
                    ),
                    if (!_serviceIssue) ...[
                      SizedBox(height: AppSpacing.small.h),
                      CustomContainer(
                        onTap: _onGallery,
                        color: AppColors.white,
                        borderRadius: AppRadius.large,
                        border: Border.all(color: AppColors.primaryGreen),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        child: const CustomText(
                          'Choose from gallery',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ] else
                      CustomContainer(
                        onTap: _onBack,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: const CustomText(
                          'Back',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptureHero extends StatelessWidget {
  const _CaptureHero({required this.path, required this.size});

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.45),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
              ClipOval(
                child: Image.file(
                  File(path),
                  width: size - 8,
                  height: size - 8,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: size - 8,
                    height: size - 8,
                    color: AppColors.divider,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.mutedText,
                      size: 32.sp,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: CustomContainer(
                  width: 28,
                  height: 28,
                  color: AppColors.error,
                  borderRadius: AppRadius.circular,
                  border: Border.all(color: AppColors.white, width: 2),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.close_rounded,
                    size: 16.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.small.h),
        CustomContainer(
          color: AppColors.white,
          borderRadius: AppRadius.circular,
          border: Border.all(color: AppColors.border),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          child: const CustomText(
            'Your photo',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _ServiceHero extends StatelessWidget {
  const _ServiceHero({required this.reason, required this.size});

  final IdentifyFailReason reason;
  final double size;

  IconData get _icon => switch (reason) {
        IdentifyFailReason.offline => Icons.wifi_off_rounded,
        IdentifyFailReason.timeout => Icons.hourglass_empty_rounded,
        _ => Icons.cloud_off_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      width: size * 0.72,
      height: size * 0.72,
      color: AppColors.white,
      borderRadius: AppRadius.circular,
      shadow: AppShadows.soft,
      border: Border.all(color: AppColors.border),
      alignment: Alignment.center,
      child: Icon(
        _icon,
        size: 40.sp,
        color: AppColors.mutedText,
      ),
    );
  }
}

class _MiniTipsRow extends StatelessWidget {
  const _MiniTipsRow();

  static const _good = 'assets/images/home/trending/trending_peace_lily.png';
  static const _close = 'assets/images/home/tips/wipe_dusty_leaves.png';
  static const _far = 'assets/images/home/trending/trending_corn_plant.png';
  static const _multi =
      'assets/images/home/suggestions/beginner_houseplants.png';

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.small.w,
        vertical: AppSpacing.small.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomText(
            'What works best',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          SizedBox(height: AppSpacing.small.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _MiniTip(image: _good, ok: true, label: 'Good'),
              _MiniTip(image: _close, ok: false, label: 'Close'),
              _MiniTip(image: _far, ok: false, label: 'Far'),
              _MiniTip(image: _multi, ok: false, label: 'Multi'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTip extends StatelessWidget {
  const _MiniTip({
    required this.image,
    required this.ok,
    required this.label,
  });

  final String image;
  final bool ok;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 52.w,
          height: 52.w,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Image.asset(
                  image,
                  width: 52.w,
                  height: 52.w,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: CustomContainer(
                  width: 18,
                  height: 18,
                  color: ok ? AppColors.primaryGreen : AppColors.error,
                  borderRadius: AppRadius.circular,
                  alignment: Alignment.center,
                  child: Icon(
                    ok ? Icons.check_rounded : Icons.close_rounded,
                    size: 11.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        CustomText(
          label,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedText,
        ),
      ],
    );
  }
}
