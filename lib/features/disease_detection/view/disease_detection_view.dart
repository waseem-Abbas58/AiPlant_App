import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/disease_detection_controller.dart';

class DiseaseDetectionView extends GetView<DiseaseDetectionController> {
  const DiseaseDetectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
