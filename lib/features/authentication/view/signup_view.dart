import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/validators/validators.dart';
import '../../../shared/widgets/custom_password_field.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controller/signup_controller.dart';
import '../widgets/auth_shared_widgets.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView>
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
    final controller = Get.find<SignupController>();
    final textTheme = Theme.of(context).textTheme;
    final style = AuthFormStyle(textTheme);

    return AuthScaffold(
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
              end: 0.22,
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
                    begin: 0.14,
                    end: 0.36,
                    scaleBegin: 0.98,
                    slideBegin: const Offset(0, 0.10),
                    child: CustomText(
                      'Create Your Account 🌱',
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
                    begin: 0.20,
                    end: 0.42,
                    slideBegin: const Offset(0, 0.08),
                    child: CustomText(
                      'Join AI PlantApp and start caring for your plants smarter.',
                      style: textTheme.bodyMedium?.copyWith(height: 1.4),
                      color: AppColors.secondaryText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.26,
                    end: 0.48,
                    slideBegin: const Offset(0, 0.08),
                    child: CustomTextField(
                      controller: controller.nameController,
                      hintText: 'Full Name',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      isDense: true,
                      fillColor: AuthFormStyle.fill,
                      focusedBorderColor: AuthFormStyle.focus,
                      cursorColor: AuthFormStyle.focus,
                      borderRadius: AuthFormStyle.fieldRadius,
                      contentPadding: style.fieldPadding,
                      style: style.textStyle,
                      hintStyle: style.hintStyle,
                      validator: (value) =>
                          Validators.required(value, fieldName: 'Full name'),
                      prefixIcon: AuthFormStyle.icon(Icons.person_outline_rounded),
                    ),
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.34,
                    end: 0.56,
                    slideBegin: const Offset(0, 0.08),
                    child: CustomTextField(
                      controller: controller.emailController,
                      hintText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      isDense: true,
                      fillColor: AuthFormStyle.fill,
                      focusedBorderColor: AuthFormStyle.focus,
                      cursorColor: AuthFormStyle.focus,
                      borderRadius: AuthFormStyle.fieldRadius,
                      contentPadding: style.fieldPadding,
                      style: style.textStyle,
                      hintStyle: style.hintStyle,
                      validator: Validators.email,
                      autofillHints: const [AutofillHints.email],
                      prefixIcon: AuthFormStyle.icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.42,
                    end: 0.64,
                    slideBegin: const Offset(0, 0.08),
                    child: CustomPasswordField(
                      controller: controller.passwordController,
                      hintText: 'Password',
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
                      prefixIcon: AuthFormStyle.icon(Icons.lock_outline_rounded),
                    ),
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.50,
                    end: 0.72,
                    slideBegin: const Offset(0, 0.08),
                    child: CustomPasswordField(
                      controller: controller.confirmPasswordController,
                      hintText: 'Confirm Password',
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
                          controller.submitSignup();
                        }
                      },
                      prefixIcon:
                          AuthFormStyle.icon(Icons.lock_outline_rounded),
                    ),
                  ),
                  SizedBox(height: AppSpacing.large.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.58,
                    end: 0.80,
                    scaleBegin: 0.96,
                    slideBegin: const Offset(0, 0.10),
                    child: Obx(
                      () => AuthPrimaryButton(
                        text: 'Create Account',
                        enabled: controller.canSubmit,
                        onPressed: controller.submitSignup,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.large.h),
                  AuthSocialRow(
                    animation: _entrance,
                    onGoogle: controller.onGoogleSignup,
                    onApple: controller.onAppleSignup,
                    onFacebook: controller.onFacebookSignup,
                    dividerBegin: 0.66,
                    dividerEnd: 0.86,
                    firstBegin: 0.72,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.medium.h),
            AuthStaggeredEntrance(
              animation: _entrance,
              begin: 0.84,
              end: 1,
              slideBegin: const Offset(0, 0.08),
              child: AuthFooterPrompt(
                leading: 'Already have an account?',
                actionLabel: 'Login',
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
