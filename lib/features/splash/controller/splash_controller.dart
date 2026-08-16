import 'dart:async';
import 'package:get/get.dart';
import '../../../app/config/app_config.dart';
import '../../../app/routes/route_names.dart';
import '../../../core/helpers/navigation_helper.dart';

class SplashController extends GetxController {
  Timer? _navigationTimer;
  @override
  void onInit() {
    super.onInit();
    _startSplashFlow();
  }

  void _startSplashFlow() {
    _navigationTimer = Timer(AppConfig.splashDuration, _navigateNext);
  }

  void _navigateNext() {
    NavigationHelper.offAllNamed(RouteNames.onboarding);
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    super.onClose();
  }
}
