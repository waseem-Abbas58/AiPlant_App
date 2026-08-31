import 'package:flutter/material.dart';

import '../../plant_scan/model/plant_identify_result.dart';
import 'trending_plant.dart';

const _previewCare = <String,
    (
      String,
      String,
      String,
      String,
      String,
      String,
      String,
      String,
      String,
      List<TrendingPest>
    )>{
  'flowering': (
    'Full sun',
    'Keep moist',
    'Loam',
    'Outdoor',
    'Keep the mix evenly moist while it blooms.',
    'Full sun for strong flowers.',
    'Light loam that drains.',
    '15–24°C',
    '9 to 11',
    TrendingPest.flowering,
  ),
  'shrubs': (
    'Bright sun',
    'When dry',
    'Loam',
    'Outdoor',
    'Water when the top of the soil is dry.',
    'Bright light; too little shade makes it sparse.',
    'Garden loam that drains.',
    '10–24°C',
    '5 to 9',
    TrendingPest.house,
  ),
  'herbs': (
    'Full sun',
    'Keep moist',
    'Loam',
    'Outdoor',
    'Keep evenly moist; pots dry fast in sun.',
    'Full sun for strong flavour.',
    'Light loam in a pot with a hole.',
    '15–27°C',
    '8 to 11',
    TrendingPest.flowering,
  ),
  'vegetables': (
    'Full sun',
    'Keep moist',
    'Loam',
    'Outdoor',
    'Keep the mix moist while fruiting.',
    'Full sun — shade cuts the crop.',
    'Rich loam that drains.',
    '18–29°C',
    '9 to 11',
    TrendingPest.flowering,
  ),
  'trees': (
    'Bright indirect',
    'When dry',
    'Loam',
    'Indoor',
    'Water when the top of the pot is dry.',
    'Bright, indirect light. Rotate so it does not lean.',
    'Loam with drainage. A pot with a hole is required.',
    '16–27°C',
    '10 to 12',
    TrendingPest.house,
  ),
  'ferns': (
    'Low light',
    'Keep moist',
    'Loam',
    'Indoor',
    'Keep the mix evenly moist, never a puddle.',
    'Low to medium, indirect light. Direct sun burns fronds.',
    'Rich loam that holds moisture but still drains.',
    '18–24°C',
    '9 to 11',
    TrendingPest.house,
  ),
  'cacti': (
    'Bright sun',
    'Sparse',
    'Sandy',
    'Indoor',
    'Soak, then let it go fully dry.',
    'Bright sun or a south window.',
    'Sandy cactus mix. Never skip drainage.',
    '13–27°C',
    '9 to 11',
    TrendingPest.succulent,
  ),
  'edible': (
    'Full sun',
    'Keep moist',
    'Loam',
    'Outdoor',
    'Keep evenly moist while it is cropping.',
    'Full sun for flavour and fruit.',
    'Rich loam in a pot or bed that drains.',
    '15–29°C',
    '8 to 11',
    TrendingPest.flowering,
  ),
};

class CategoryPlant {
  const CategoryPlant({
    required this.name,
    required this.scientificName,
    required this.imagePath,
  });

  final String name;
  final String scientificName;
  final String imagePath;

  TrendingPlant toDetail(String categoryId) {
    for (final item in TrendingPlant.catalog) {
      if (item.name.toLowerCase() == name.toLowerCase()) return item;
    }
    return _previewDetail(categoryId);
  }

  TrendingPlant _previewDetail(String categoryId) {
    final care = _previewCare[categoryId] ?? _previewCare['flowering']!;
    final genus = scientificName.split(RegExp(r'[\s×]')).first;
    return TrendingPlant(
      name: name,
      scientificName: scientificName,
      imagePath: imagePath,
      overview:
          '$name ($scientificName) is a $categoryId plant kept for its look and habit. It prefers ${care.$1} light and ${care.$2} watering, in ${care.$3}, typically ${care.$4}. Give it a pot that drains and a steady spot — moving it often stresses new growth.\n\nUse a balanced slow-release feed in the growing season. Skip heavy doses when days are short. Preview library · full notes when connected.',
      lightChip: care.$1,
      waterChip: care.$2,
      soilChip: care.$3,
      placeChip: care.$4,
      waterNote: care.$5,
      lightNote: care.$6,
      soilNote: care.$7,
      temperature: care.$8,
      hardiness: care.$9,
      order: '—',
      genus: genus,
      family: '—',
      taxonClass: '—',
      nameStory:
          '$name takes its garden name from common speech; nurseries list it as $scientificName. Preview library · full name story when connected.',
      pests: care.$10,
      toxicity: const PlantToxicity(
        toxicToPets: false,
        toxicToKids: false,
        summary:
            'Preview safety · confirm before pets or kids chew this plant.',
        petsDetail: 'Full toxicity when the library is connected.',
        kidsDetail: 'Full toxicity when the library is connected.',
      ),
    );
  }
}

