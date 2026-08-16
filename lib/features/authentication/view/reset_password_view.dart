import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/validators/validators.dart';
import '../../../shared/widgets/custom_password_field.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/reset_password_controller.dart';
import '../widgets/auth_shared_widgets.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView>
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
    final controller = Get.find<ResetPasswordController>();
    final textTheme = Theme.of(context).textTheme;
    final style = AuthFormStyle(textTheme);

    return AuthScaffold(
      pinBottomDecoration: true,
      child: AutofillGroup(
      child: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
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
                      'Reset Password',
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
                    child: CustomText(
                      'Create a new password to secure your AI PlantApp account.',
                      style: textTheme.bodyMedium?.copyWith(height: 1.4),
                      color: AppColors.secondaryText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.34,
                    end: 0.60,
                    slideBegin: const Offset(0, 0.08),
                    child: CustomPasswordField(
                      controller: controller.passwordController,
                      focusNode: controller.passwordFocus,
                      hintText: 'New Password',
                      textInputAction: TextInputAction.next,
                      isDense: true,
                      fillColor: AuthFormStyle.fill,
                      focusedBorderColor: AuthFormStyle.focus,
                      cursorColor: AuthFormStyle.focus,
                      borderRadius: AuthFormStyle.fieldRadius,
                      contentPadding: style.fieldPadding,
                      style: style.textStyle,
                      hintStyle: style.hintStyle,
                      validator: Validators.password,
                      autofillHints: const [AutofillHints.newPassword],
                      prefixIcon:
                          AuthFormStyle.icon(Icons.lock_outline_rounded),
                    ),
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.44,
                    end: 0.70,
                    slideBegin: const Offset(0, 0.08),
                    child: CustomPasswordField(
                      controller: controller.confirmPasswordController,
                      focusNode: controller.confirmFocus,
                      hintText: 'Confirm New Password',
                      textInputAction: TextInputAction.done,
                      isDense: true,
                      fillColor: AuthFormStyle.fill,
                      focusedBorderColor: AuthFormStyle.focus,
                      cursorColor: AuthFormStyle.focus,
                      borderRadius: AuthFormStyle.fieldRadius,
                      contentPadding: style.fieldPadding,
                      style: style.textStyle,
                      hintStyle: style.hintStyle,
                      validator: (value) => Validators.confirmPassword(
                        value,
                        controller.passwordController.text,
                      ),
                      autofillHints: const [AutofillHints.newPassword],
                      onSubmitted: (_) {
                        if (controller.canSubmit) {
                          controller.submitReset();
                        }
                      },
                      prefixIcon:
                          AuthFormStyle.icon(Icons.lock_outline_rounded),
                    ),
                  ),
                  SizedBox(height: AppSpacing.large.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.56,
                    end: 0.84,
                    scaleBegin: 0.96,
                    slideBegin: const Offset(0, 0.10),
                    child: Obx(
                      () => AuthPrimaryButton(
                        text: 'Reset Password',
                        enabled: controller.canSubmit,
                        isLoading: controller.isSubmitting.value,
                        onPressed: controller.submitReset,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.large.h),
            AuthStaggeredEntrance(
              animation: _entrance,
              begin: 0.70,
              end: 1,
              slideBegin: const Offset(0, 0.08),
              child: AuthFooterPrompt(
                leading: '',
                actionLabel: 'Back to Login',
                onAction: controller.goToLogin,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
