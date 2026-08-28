import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_borders.dart';
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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();
  late final AnimationController _entrance;
  late final ResetPasswordController _auth;
  @override
  void initState() {
    super.initState();
    _auth = Get.find<ResetPasswordController>();
    _passwordController.addListener(_syncPassword);
    _confirmPasswordController.addListener(_syncConfirmPassword);
    _syncPassword();
    _syncConfirmPassword();
    _entrance = AnimationController(
      vsync: this,
      duration: _entranceDuration,
    )..forward();
  }

  void _syncPassword() => _auth.syncPassword(_passwordController.text);

  void _syncConfirmPassword() =>
      _auth.syncConfirmPassword(_confirmPasswordController.text);

  void _submitReset() {
    if (!_auth.canSubmit) return;
    _passwordFocus.unfocus();
    _confirmFocus.unfocus();
    _auth.submitReset();
  }

  @override
  void dispose() {
    _passwordController
      ..removeListener(_syncPassword)
      ..dispose();
    _confirmPasswordController
      ..removeListener(_syncConfirmPassword)
      ..dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _entrance.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final controller = _auth;
    final textTheme = Theme.of(context).textTheme;
    final style = AuthFormStyle(textTheme);
    return _ResetPasswordScaffold(
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
                      'Reset Password',
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
                    child: _ResetPasswordFieldSurface(
                      child: CustomPasswordField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        hintText: 'New Password',
                        textInputAction: TextInputAction.next,
                        isDense: true,
                        fillColor: AuthFormStyle.fill,
                        enabledBorderColor: _ResetPasswordSurfaces.fieldBorder,
                        enabledBorderWidth: _ResetPasswordSurfaces.fieldBorderWidth,
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
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  AuthStaggeredEntrance(
                    animation: _entrance,
                    begin: 0.44,
                    end: 0.70,
                    slideBegin: const Offset(0, 0.08),
                    child: _ResetPasswordFieldSurface(
                      child: CustomPasswordField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmFocus,
                        hintText: 'Confirm New Password',
                        textInputAction: TextInputAction.done,
                        isDense: true,
                        fillColor: AuthFormStyle.fill,
                        enabledBorderColor: _ResetPasswordSurfaces.fieldBorder,
                        enabledBorderWidth: _ResetPasswordSurfaces.fieldBorderWidth,
                        focusedBorderColor: AuthFormStyle.focus,
                        cursorColor: AuthFormStyle.focus,
                        borderRadius: AuthFormStyle.fieldRadius,
                        contentPadding: style.fieldPadding,
                        style: style.textStyle,
                        hintStyle: style.hintStyle,
                        validator: (value) => Validators.confirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        autofillHints: const [AutofillHints.newPassword],
                        onSubmitted: (_) {
                          if (controller.canSubmit) {
                            _submitReset();
                          }
                        },
                        prefixIcon:
                            AuthFormStyle.icon(Icons.lock_outline_rounded),
                      ),
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
                        onPressed: _submitReset,
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

class _ResetPasswordFieldSurface extends StatelessWidget {
  const _ResetPasswordFieldSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AuthFormStyle.fieldRadius.r),
        boxShadow: _ResetPasswordSurfaces.fieldShadow,
      ),
      child: child,
    );
  }
}

class _ResetPasswordSurfaces {
  _ResetPasswordSurfaces._();

  static final Color fieldBorder =
      AppColors.border.withValues(alpha: 0.52);

  static const double fieldBorderWidth = AppBorders.widthRegular;

  static final List<BoxShadow> fieldShadow = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 1),
    ),
  ];
}

class _ResetPasswordScaffold extends StatelessWidget {
  const _ResetPasswordScaffold({required this.child});

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
                image: AssetImage('assets/images/RESET_PASSWORD_IMAGE.png'),
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
