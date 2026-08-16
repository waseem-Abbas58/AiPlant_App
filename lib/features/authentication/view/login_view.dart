import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_sizes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/validators/validators.dart';
import '../../../shared/widgets/custom_password_field.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controller/authentication_controller.dart';
import '../widgets/auth_shared_widgets.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  static final Duration _entranceDuration =
      AppDurations.slow + AppDurations.medium;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _entrance;
  late final AuthenticationController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthenticationController>();
    _emailController.addListener(_syncEmail);
    _passwordController.addListener(_syncPassword);
    _syncEmail();
    _syncPassword();
    _entrance = AnimationController(
      vsync: this,
      duration: _entranceDuration,
    )..forward();
  }

  void _syncEmail() => _auth.syncEmail(_emailController.text);

  void _syncPassword() => _auth.syncPassword(_passwordController.text);

  void _submitLogin() {
    _auth.submitLogin(_formKey);
  }

  @override
  void dispose() {
    _emailController
      ..removeListener(_syncEmail)
      ..dispose();
    _passwordController
      ..removeListener(_syncPassword)
      ..dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _auth;
    final textTheme = Theme.of(context).textTheme;
    final style = AuthFormStyle(textTheme);

    return AuthScaffold(
      child: AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthStaggeredEntrance(
              animation: _entrance,
              begin: 0,
              end: 0.28,
              scaleBegin: 0.85,
              child: const AuthLogo(),
            ),
            SizedBox(height: AppSpacing.extraLarge.h),
            AuthCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.18,
                    end: 0.42,
                    scaleBegin: 0.98,
                    slideBegin: const Offset(0, 0.10),
                    child: CustomText(
                      'Welcome Back 👋',
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
                    begin: 0.28,
                    end: 0.50,
                    slideBegin: const Offset(0, 0.08),
                    child: CustomText(
                      'Sign in to continue to AI PlantApp',
                      style: textTheme.bodyMedium?.copyWith(height: 1.4),
                      color: AppColors.secondaryText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.36,
                    end: 0.58,
                    slideBegin: const Offset(0, 0.08),
                    child: CustomTextField(
                      controller: _emailController,
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
                    begin: 0.44,
                    end: 0.66,
                    slideBegin: const Offset(0, 0.08),
                    child: CustomPasswordField(
                      controller: _passwordController,
                      hintText: 'Password',
                      textInputAction: TextInputAction.done,
                      isDense: true,
                      fillColor: AuthFormStyle.fill,
                      focusedBorderColor: AuthFormStyle.focus,
                      cursorColor: AuthFormStyle.focus,
                      borderRadius: AuthFormStyle.fieldRadius,
                      contentPadding: style.fieldPadding,
                      style: style.textStyle,
                      hintStyle: style.hintStyle,
                      validator: Validators.password,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) {
                        if (controller.canSubmit) {
                          _submitLogin();
                        }
                      },
                      prefixIcon: AuthFormStyle.icon(Icons.lock_outline_rounded),
                    ),
                  ), 
                   SizedBox(height: AppSpacing.small.h),
AuthStaggeredEntrance(
  animation: _entrance,
  begin: 0.50,
  end: 0.70,
  slideBegin: const Offset(0, 0.06),
  child: Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: controller.onForgotPassword,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: CustomText(
        'Forgot Password?',
        style: textTheme.labelMedium?.copyWith(height: 1.2),
        color: AppColors.primaryGreen,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),
 SizedBox(height: AppSpacing.large.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.56,
                    end: 0.78,
                    scaleBegin: 0.96,
                    slideBegin: const Offset(0, 0.10),
                    child: Obx(
                      () => AuthPrimaryButton(
                        text: 'Login',
                        enabled: controller.canSubmit,
                        onPressed: _submitLogin,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  AuthSocialRow(
                    animation: _entrance,
                    onGoogle: controller.onGoogleLogin,
                    onApple: controller.onAppleLogin,
                    onFacebook: controller.onFacebookLogin,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.small.h), 
            AuthStaggeredEntrance(
              animation: _entrance,
              begin: 0.84,
              end: 1,
              slideBegin: const Offset(0, 0.08),
              child: AuthFooterPrompt(
                leading: "Don't have an account?",
                actionLabel: 'Sign Up',
                onAction: controller.onSignUp,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
