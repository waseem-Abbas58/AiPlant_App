import 'package:get/get.dart';

import '../controller/chatbot_controller.dart';

class ChatbotBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ChatbotController>()) {
      Get.put(ChatbotController(), permanent: true);
    }
  }
}
