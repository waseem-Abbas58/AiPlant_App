import 'package:get/get.dart';

import '../controller/plant_finder_controller.dart';

class PlantFinderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlantFinderController>(PlantFinderController.new);
  }
}
