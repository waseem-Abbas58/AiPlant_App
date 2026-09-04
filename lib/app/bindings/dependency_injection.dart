import 'package:get/get.dart';

import '../../core/config/plant_api_config.dart';
import '../../features/plant_scan/data/api_plant_identify_repository.dart';
import '../../features/plant_scan/data/plant_identify_repository.dart';

class DependencyInjection {
  DependencyInjection._();

  static void init() {
    final config = PlantApiConfig.fromEnvironment();
    Get.put<PlantIdentifyRepository>(
      config.hasRemote
          ? ApiPlantIdentifyRepository(config: config)
          : LocalPlantIdentifyRepository(),
      permanent: true,
    );
  }
}
