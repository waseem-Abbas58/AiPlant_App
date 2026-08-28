import 'package:get/get.dart';

import '../../main_navigation/controller/main_navigation_controller.dart';
import '../controller/chatbot_controller.dart';
import '../model/chat_message.dart';

void openBotanistChat({
  String? plantName,
  String? imagePath,
  bool isAssetImage = false,
  String? plantId,
}) {
  if (!Get.isRegistered<ChatbotController>()) {
    Get.put(ChatbotController(), permanent: true);
  }

  final name = plantName?.trim() ?? '';
  if (name.isNotEmpty) {
    Get.find<ChatbotController>().startForPlant(
      ChatPlantContext(
        name: name,
        imagePath: imagePath,
        isAssetImage: isAssetImage,
        plantId: plantId,
      ),
    );
  }

  final navigator = Get.key.currentState;
  if (navigator != null && navigator.canPop()) {
    navigator.popUntil((route) => route.isFirst);
  }

  if (!Get.isRegistered<MainNavigationController>()) return;
  Get.find<MainNavigationController>()
      .onTabTapped(MainNavigationController.chatIndex);
}
