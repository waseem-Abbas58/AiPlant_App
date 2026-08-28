import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  late final AnimationController _entrance;
  late final OtpVerificationController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<OtpVerificationController>();
    _otpController.addListener(_syncOtp); 
    _syncOtp();
    _entrance = AnimationController(
      vsync: this,
      duration: _entranceDuration,
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _otpFocusNode.requestFocus();
    });
  }

  void _syncOtp() {
    final digits = _otpController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final clipped = digits.length > OtpVerificationController.otpLength
        ? digits.substring(0, OtpVerificationController.otpLength)
        : digits;
    if (clipped != _otpController.text) {
      _otpController.value = TextEditingValue(
        text: clipped,
        selection: TextSelection.collapsed(offset: clipped.length),
      );
      return;
    }
    _auth.syncOtp(clipped);
  }

  void _verifyCode() {
    if (!_auth.canVerify) return;
    _otpFocusNode.unfocus();
    _auth.verifyCode();
  }

  void _resendCode() {
    if (!_auth.canResend) return;
    _otpController.clear();
    _auth.resendCode();
    _otpFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _otpController
      ..removeListener(_syncOtp)
      ..dispose();
    _otpFocusNode.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _auth;
    final textTheme = Theme.of(context).textTheme;

    return _OtpVerificationScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.large.h),
          AuthStaggeredEntrance(
            animation: _entrance,
            begin: 0,
            end: 0.28,
            scaleBegin: 0.85,
            slideBegin: const Offset(0, 0.08),
            child: const AuthLogo(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.large.w,
              AppSpacing.large.h,
              AppSpacing.large.w,
              AppSpacing.small.h, 
            ), 
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
                    fontWeight: FontWeight.bold,
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
                        'We sent a 6-digit verification code',
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
                        controller: _otpController,
                        focusNode: _otpFocusNode,
                        hasError: controller.hasError,
                        onSubmitted: () {
                          if (controller.canVerify) {
                            _verifyCode();
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
                SizedBox(height: AppSpacing.medium.h),
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
                      onPressed: _verifyCode,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.small.h),
                AuthStaggeredEntrance(
                  animation: _entrance,
                  begin: 0.60,
                  end: 0.90,
                  child: Obx(() {
                    final canResend = controller.canResend;
                    return TextButton(
                      onPressed:
                          canResend ? _resendCode : null,
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
          AuthStaggeredEntrance(
            animation: _entrance,
            begin: 0.50,
            end: 1,
            slideBegin: const Offset(0, 0.08),
            child: AuthFooterPrompt(
              leading: '', 
              actionLabel: 'Change Email',
              onAction: controller.goToForgotPassword,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpVerificationScaffold extends StatelessWidget {
  const _OtpVerificationScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.large.w,
          AppSpacing.extraLarge.h,
          AppSpacing.large.w,
          AppSpacing.large.h + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: child,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Image(
                image: AssetImage('assets/images/otp_background.png'),
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
                width: double.infinity,
              ),
            ),
            content,
          ],
        ),
      ),
    );
  }
}
