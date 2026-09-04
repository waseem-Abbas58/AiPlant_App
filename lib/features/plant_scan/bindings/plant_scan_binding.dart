import 'package:get/get.dart';

import '../../../core/config/plant_api_config.dart';
import '../controller/plant_scan_controller.dart';
import '../data/api_plant_identify_repository.dart';
import '../data/plant_identify_repository.dart';

class PlantScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlantScanController>(PlantScanController.new);
    if (!Get.isRegistered<PlantIdentifyRepository>()) {
      final config = PlantApiConfig.fromEnvironment();
      Get.put<PlantIdentifyRepository>(
        config.hasRemote
            ? ApiPlantIdentifyRepository(config: config)
            : LocalPlantIdentifyRepository(),
        permanent: true,
      );
    }
  }
}
