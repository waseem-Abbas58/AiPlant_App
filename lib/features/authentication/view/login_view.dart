import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_borders.dart';
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

    return _LoginScaffold(
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
              child: const AuthLogo(width: AppSizes.imageLg),
            ),
            SizedBox(height: AppSpacing.medium.h),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.large.w,
                0,
                AppSpacing.large.w,
                AppSpacing.medium.h, 
              ),
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
                      'Welcome Back',
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
                    child: _LoginFieldSurface(
                      child: CustomTextField(
                        controller: _emailController,
                        hintText: 'Email address',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enableSuggestions: false,
                        isDense: true,
                        fillColor: _LoginFormSurfaces.fieldFill,
                        enabledBorderColor: _LoginFormSurfaces.fieldBorder,
                        enabledBorderWidth: _LoginFormSurfaces.fieldBorderWidth,
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
                    begin: 0.44,
                    end: 0.66,
                    slideBegin: const Offset(0, 0.08),
                    child: _LoginFieldSurface(
                      child: CustomPasswordField(
                        controller: _passwordController,
                        hintText: 'Password',
                        textInputAction: TextInputAction.done,
                        isDense: true,
                        fillColor: _LoginFormSurfaces.fieldFill,
                        enabledBorderColor: _LoginFormSurfaces.fieldBorder,
                        enabledBorderWidth: _LoginFormSurfaces.fieldBorderWidth,
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
                        shadow: _LoginFormSurfaces.primaryButtonShadow,
                        disabledBackgroundColor:
                            _LoginFormSurfaces.disabledButtonFill,
                        disabledTextColor:
                            _LoginFormSurfaces.disabledButtonText,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  AuthSocialRow(
                    animation: _entrance,
                    onGoogle: controller.onGoogleLogin,
                    onApple: controller.onAppleLogin,
                    onFacebook: controller.onFacebookLogin,
                    buttonFill: _LoginFormSurfaces.socialFill,
                    buttonBorderColor: _LoginFormSurfaces.socialBorder,
                    buttonShadow: _LoginFormSurfaces.socialShadow,
                    dividerColor: _LoginFormSurfaces.divider,
                    dividerThickness: _LoginFormSurfaces.dividerThickness,
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

class _LoginScaffold extends StatelessWidget {
  const _LoginScaffold({required this.child});

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
            const Positioned.fill(child: _LoginPremiumBackground()),
            content,
          ],
        ),
      ),
    );
  }
}

class _LoginFieldSurface extends StatelessWidget {
  const _LoginFieldSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AuthFormStyle.fieldRadius.r),
        boxShadow: _LoginFormSurfaces.fieldShadow,
      ),
      child: child,
    );
  }
}

class _LoginFormSurfaces {
  _LoginFormSurfaces._();

  static final Color fieldFill = AuthFormStyle.fill;

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

  static final List<BoxShadow> primaryButtonShadow = [
    BoxShadow(
      color: AppColors.primaryGreen.withValues(alpha: 0.18),
      blurRadius: 14,
      offset: const Offset(0, 5),
    ),
  ];

  static final Color socialFill = AppColors.white.withValues(alpha: 0.90);

  static final Color socialBorder = AppColors.border.withValues(alpha: 0.55);

  static final List<BoxShadow> socialShadow = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final Color divider = AppColors.border.withValues(alpha: 0.58);

  static const double dividerThickness = AppBorders.widthRegular;

  static final Color disabledButtonFill = Color.alphaBlend(
    AppColors.primaryGreen.withValues(alpha: 0.08),
    AppColors.divider,
  );

  static final Color disabledButtonText = AppColors.secondaryText;
}

class _LoginPremiumBackground extends StatelessWidget {
  const _LoginPremiumBackground();

  static final Color _midMint = Color.alphaBlend(
    AppColors.lightGreen.withValues(alpha: 0.07),
    AppColors.background,
  );
  static final Color _softMint = Color.alphaBlend(
    AppColors.lightGreen.withValues(alpha: 0.13),
    AppColors.background,
  );
  static final Color _depthMint = Color.alphaBlend(
    AppColors.lightGreen.withValues(alpha: 0.22),
    AppColors.background,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.white,
                AppColors.white,
                Color.lerp(AppColors.white, AppColors.background, 0.65)!,
                AppColors.background,
                _midMint,
                _softMint,
                _depthMint,
              ], 
              stops: const [0.0, 0.18, 0.34, 0.50, 0.66, 0.82, 1.0],
            ),
          ), 
        ),
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
      ],
    ); 
  }
}
