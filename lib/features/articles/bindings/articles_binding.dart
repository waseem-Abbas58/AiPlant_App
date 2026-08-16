import 'package:get/get.dart';

import '../controller/articles_controller.dart';

class ArticlesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArticlesController>(ArticlesController.new);
  }
}
