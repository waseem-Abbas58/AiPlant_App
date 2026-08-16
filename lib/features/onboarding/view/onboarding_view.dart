import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_sizes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controller/onboarding_controller.dart';
import '../widgets/onboarding_care_page.dart';
import '../widgets/onboarding_disease_page.dart';
import '../widgets/onboarding_garden_page.dart';
import '../widgets/onboarding_identify_page.dart';
import '../widgets/onboarding_page_indicator.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final pageView = PageView(
      controller: controller.pageController,
      onPageChanged: controller.onPageChanged,
      physics: const BouncingScrollPhysics(),
      children: const [
        OnboardingIdentifyPage(),
        OnboardingDiseasePage(),
        OnboardingCarePage(),
        OnboardingGardenPage(),
      ],
    );

    return Obx(() {
      final isHeroPage = controller.currentPage.value <= 3;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemStatusBarContrastEnforced: false,
        ),
        child: Scaffold(
          backgroundColor:
              isHeroPage ? AppColors.black : AppColors.background,
          body: Column(
            children: [
              SizedBox(height: isHeroPage ? 0 : topInset),
              SizedBox(
                height: isHeroPage ? 0 : AppSizes.appBarHeight.h,
                child: isHeroPage
                    ? null
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: _OnboardingBackButton(
                          onPressed: controller.previousPage,
                          color: AppColors.primaryText,
                        ),
                      ),
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    pageView,
                    if (isHeroPage && controller.currentPage.value > 0)
                      Positioned(
                        top: topInset,
                        left: 0,
                        child: _OnboardingBackButton(
                          onPressed: controller.previousPage,
                          color: AppColors.white,
                        ),
                      ),
                  ],
                ),
              ),
              if (isHeroPage)
                const SizedBox.shrink()
              else
                _OnboardingFooter(controller: controller),
            ],
          ),
        ),
      );
    });
  }
}

class _OnboardingBackButton extends StatelessWidget {
  const _OnboardingBackButton({
    required this.onPressed,
    required this.color,
  });

  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: AppStrings.back,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      icon: Icon(
        Icons.arrow_back,
        size: AppSizes.iconMd.sp,
        color: color,
      ),
    );
  }
}

class _OnboardingFooter extends StatefulWidget {
  const _OnboardingFooter({required this.controller});

  final OnboardingController controller;

  @override
  State<_OnboardingFooter> createState() => _OnboardingFooterState();
}

class _OnboardingFooterState extends State<_OnboardingFooter>
    with TickerProviderStateMixin {
  static const String _getStartedLabel = 'Get Started';

  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  late final AnimationController _ctaController;
  late final CurvedAnimation _ctaCurve;
  late final Animation<double> _ctaFade;
  late final Animation<Offset> _ctaSlide;

  Worker? _pageWorker;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
    );

    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(_curve);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(_curve);

    _ctaController = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
      value: 1,
    );

    _ctaCurve = CurvedAnimation(
      parent: _ctaController,
      curve: Curves.easeOutCubic,
    );

    _ctaFade = Tween<double>(begin: 0, end: 1).animate(_ctaCurve);
    _ctaSlide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(_ctaCurve);

    Future<void>.delayed(AppDurations.medium, () {
      if (mounted) {
        _controller.forward();
      }
    });

    _pageWorker = ever<int>(widget.controller.currentPage, (index) {
      if (index == OnboardingController.totalPages - 1) {
        _ctaController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _pageWorker?.dispose();
    _ctaCurve.dispose();
    _ctaController.dispose();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.large.w,
            AppSpacing.medium.h,
            AppSpacing.large.w,
            AppSpacing.large.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => OnboardingPageIndicator(
                  pageCount: OnboardingController.totalPages,
                  currentIndex: widget.controller.currentPage.value,
                ),
              ),
              SizedBox(height: AppSpacing.large.h),
              FadeTransition(
                opacity: _ctaFade,
                child: SlideTransition(
                  position: _ctaSlide,
                  child: Obx(
                    () {
                      final isLast = widget.controller.isLastPage;
                      return CustomButton(
                        text: isLast
                            ? _getStartedLabel
                            : AppStrings.continueLabel,
                        onPressed: isLast
                            ? widget.controller.completeOnboarding
                            : widget.controller.nextPage,
                        backgroundColor: AppColors.primaryGreen,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
