import 'package:get/get.dart';

import '../../../app/config/app_config.dart';
import '../../../core/helpers/app_session.dart';
import '../../../core/helpers/navigation_helper.dart';

class SplashController extends GetxController {
  var _closed = false;

  @override
  void onInit() {
    super.onInit();
    _startSplashFlow();
  }

  Future<void> _startSplashFlow() async {
    final wait = Future<void>.delayed(AppConfig.splashDuration);
    final next = await AppSession.nextRoute();
    await wait;
    if (_closed) return;
    NavigationHelper.offAllNamed(next);
  }

  @override
  void onClose() {
    _closed = true;
    super.onClose();
  }
}
