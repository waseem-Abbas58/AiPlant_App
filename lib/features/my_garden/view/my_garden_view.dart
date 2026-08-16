import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/my_garden_controller.dart';

class MyGardenView extends GetView<MyGardenController> {
  const MyGardenView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
