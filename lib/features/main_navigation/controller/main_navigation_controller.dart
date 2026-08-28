import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  static const int initialTabIndex = 0;
  static const int homeIndex = 0;
  static const int gardenIndex = 1;
  static const int scanIndex = 2;
  static const int chatIndex = 3;
  static const int profileIndex = 4;

  final RxInt selectedIndex = initialTabIndex.obs;
  int _tabBeforeChat = homeIndex;

  void onTabTapped(int index) {
    if (index == chatIndex && selectedIndex.value != chatIndex) {
      _tabBeforeChat = selectedIndex.value;
    }
    selectedIndex.value = index;
  }

  bool goBackFromChat() {
    if (selectedIndex.value != chatIndex) return false;
    final backTo =
        _tabBeforeChat == chatIndex ? homeIndex : _tabBeforeChat;
    selectedIndex.value = backTo;
    return true;
  }
}
