import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import '../../../app/theme/app_borders.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_sizes.dart';
import '../../../app/theme/app_spacing.dart'; 
import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_images.dart';  
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_button.dart';  
import '../../../shared/widgets/custom_card.dart'; 
import '../../../shared/widgets/custom_image.dart';
import '../../../shared/widgets/custom_svg.dart';
import '../../../shared/widgets/custom_text.dart';

class AuthFormStyle {
  AuthFormStyle(this.textTheme);

  final TextTheme textTheme;

  static const Color fill = AppColors.background;
  static const Color focus = AppColors.primaryGreen;
  static const double fieldRadius = AppRadius.medium;

  TextStyle? get hintStyle => textTheme.bodyMedium?.copyWith(
        color: AppColors.mutedText,
        height: 1.3,
      );

  TextStyle? get textStyle => textTheme.bodyMedium?.copyWith(
        color: AppColors.primaryText,
        height: 1.3,
      );

  EdgeInsets get fieldPadding => EdgeInsets.symmetric(
        horizontal: AppSpacing.medium.w,
        vertical: AppSpacing.small.h + AppSpacing.extraSmall.h,
      );

  static Widget icon(IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.small.w),
      child: Icon(
        icon,
        size: AppSizes.iconMd.sp,
        color: AppColors.mutedText,
      ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.pinBottomDecoration = true,
  });

  final Widget child;
  final bool pinBottomDecoration;

  static final BoxDecoration _background = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.white,
        AppColors.background,
        AppColors.lightGreen.withValues(alpha: 0.10),
      ],
      stops: const [0, 0.55, 1],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.large.w,
          AppSpacing.extraLarge.h,
          AppSpacing.large.w,
          AppSpacing.large.h,
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
        backgroundColor: AppColors.background,
        extendBody: pinBottomDecoration,
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: DecoratedBox(decoration: _background),
            ),
            content,
          ],
        ),
      ),
    );
  }
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomImage(
        assetPath: AppImages.authLogo,
        width: AppSizes.imageLg + AppSpacing.large,
        fit: BoxFit.contain,
        borderRadius: AppRadius.extraLarge,
        semanticsLabel: AppStrings.appName,
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      borderRadius: AppRadius.extraLarge,
      border: Border.all(
        color: Colors.transparent,
        width: 0,
      ),
      shadow: AppShadows.soft,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.large.w,
        AppSpacing.large.h,
        AppSpacing.large.w,
        AppSpacing.large.h,
      ),
      child: child,
    );
  }
}

class AuthStaggeredEntrance extends StatelessWidget {
  const AuthStaggeredEntrance({
    super.key,
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
    this.slideBegin = Offset.zero,
    this.scaleBegin = 1,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;
  final Offset slideBegin;
  final double scaleBegin;

  @override
  Widget build(BuildContext context) {
    final curve = Interval(begin, end, curve: Curves.easeOutCubic);
    final fade = animation.drive(
      Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: curve)),
    );
    final slide = animation.drive(
      Tween<Offset>(begin: slideBegin, end: Offset.zero)
          .chain(CurveTween(curve: curve)),
    );
    final scale = animation.drive(
      Tween<double>(begin: scaleBegin, end: 1).chain(CurveTween(curve: curve)),
    );

    Widget content = FadeTransition(opacity: fade, child: child);
    if (slideBegin != Offset.zero) {
      content = SlideTransition(position: slide, child: content);
    }
    if (scaleBegin != 1) {
      content = ScaleTransition(scale: scale, child: content);
    }
    return content;
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.enabled,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final bool enabled;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final interactive = enabled && !isLoading;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.large.r),
        boxShadow: interactive ? AppShadows.soft : AppShadows.none,
      ),
      child: CustomButton(
        text: text,
        enabled: enabled || isLoading,
        isLoading: isLoading,
        onPressed: interactive ? onPressed : null,
        backgroundColor: AppColors.primaryGreen,
        disabledBackgroundColor: AppColors.divider,
        disabledTextColor: AppColors.secondaryText,
        borderRadius: AppRadius.large,
        height: AppSizes.buttonHeightLg,
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          height: 1.2,
        ),
      ),
    );
  }
}

