import 'package:get/get.dart';

import 'dependency_injection.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    DependencyInjection.init();
  }
}
