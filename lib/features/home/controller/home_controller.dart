import 'package:get/get.dart';

class HomeController extends GetxController {
  final showAllPlantTools = false.obs;
  final showAllCategories = false.obs;

  void togglePlantTools() => showAllPlantTools.toggle();
  void toggleCategories() => showAllCategories.toggle();
}
