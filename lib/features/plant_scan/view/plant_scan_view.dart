import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/plant_scan_controller.dart';

class PlantScanView extends GetView<PlantScanController> {
  const PlantScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
