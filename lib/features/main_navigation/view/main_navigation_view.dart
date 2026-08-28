import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_icons.dart';
import '../../../shared/widgets/custom_bottom_navigation.dart';
import '../../../shared/widgets/custom_svg.dart';
import '../../chatbot/data/botanist_navigator.dart';
import '../../chatbot/view/chatbot_view.dart';
import '../../chatbot/widgets/ask_ai_fab.dart';
import '../../home/view/home_view.dart';
import '../../my_garden/view/my_garden_view.dart';
import '../../plant_scan/view/plant_scan_view.dart';
import '../../profile/view/profile_view.dart';
import '../controller/main_navigation_controller.dart';
class MainNavigationView extends GetView<MainNavigationController> {
  const MainNavigationView({super.key});
  static const List<Widget> _screens = [
    HomeView(),
    MyGardenView(),
    PlantScanView(),
    ChatbotView(),
    ProfileView(), 
  ];

  static Widget _navSvg(String assetPath, String label) {
    return CustomSVG(
      assetPath: assetPath,
      semanticsLabel: label,
    );
  }
 
  static final List<BottomNavigationBarItem> _items = [
    BottomNavigationBarItem(
      icon: _navSvg(AppIcons.home, 'Home'),
      label: 'Home',
    ),
    BottomNavigationBarItem( 
      icon: _navSvg(AppIcons.garden, 'Garden'),  
      label: 'Garden',
    ),
    BottomNavigationBarItem(
      icon: _navSvg(AppIcons.scan, 'Scan'),
      label: 'Scan',
    ),
    BottomNavigationBarItem(
      icon: _navSvg(AppIcons.chat, 'Chat'),
      label: 'Chat',
    ),
    BottomNavigationBarItem(
      icon: _navSvg(AppIcons.profile, 'Profile'),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.selectedIndex.value;
      final hideNav = index == MainNavigationController.chatIndex ||
          index == MainNavigationController.scanIndex;

      return PopScope(
        canPop: !hideNav,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (index == MainNavigationController.chatIndex) {
            controller.goBackFromChat();
          } else if (index == MainNavigationController.scanIndex) {
            controller.onTabTapped(MainNavigationController.homeIndex);
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemStatusBarContrastEnforced: false,
        ),
        child: Scaffold(
          body: Stack(
            children: [
              IndexedStack(
                index: index,
                children: _screens,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSlide(
                  offset: hideNav ? const Offset(0, 1) : Offset.zero,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: hideNav ? 0 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: IgnorePointer(
                      ignoring: hideNav,
                      child: CustomBottomNavigation(
                        currentIndex: index,
                        onTap: controller.onTabTapped,
                        items: _items,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16.w,
                bottom: MediaQuery.paddingOf(context).bottom + 56.h + 8.h,
                child: AnimatedOpacity(
                  opacity: !hideNav &&
                          (index == MainNavigationController.homeIndex ||
                              index == MainNavigationController.gardenIndex)
                      ? 1
                      : 0,
                  duration: const Duration(milliseconds: 180),
                  child: IgnorePointer(
                    ignoring: hideNav ||
                        (index != MainNavigationController.homeIndex &&
                            index != MainNavigationController.gardenIndex),
                    child: AskAiFab(onTap: () => openBotanistChat()),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      );
    });
  }
}
