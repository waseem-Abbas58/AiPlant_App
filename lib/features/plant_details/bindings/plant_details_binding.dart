import 'package:get/get.dart';

import '../controller/plant_details_controller.dart';

class PlantDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlantDetailsController>(PlantDetailsController.new);
  }
}
