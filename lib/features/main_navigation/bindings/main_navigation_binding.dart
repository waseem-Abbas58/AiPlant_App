import 'package:get/get.dart';
import '../../chatbot/bindings/chatbot_binding.dart';
import '../../home/bindings/home_binding.dart';
import '../../my_garden/bindings/my_garden_binding.dart';
import '../../plant_scan/bindings/plant_scan_binding.dart';
import '../../profile/bindings/profile_binding.dart';
import '../controller/main_navigation_controller.dart';
class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(MainNavigationController.new);
    HomeBinding().dependencies();
    MyGardenBinding().dependencies(); 
    PlantScanBinding().dependencies();
    ChatbotBinding().dependencies();
    ProfileBinding().dependencies(); 
  }
}
