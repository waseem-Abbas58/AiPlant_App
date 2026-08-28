import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/validators/validators.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controller/forgot_password_controller.dart';
import '../widgets/auth_shared_widgets.dart'; 
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});
  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView>
    with SingleTickerProviderStateMixin {
  static final Duration _entranceDuration =
      AppDurations.slow + AppDurations.medium;

  final TextEditingController _emailController = TextEditingController();

  late final AnimationController _entrance;
  late final ForgotPasswordController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<ForgotPasswordController>();
    _emailController.addListener(_syncEmail);
    _syncEmail();
    _entrance = AnimationController(
      vsync: this,
      duration: _entranceDuration,
    )..forward();
  }

  void _syncEmail() => _auth.syncEmail(_emailController.text);

  @override
  void dispose() {
    _emailController
      ..removeListener(_syncEmail)
      ..dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _auth;
    final textTheme = Theme.of(context).textTheme;
    final style = AuthFormStyle(textTheme);

    return _ForgotPasswordScaffold(
      child: AutofillGroup(
      child: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
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
            SizedBox(height: AppSpacing.small.h),
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
                      'Forgot Password?', 
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
                    child: CustomText(
                      "Enter your email and we'll send you a 6-digit verification code.",
                      style: textTheme.bodyMedium?.copyWith(height: 1.4),
                      color: AppColors.secondaryText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.34,
                    end: 0.62,
                    slideBegin: const Offset(0, 0.08),
                    child: AuthFieldSurface(
                      child: CustomTextField(
                      controller: _emailController,
                      hintText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
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
                      onSubmitted: (_) {
                        if (controller.canSubmit) {
                          controller.submitResetRequest();
                        }
                      },
                      prefixIcon:
                          AuthFormStyle.icon(Icons.mail_outline_rounded),
                    ),
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
                        text: 'Send Verification Code',
                        enabled: controller.canSubmit,
                        onPressed: controller.submitResetRequest,
                      ),
                    ),
                  ),
                ],
              ), 
            ),
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

class _ForgotPasswordScaffold extends StatelessWidget {
  const _ForgotPasswordScaffold({required this.child});

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
