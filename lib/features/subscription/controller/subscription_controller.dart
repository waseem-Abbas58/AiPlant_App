import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  final selectedPlan = 0.obs;

  void selectPlan(int index) {
    selectedPlan.value = index;
  }
}
