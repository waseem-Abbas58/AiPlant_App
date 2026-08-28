import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class IdentifyTipsView extends StatelessWidget {
  const IdentifyTipsView({super.key, this.showDone = true});

  final bool showDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: IdentifyTipsBody(showDone: showDone),
      ),
    );
  }
}

class IdentifyTipsBody extends StatelessWidget {
  const IdentifyTipsBody({super.key, this.showDone = true, this.showHeader = true});

  final bool showDone;
  final bool showHeader;

  static const _good = 'assets/images/home/trending/trending_peace_lily.png';
  static const _close = 'assets/images/home/tips/wipe_dusty_leaves.png';
  static const _far = 'assets/images/home/trending/trending_corn_plant.png';
  static const _multi = 'assets/images/home/suggestions/beginner_houseplants.png';

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.large.w,
            AppSpacing.medium.h,
            AppSpacing.large.w,
            AppSpacing.large.h,
          ),
          child: Column(
            children: [
              if (showHeader) ...[
              const CustomText(
                'Identification Tips',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.extraSmall.h),
              const CustomText(
                'Fill the frame with one healthy plant in clear light.',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFD0D0D0),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ],
              _TipCircle(
                size: 196,
                image: _good,
                ok: true,
              ),
              SizedBox(height: AppSpacing.extraLarge.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _TipCircle(size: 88, image: _close, ok: false, label: 'Too Close'),
                  _TipCircle(size: 88, image: _far, ok: false, label: 'Too Far'),
                  _TipCircle(size: 88, image: _multi, ok: false, label: 'Multi-species'),
                ],
              ),
              const Spacer(),
              if (showDone)
                CustomButton(
                  text: 'Done',
                  backgroundColor: AppColors.primaryGreen,
                  textColor: AppColors.white,
                  onPressed: () => Navigator.of(context).pop(),
                ),
            ],
          ),
    );
  }
}

class _TipCircle extends StatelessWidget {
  const _TipCircle({
    required this.size,
    required this.image,
    required this.ok,
    this.label,
  });

  final double size;
  final String image;
  final bool ok;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size.w,
          height: size.w,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Image.asset(
                  image,
                  width: size.w,
                  height: size.w,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: CustomContainer(
                  width: 28,
                  height: 28,
                  color: ok ? AppColors.primaryGreen : AppColors.error,
                  borderRadius: AppRadius.circular,
                  alignment: Alignment.center,
                  child: Icon(
                    ok ? Icons.check_rounded : Icons.close_rounded,
                    size: 16.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (label != null) ...[
          SizedBox(height: AppSpacing.small.h),
          CustomText(
            label!,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
        ],
      ],
    );
  }
}
