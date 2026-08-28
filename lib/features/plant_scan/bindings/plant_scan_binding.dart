import 'package:get/get.dart';

import '../controller/plant_scan_controller.dart';
import '../data/plant_identify_repository.dart';

class PlantScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlantScanController>(PlantScanController.new);
    Get.lazyPut<PlantIdentifyRepository>(
      LocalPlantIdentifyRepository.new,
      fenix: true,
    );
  }
}
