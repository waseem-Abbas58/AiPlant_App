import 'package:get/get.dart';

import '../controller/reminder_controller.dart';

class ReminderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReminderController>(ReminderController.new);
  }
}
