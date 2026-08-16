import 'package:get/get.dart';

import '../controller/my_garden_controller.dart';

class MyGardenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyGardenController>(MyGardenController.new);
  }
}
