import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/onboarding_controller.dart';
import '../model/onboarding_model.dart';
import 'onboarding_content_card.dart';
import 'onboarding_page_indicator.dart';

class OnboardingDiseasePage extends StatefulWidget {
  const OnboardingDiseasePage({
    super.key,
    this.data = OnboardingModel.diseaseDetection,
  });

  final OnboardingModel data;

  @override
  State<OnboardingDiseasePage> createState() => _OnboardingDiseasePageState();
}

class _OnboardingDiseasePageState extends State<OnboardingDiseasePage>
    with TickerProviderStateMixin {
  static const int _pageIndex = 1;

  late final AnimationController _entrance;
  late final Animation<double> _imageFade;
  late final Animation<double> _imageScale;
  late final Animation<Offset> _imageSlide;
  late final Animation<double> _headingFade;
  late final Animation<double> _headingScale;
  late final Animation<Offset> _headingSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;

  late final AnimationController _footerController;
  late final CurvedAnimation _footerCurve;
  late final Animation<double> _footerFade;
  late final Animation<Offset> _footerSlide;

  Worker? _pageWorker;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    );

    _imageFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0, 0.50, curve: Curves.easeOutCubic),
      ),
    );
    _imageScale = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0, 0.50, curve: Curves.easeOutCubic),
      ),
    );
    _imageSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    _headingFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.22, 0.68, curve: Curves.easeOutCubic),
      ),
    );
    _headingScale = Tween<double>(begin: 0.97, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.22, 0.68, curve: Curves.easeOutCubic),
      ),
    );
    _headingSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.22, 0.68, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.40, 0.88, curve: Curves.easeOutCubic),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.40, 0.88, curve: Curves.easeOutCubic),
      ),
    );

    _footerController = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
    );
    _footerCurve = CurvedAnimation(
      parent: _footerController,
      curve: Curves.easeOutCubic,
    );
    _footerFade = Tween<double>(begin: 0, end: 1).animate(_footerCurve);
    _footerSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(_footerCurve);

    final onboarding = Get.find<OnboardingController>();
    if (onboarding.currentPage.value == _pageIndex) {
      _playEntrance();
    }
    _pageWorker = ever<int>(onboarding.currentPage, (index) {
      if (index == _pageIndex) {
        _playEntrance();
      }
    });
  }

  void _playEntrance() {
    _footerController
      ..stop()
      ..reset();
    _entrance.forward(from: 0);
    Future<void>.delayed(AppDurations.medium, () {
      if (mounted) {
        _footerController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageWorker?.dispose();
    _footerCurve.dispose();
    _footerController.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final controller = Get.find<OnboardingController>();

    return ColoredBox(
      color: AppColors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: FadeTransition(
              opacity: _imageFade,
              child: SlideTransition(
                position: _imageSlide,
                child: ScaleTransition(
                  scale: _imageScale,
                  child: Image.asset(
                    widget.data.imagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: double.infinity,
                    semanticLabel: widget.data.title,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: OnboardingContentCard(
              heading: FadeTransition(
                opacity: _headingFade,
                child: SlideTransition(
                  position: _headingSlide,
                  child: ScaleTransition(
                    scale: _headingScale,
                    child: CustomText(
                      widget.data.title,
                      style: textTheme.headlineMedium,
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                      maxLines: OnboardingContentCard.headingMaxLines,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
              subtitle: FadeTransition(
                opacity: _subtitleFade,
                child: SlideTransition(
                  position: _subtitleSlide,
                  child: CustomText(
                    widget.data.subtitle,
                    style: textTheme.bodyLarge,
                    color: AppColors.secondaryText,
                    textAlign: TextAlign.center,
                    height: OnboardingContentCard.subtitleLineHeight,
                    maxLines: OnboardingContentCard.subtitleMaxLines,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              footer: FadeTransition(
                opacity: _footerFade,
                child: SlideTransition(
                  position: _footerSlide,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => OnboardingPageIndicator(
                          pageCount: OnboardingController.totalPages,
                          currentIndex: controller.currentPage.value,
                        ),
                      ),
                      SizedBox(height: AppSpacing.large.h),
                      CustomButton(
                        text: AppStrings.continueLabel,
                        onPressed: controller.nextPage,
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
