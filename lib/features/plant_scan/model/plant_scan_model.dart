import 'package:flutter/material.dart';

class ScanCategory {
  const ScanCategory({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;

  static const all = <ScanCategory>[
    ScanCategory(id: 'plant', label: 'Plant', icon: Icons.eco_rounded),
    ScanCategory(
      id: 'mushroom',
      label: 'Mushroom',
      icon: Icons.spa_outlined,
    ),
    ScanCategory(id: 'weed', label: 'Weed', icon: Icons.grass_rounded),
    ScanCategory(
      id: 'disease',
      label: 'Disease',
      icon: Icons.coronavirus_outlined,
    ),
    ScanCategory(id: 'tree', label: 'Tree', icon: Icons.park_rounded),
  ];

  String get identifyHint => switch (id) {
        'mushroom' => 'Fill the frame with the cap and stem',
        'weed' => 'Fill the frame with the whole weed',
        'disease' => 'Fill the frame with a damaged leaf',
        'tree' => 'Fill the frame with a leaf or bark',
        _ => '',
      };
}

