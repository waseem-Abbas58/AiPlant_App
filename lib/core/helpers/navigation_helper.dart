import 'package:get/get.dart';

class NavigationHelper {
  NavigationHelper._();

  static Future<T?>? toNamed<T>(
    String route, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    return Get.toNamed<T>(
      route,
      arguments: arguments,
      parameters: parameters,
    );
  }

  static Future<T?>? offNamed<T>(
    String route, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    return Get.offNamed<T>(
      route,
      arguments: arguments,
      parameters: parameters,
    );
  }

  static Future<T?>? offAllNamed<T>(
    String route, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    return Get.offAllNamed<T>(
      route,
      arguments: arguments,
      parameters: parameters,
    );
  }

  static void back<T>([T? result]) {
    Get.back<T>(result: result);
  }

  static void until(String routeName) {
    Get.until((route) => route.settings.name == routeName);
  }
}
