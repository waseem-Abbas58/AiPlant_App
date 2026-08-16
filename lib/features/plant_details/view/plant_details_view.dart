import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/plant_details_controller.dart';

class PlantDetailsView extends GetView<PlantDetailsController> {
  const PlantDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
