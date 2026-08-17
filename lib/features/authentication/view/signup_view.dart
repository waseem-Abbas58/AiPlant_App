import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _entrance;
  late final SignupController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<SignupController>();
    _nameController.addListener(_syncName);
    _emailController.addListener(_syncEmail);
    _passwordController.addListener(_syncPassword);
    _syncName();
    _syncEmail();
    _syncPassword();
    _entrance = AnimationController(
      vsync: this,
      duration: _entranceDuration,
    )..forward();
  }

  void _syncName() => _auth.syncName(_nameController.text);

  void _syncEmail() => _auth.syncEmail(_emailController.text);

  void _syncPassword() => _auth.syncPassword(_passwordController.text);

  @override
  void dispose() {
    _nameController
      ..removeListener(_syncName)
      ..dispose();
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

    return _SignupScaffold(
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
              child: const AuthLogo(width: AppSizes.imageLg),
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
                    begin: 0.14,
                    end: 0.36,
                    scaleBegin: 0.98,
                    slideBegin: const Offset(0, 0.10),
                    child: CustomText(
                      'Create Your Account',
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
                    child: AuthFieldSurface(
                      child: CustomTextField(
                      controller: _nameController,
                      hintText: 'Full Name',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      isDense: true,
                      fillColor: AuthFormStyle.fill,
                      enabledBorderColor: AuthFormStyle.enabledBorder,
                      enabledBorderWidth: AuthFormStyle.enabledBorderWidth,
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
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.34,
                    end: 0.56,
                    slideBegin: const Offset(0, 0.08),
                    child: AuthFieldSurface(
                      child: CustomTextField(
                      controller: _emailController,
                      hintText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      isDense: true,
                      fillColor: AuthFormStyle.fill,
                      enabledBorderColor: AuthFormStyle.enabledBorder,
                      enabledBorderWidth: AuthFormStyle.enabledBorderWidth,
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
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.42,
                    end: 0.64,
                    slideBegin: const Offset(0, 0.08),
                    child: AuthFieldSurface(
                      child: CustomPasswordField(
                      controller: _passwordController,
                      hintText: 'Password',
                      textInputAction: TextInputAction.done,
                      isDense: true,
                      fillColor: AuthFormStyle.fill,
                      enabledBorderColor: AuthFormStyle.enabledBorder,
                      enabledBorderWidth: AuthFormStyle.enabledBorderWidth,
                      focusedBorderColor: AuthFormStyle.focus,
                      cursorColor: AuthFormStyle.focus,
                      borderRadius: AuthFormStyle.fieldRadius,
                      contentPadding: style.fieldPadding,
                      style: style.textStyle,
                      hintStyle: style.hintStyle,
                      validator: Validators.password,
                      autofillHints: const [AutofillHints.newPassword],
                      onSubmitted: (_) {
                        if (controller.canSubmit) {
                          controller.submitSignup();
                        }
                      },
                      prefixIcon: AuthFormStyle.icon(Icons.lock_outline_rounded),
                    ),
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
                  SizedBox(height: AppSpacing.medium.h),
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

class _SignupScaffold extends StatelessWidget {
  const _SignupScaffold({required this.child});

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
                image: AssetImage('assets/images/loginimage.png'),
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