class BrowseCategory {
  const BrowseCategory({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.color,
    this.wide = false,
  });

  final String id;
  final String title;
  final String imagePath;
  final Color color;
  final bool wide;

  List<CategoryPlant> get plants => catalog[id] ?? const [];

  static const grid = <BrowseCategory>[
    BrowseCategory(
      id: 'flowering',
      title: 'Flowering Plants',
      imagePath: 'assets/images/home/categories/flowering_plants.png',
      color: Color(0xFFF6EBEA),
    ),
    BrowseCategory(
      id: 'shrubs',
      title: 'Shrubs',
      imagePath: 'assets/images/home/categories/shrubs.png',
      color: Color(0xFFEEF0E8),
    ),
    BrowseCategory(
      id: 'herbs',
      title: 'Herbs',
      imagePath: 'assets/images/home/categories/herbs.png',
      color: Color(0xFFE7F1EC),
    ),
    BrowseCategory(
      id: 'vegetables',
      title: 'Vegetables and Fruits',
      imagePath: 'assets/images/home/categories/vegetables_fruits.png',
      color: Color(0xFFEEF3E8),
    ),
    BrowseCategory(
      id: 'trees',
      title: 'Trees',
      imagePath: 'assets/images/home/categories/trees.png',
      color: Color(0xFFE8EEE9),
    ),
    BrowseCategory(
      id: 'ferns',
      title: 'Ferns',
      imagePath: 'assets/images/home/categories/ferns.png',
      color: Color(0xFFE8F0E6),
    ),
    BrowseCategory(
      id: 'cacti',
      title: 'Cacti and Succulents',
      imagePath: 'assets/images/home/categories/cacti_succulents.png',
      color: Color(0xFFF3EEE6),
    ),
    BrowseCategory(
      id: 'edible',
      title: 'Edible Plants',
      imagePath: 'assets/images/home/categories/edible_plants.png',
      color: Color(0xFFEEF3E8),
    ),
  ];

  static const _fern = 'assets/images/home/categories/ferns.png';
  static const _herb = 'assets/images/home/categories/herbs.png';
  static const _veg = 'assets/images/home/categories/vegetables_fruits.png';
  static const _petunia = 'assets/images/home/trending/trending_devils_ivy.png';
  static const _orchid = 'assets/images/home/trending/trending_orchid.png';
  static const _aloe = 'assets/images/home/trending/trending_aloe.png';
  static const _jade = 'assets/images/home/trending/trending_jade.png';
  static const _snake = 'assets/images/home/trending/trending_snake_plant.png';
  static const _fiddle = 'assets/images/home/trending/trending_fiddle_leaf.png';
  static const _rubber = 'assets/images/home/trending/trending_rubber_plant.png';
  static const _corn = 'assets/images/home/trending/trending_corn_plant.png';

  static const catalog = <String, List<CategoryPlant>>{
    'flowering': [
      CategoryPlant(name: 'Petunia', scientificName: 'Petunia × atkinsiana', imagePath: _petunia),
      CategoryPlant(name: 'Orchid', scientificName: 'Phalaenopsis', imagePath: _orchid),
    ],
    'shrubs': [
      CategoryPlant(name: 'Rubber Plant', scientificName: 'Ficus elastica', imagePath: _rubber),
      CategoryPlant(name: 'Jade Plant', scientificName: 'Crassula ovata', imagePath: _jade),
    ],
    'herbs': [
      CategoryPlant(name: 'Basil', scientificName: 'Ocimum basilicum', imagePath: _herb),
      CategoryPlant(name: 'Mint', scientificName: 'Mentha spicata', imagePath: _herb),
    ],
    'vegetables': [
      CategoryPlant(name: 'Tomato', scientificName: 'Solanum lycopersicum', imagePath: _veg),
      CategoryPlant(name: 'Chili Pepper', scientificName: 'Capsicum annuum', imagePath: _veg),
    ],
    'trees': [
      CategoryPlant(name: 'Fiddle Leaf Fig', scientificName: 'Ficus lyrata', imagePath: _fiddle),
      CategoryPlant(name: 'Corn Plant', scientificName: 'Dracaena fragrans', imagePath: _corn),
    ],
    'ferns': [
      CategoryPlant(name: 'Boston Fern', scientificName: 'Nephrolepis exaltata', imagePath: _fern),
      CategoryPlant(name: 'Maidenhair Fern', scientificName: 'Adiantum raddianum', imagePath: _fern),
    ],
    'cacti': [
      CategoryPlant(name: 'Aloe Vera', scientificName: 'Aloe vera', imagePath: _aloe),
      CategoryPlant(name: 'Snake Plant', scientificName: 'Dracaena trifasciata', imagePath: _snake),
    ],
    'edible': [
      CategoryPlant(name: 'Tomato', scientificName: 'Solanum lycopersicum', imagePath: _veg),
      CategoryPlant(name: 'Basil', scientificName: 'Ocimum basilicum', imagePath: _herb),
    ],
  };
}
