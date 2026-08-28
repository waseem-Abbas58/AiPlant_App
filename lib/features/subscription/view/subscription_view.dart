import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/subscription_controller.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  static const _perks = [
    'Unlimited plant identification',
    'Disease scans without limits',
    'Ad-free home and garden',
    'Premium care reminders',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sageBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: NavigationHelper.back,
          icon: Icon(
            Icons.close_rounded,
            size: 22.sp,
            color: AppColors.primaryText,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppImages.premiumCardBg,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.large.w,
                0,
                AppSpacing.large.w,
                AppSpacing.medium.h,
              ),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                'AiPlant Premium',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
                letterSpacing: -0.4,
                height: 1.2,
              ),
              SizedBox(height: AppSpacing.small.h),
              CustomText(
                'Choose a plan. Nothing is billed yet.',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
              SizedBox(height: AppSpacing.large.h),
              for (final perk in _perks) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.small.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 20.sp,
                        color: AppColors.primaryGreen,
                      ),
                      SizedBox(width: AppSpacing.small.w),
                      Expanded(
                        child: CustomText(
                          perk,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.medium.h),
              Obx(() {
                final selected = controller.selectedPlan.value;
                return Column(
                  children: [
                    _PlanTile(
                      title: '7 days',
                      price: 'Free trial',
                      badge: 'Popular',
                      selected: selected == 0,
                      onTap: () => controller.selectPlan(0),
                    ),
                    SizedBox(height: AppSpacing.small.h),
                    _PlanTile(
                      title: 'Monthly',
                      price: '\$4.99 / month',
                      selected: selected == 1,
                      onTap: () => controller.selectPlan(1),
                    ),
                    SizedBox(height: AppSpacing.small.h),
                    _PlanTile(
                      title: 'Yearly',
                      price: '\$29.99 / year',
                      badge: 'Save 50%',
                      selected: selected == 2,
                      onTap: () => controller.selectPlan(2),
                    ),
                  ],
                );
              }),
              const Spacer(),
              CustomButton(
                text: 'Continue',
                backgroundColor: AppColors.primaryGreen,
                height: 48,
                borderRadius: AppRadius.large,
                onPressed: NavigationHelper.back,
              ),
              SizedBox(height: AppSpacing.small.h),
              Center(
                child: CustomText(
                  'Restore purchase  ·  Terms',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.title,
    required this.price,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: selected ? AppShadows.soft : AppShadows.none,
      border: Border.all(
        color: selected ? AppColors.primaryGreen : AppColors.border,
        width: selected ? 1.5 : 1,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium.w,
        vertical: AppSpacing.medium.h,
      ),
      child: Row(
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            size: 22.sp,
            color: selected ? AppColors.primaryGreen : AppColors.mutedText,
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
                CustomText(
                  price,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          if (badge != null)
            CustomContainer(
              color: AppColors.lightGreen.withValues(alpha: 0.35),
              borderRadius: AppRadius.circular,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.small.w,
                vertical: 4.h,
              ),
              child: CustomText(
                badge!,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
        ],
      ),
    );
  }
}
