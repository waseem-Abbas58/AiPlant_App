import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/helpers/navigation_helper.dart';

class OnboardingController extends GetxController {
  static const int totalPages = 4;

  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  bool get isLastPage => currentPage.value >= totalPages - 1;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (isLastPage || !pageController.hasClients) return;

    pageController.nextPage(
      duration: AppDurations.pageTransition,
      curve: Curves.easeOutCubic,
    );
  }

  void previousPage() {
    if (currentPage.value <= 0 || !pageController.hasClients) return;

    pageController.previousPage(
      duration: AppDurations.pageTransition,
      curve: Curves.easeOutCubic,
    );
  }

  void completeOnboarding() {
    NavigationHelper.offAllNamed(RouteNames.authentication);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