class AuthSocialRow extends StatelessWidget {
  const AuthSocialRow({
    super.key,
    required this.animation,
    required this.onGoogle,
    required this.onApple,
    required this.onFacebook,
    this.dividerBegin = 0.64,
    this.dividerEnd = 0.84,
    this.firstBegin = 0.70,
  });

  final Animation<double> animation;
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onFacebook;
  final double dividerBegin;
  final double dividerEnd;
  final double firstBegin;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        AuthStaggeredEntrance(
          animation: animation,
          begin: dividerBegin,
          end: dividerEnd,
          child: _AuthSocialDivider(textTheme: textTheme),
        ),
        SizedBox(height: AppSpacing.medium.h),
        Row(
          children: [
            Expanded(
              child: AuthStaggeredEntrance(
                animation: animation,
                begin: firstBegin,
                end: firstBegin + 0.18,
                scaleBegin: 0.96,
                child: _AuthSocialButton(
                  assetPath: AppIcons.google,
                  label: 'Google',
                  onPressed: onGoogle,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.small.w),
            Expanded(
              child: AuthStaggeredEntrance(
                animation: animation,
                begin: firstBegin + 0.04,
                end: firstBegin + 0.22,
                scaleBegin: 0.96,
                child: _AuthSocialButton(
                  assetPath: AppIcons.apple,
                  label: 'Apple',
                  onPressed: onApple,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.small.w),
            Expanded(
              child: AuthStaggeredEntrance(
                animation: animation,
                begin: firstBegin + 0.08,
                end: firstBegin + 0.26,
                scaleBegin: 0.96,
                child: _AuthSocialButton(
                  assetPath: AppIcons.facebook,
                  label: 'Facebook',
                  onPressed: onFacebook,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthSocialDivider extends StatelessWidget {
  const _AuthSocialDivider({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.border.withValues(alpha: 0.8),
            thickness: AppBorders.widthThin,
            height: AppBorders.widthThin,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium.w),
          child: CustomText(
            'Or continue with',
            style: textTheme.bodySmall?.copyWith(
              height: 1.2,
              letterSpacing: 0.2,
            ),
            color: AppColors.secondaryText,
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.border.withValues(alpha: 0.8),
            thickness: AppBorders.widthThin,
            height: AppBorders.widthThin,
          ),
        ),
      ],
    );
  }
}

class _AuthSocialButton extends StatefulWidget {
  const _AuthSocialButton({
    required this.assetPath,
    required this.label,
    required this.onPressed,
  });

  final String assetPath;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_AuthSocialButton> createState() => _AuthSocialButtonState();
}

class _AuthSocialButtonState extends State<_AuthSocialButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.large.r);

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: AppDurations.normal,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.92 : 1,
          duration: AppDurations.normal,
          curve: Curves.easeOutCubic,
          child: Material(
            color: AppColors.surface,
            elevation: 0,
            shadowColor: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: radius,
              child: Ink(
                height: AppSizes.buttonHeightMd.h,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: radius,
                  border: Border.all(
                    color: AppColors.border,
                    width: AppBorders.widthThin,
                  ),
                  boxShadow: AppShadows.soft,
                ),
                child: Center(
                  child: CustomSVG(
                    assetPath: widget.assetPath,
                    width: AppSizes.iconMd,
                    height: AppSizes.iconMd,
                    semanticsLabel: widget.label,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthFooterPrompt extends StatelessWidget {
  const AuthFooterPrompt({
    super.key,
    required this.leading,
    required this.actionLabel,
    required this.onAction,
  });

  final String leading;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading.isNotEmpty)
          CustomText(
            leading,
            style: textTheme.bodyMedium?.copyWith(height: 1.3),
            color: AppColors.secondaryText,
          ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryGreen,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.small.w,
              vertical: AppSpacing.small.h,
            ),
            minimumSize: Size(AppSizes.iconXl.w, AppSizes.iconXl.h),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: CustomText(
            actionLabel,
            style: textTheme.labelLarge?.copyWith(height: 1.2),
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
