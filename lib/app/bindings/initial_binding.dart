import 'package:get/get.dart';

import '../../features/profile/controller/profile_controller.dart';
import 'dependency_injection.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    DependencyInjection.init();
    Get.put<ProfileController>(ProfileController(), permanent: true);
  }
}
