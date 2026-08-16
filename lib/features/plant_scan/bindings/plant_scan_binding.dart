import 'package:get/get.dart';

import '../controller/plant_scan_controller.dart';

class PlantScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlantScanController>(PlantScanController.new);
  }
}
