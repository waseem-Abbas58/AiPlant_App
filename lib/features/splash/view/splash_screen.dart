import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_sizes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/splash_controller.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String _logoLottie = 'assets/lottie/splash.json';
  static const String _bottomArtwork = 'assets/images/splash/splash_bottom.png'; 

  late final AnimationController _textController;
  late final CurvedAnimation _textCurve;
  late final Animation<double> _textFade;
  late final Animation<double> _textScale;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    // Ensure SplashController is created (lazy binding) for preview/nav timer.
    Get.find<SplashController>();

    _textController = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    );

    _textCurve = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(_textCurve);
    _textScale = Tween<double>(begin: 0.94, end: 1).animate(_textCurve);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.28),
      end: Offset.zero,
    ).animate(_textCurve);

    // Text starts shortly after the Lottie begins playing.
    Future<void>.delayed(AppDurations.medium, () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  @override
  void dispose() {
    _textCurve.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { 
    final textTheme = Theme.of(context).textTheme;
    final logoSize = AppSizes.imageXl.w;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0, 
            right: 0,
            bottom: 0,
            child: Image.asset(
              _bottomArtwork,
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
              color: AppColors.background,
              colorBlendMode: BlendMode.darken,
            ),
          ),
          SafeArea(
            child: Center( 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    _logoLottie,
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.contain,
                    // Composition is 3.333s @ 30fps. Play once and hold the final frame.
                    repeat: false,
                    animate: true,
                  ),
                  SizedBox(height: AppSpacing.large.h),
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: ScaleTransition(
                        scale: _textScale,
                        child: CustomText(
                          AppStrings.appName,
                          style: textTheme.headlineLarge,
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
