import 'package:get/get.dart';

import '../controller/subscription_controller.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionController>(SubscriptionController.new);
  }
}
