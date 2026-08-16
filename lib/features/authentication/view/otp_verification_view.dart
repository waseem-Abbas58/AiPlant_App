import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_durations.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/otp_verification_controller.dart';
import '../widgets/auth_otp_input.dart';
import '../widgets/auth_shared_widgets.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView>
    with SingleTickerProviderStateMixin {
  static final Duration _entranceDuration =
      AppDurations.slow + AppDurations.medium;

  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: _entranceDuration,
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpVerificationController>();
    final textTheme = Theme.of(context).textTheme;

    return AuthScaffold(
      pinBottomDecoration: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthStaggeredEntrance(
            animation: _entrance,
            begin: 0,
            end: 0.28,
            scaleBegin: 0.85,
            slideBegin: const Offset(0, 0.08),
            child: const AuthLogo(),
          ),
          SizedBox(height: AppSpacing.extraLarge.h),
          AuthCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthStaggeredEntrance(
                  animation: _entrance,
                  begin: 0.16,
                  end: 0.42,
                  scaleBegin: 0.98,
                  slideBegin: const Offset(0, 0.10),
                  child: CustomText(
                    'Verify Your Email',
                    style: textTheme.headlineSmall?.copyWith(
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: AppSpacing.small.h),
                AuthStaggeredEntrance(
                  animation: _entrance,
                  begin: 0.24,
                  end: 0.50,
                  slideBegin: const Offset(0, 0.08),
                  child: Column(
                    children: [
                      CustomText(
                        'We sent a 6-digit verification code to your email address.',
                        style: textTheme.bodyMedium?.copyWith(height: 1.4),
                        color: AppColors.secondaryText,
                        textAlign: TextAlign.center,
                      ),
                      Obx(() {
                        final masked = controller.maskedEmail;
                        if (masked.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: EdgeInsets.only(top: AppSpacing.extraSmall.h),
                          child: CustomText(
                            masked,
                            style: textTheme.bodyMedium?.copyWith(height: 1.4),
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.medium.h),
                AuthStaggeredEntrance(
                  animation: _entrance,
                  begin: 0.34,
                  end: 0.62,
                  slideBegin: const Offset(0, 0.08),
                  child: Column(
                    children: [
                      AuthOtpInput(
                        controller: controller.otpController,
                        focusNode: controller.otpFocusNode,
                        hasError: controller.hasError,
                        onSubmitted: () {
                          if (controller.canVerify) {
                            controller.verifyCode();
                          }
                        },
                      ),
                      Obx(() {
                        if (!controller.hasError.value) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: AppSpacing.small.h),
                          child: CustomText(
                            'Invalid verification code. Please try again.',
                            style: textTheme.bodySmall?.copyWith(height: 1.3),
                            color: AppColors.error,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.large.h),
                AuthStaggeredEntrance(
                  animation: _entrance,
                  begin: 0.48,
                  end: 0.78,
                  scaleBegin: 0.96,
                  slideBegin: const Offset(0, 0.10),
                  child: Obx(
                    () => AuthPrimaryButton(
                      text: 'Verify Code',
                      enabled: controller.canVerify,
                      onPressed: controller.verifyCode,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.medium.h),
                AuthStaggeredEntrance(
                  animation: _entrance,
                  begin: 0.60,
                  end: 0.90,
                  child: Obx(() {
                    final canResend = controller.canResend;
                    return TextButton(
                      onPressed:
                          canResend ? controller.resendCode : null,
                      style: TextButton.styleFrom(
                        foregroundColor: canResend
                            ? AppColors.primaryGreen
                            : AppColors.mutedText,
                        disabledForegroundColor: AppColors.mutedText,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.small.w,
                          vertical: AppSpacing.small.h,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: CustomText(
                        controller.resendLabel,
                        style: textTheme.labelMedium?.copyWith(height: 1.2),
                        color: canResend
                            ? AppColors.primaryGreen
                            : AppColors.mutedText,
                        fontWeight:
                            canResend ? FontWeight.w600 : FontWeight.w500,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.medium.h),
          AuthStaggeredEntrance(
            animation: _entrance,
            begin: 0.70,
            end: 1,
            slideBegin: const Offset(0, 0.08),
            child: AuthFooterPrompt(
              leading: '',
              actionLabel: 'Change email',
              onAction: controller.goToForgotPassword,
            ),
          ),
        ],
      ),
    );
  }
}
