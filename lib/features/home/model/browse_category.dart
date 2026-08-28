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
  'groundcover': (
    'Bright light',
    'When dry',
    'Loam',
    'Outdoor',
    'Water when the top is dry. Avoid a soggy mat.',
    'Bright light; too little shade makes it thin.',
    'Loam that drains. Tight wet soil invites rot.',
    '10–27°C',
    '4 to 9',
    TrendingPest.house,
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
      id: 'groundcover',
      title: 'Groundcover',
      imagePath: 'assets/images/home/categories/groundcover.png',
      color: Color(0xFFEEF1F3),
    ),
  ];

  static const edible = BrowseCategory(
    id: 'edible',
    title: 'Edible Plants',
    imagePath: 'assets/images/home/categories/edible_plants.png',
    color: Color(0xFFEEF3E8),
    wide: true,
  );

  static const _fern = 'assets/images/home/categories/ferns.png';
  static const _flower = 'assets/images/home/categories/flowering_plants.png';
  static const _cactus = 'assets/images/home/categories/cacti_succulents.png';
  static const _herb = 'assets/images/home/categories/herbs.png';
  static const _shrub = 'assets/images/home/categories/shrubs.png';
  static const _tree = 'assets/images/home/categories/trees.png';
  static const _veg = 'assets/images/home/categories/vegetables_fruits.png';
  static const _ground = 'assets/images/home/categories/groundcover.png';
  static const _petunia = 'assets/images/home/trending/trending_devils_ivy.png';
  static const _orchid = 'assets/images/home/trending/trending_orchid.png';
  static const _peace = 'assets/images/home/trending/trending_peace_lily.png';
  static const _aloe = 'assets/images/home/trending/trending_aloe.png';
  static const _jade = 'assets/images/home/trending/trending_jade.png';
  static const _snake = 'assets/images/home/trending/trending_snake_plant.png';
  static const _fiddle = 'assets/images/home/trending/trending_fiddle_leaf.png';
  static const _rubber = 'assets/images/home/trending/trending_rubber_plant.png';
  static const _corn = 'assets/images/home/trending/trending_corn_plant.png';
  static const _monstera = 'assets/images/home/trending/trending_monstera.png';

  static const catalog = <String, List<CategoryPlant>>{
    'flowering': [
      CategoryPlant(name: 'Petunia', scientificName: 'Petunia × atkinsiana', imagePath: _petunia),
      CategoryPlant(name: 'Orchid', scientificName: 'Phalaenopsis', imagePath: _orchid),
      CategoryPlant(name: 'Peace Lily', scientificName: 'Spathiphyllum wallisii', imagePath: _peace),
      CategoryPlant(name: 'Hibiscus', scientificName: 'Hibiscus rosa-sinensis', imagePath: _flower),
      CategoryPlant(name: 'Geranium', scientificName: 'Pelargonium × hortorum', imagePath: _petunia),
      CategoryPlant(name: 'Begonia', scientificName: 'Begonia × semperflorens', imagePath: _flower),
      CategoryPlant(name: 'Impatiens', scientificName: 'Impatiens walleriana', imagePath: _petunia),
      CategoryPlant(name: 'Marigold', scientificName: 'Tagetes erecta', imagePath: _flower),
      CategoryPlant(name: 'Zinnia', scientificName: 'Zinnia elegans', imagePath: _petunia),
      CategoryPlant(name: 'Snapdragon', scientificName: 'Antirrhinum majus', imagePath: _flower),
      CategoryPlant(name: 'Dahlia', scientificName: 'Dahlia pinnata', imagePath: _petunia),
      CategoryPlant(name: 'Camellia', scientificName: 'Camellia japonica', imagePath: _flower),
      CategoryPlant(name: 'Jasmine', scientificName: 'Jasminum officinale', imagePath: _peace),
      CategoryPlant(name: 'Lavender', scientificName: 'Lavandula angustifolia', imagePath: _flower),
    ],
    'shrubs': [
      CategoryPlant(name: 'Boxwood', scientificName: 'Buxus sempervirens', imagePath: _shrub),
      CategoryPlant(name: 'Hydrangea', scientificName: 'Hydrangea macrophylla', imagePath: _flower),
      CategoryPlant(name: 'Azalea', scientificName: 'Rhododendron indicum', imagePath: _shrub),
      CategoryPlant(name: 'Lilac', scientificName: 'Syringa vulgaris', imagePath: _flower),
      CategoryPlant(name: 'Forsythia', scientificName: 'Forsythia × intermedia', imagePath: _shrub),
      CategoryPlant(name: 'Spirea', scientificName: 'Spiraea japonica', imagePath: _shrub),
      CategoryPlant(name: 'Rubber Plant', scientificName: 'Ficus elastica', imagePath: _rubber),
      CategoryPlant(name: 'Jade Plant', scientificName: 'Crassula ovata', imagePath: _jade),
      CategoryPlant(name: 'Privet', scientificName: 'Ligustrum ovalifolium', imagePath: _shrub),
      CategoryPlant(name: 'Barberry', scientificName: 'Berberis thunbergii', imagePath: _shrub),
      CategoryPlant(name: 'Weigela', scientificName: 'Weigela florida', imagePath: _flower),
      CategoryPlant(name: 'Viburnum', scientificName: 'Viburnum opulus', imagePath: _shrub),
    ],
    'herbs': [
      CategoryPlant(name: 'Basil', scientificName: 'Ocimum basilicum', imagePath: _herb),
      CategoryPlant(name: 'Mint', scientificName: 'Mentha spicata', imagePath: _herb),
      CategoryPlant(name: 'Rosemary', scientificName: 'Salvia rosmarinus', imagePath: _herb),
      CategoryPlant(name: 'Thyme', scientificName: 'Thymus vulgaris', imagePath: _herb),
      CategoryPlant(name: 'Parsley', scientificName: 'Petroselinum crispum', imagePath: _herb),
      CategoryPlant(name: 'Cilantro', scientificName: 'Coriandrum sativum', imagePath: _herb),
      CategoryPlant(name: 'Sage', scientificName: 'Salvia officinalis', imagePath: _herb),
      CategoryPlant(name: 'Oregano', scientificName: 'Origanum vulgare', imagePath: _herb),
      CategoryPlant(name: 'Chives', scientificName: 'Allium schoenoprasum', imagePath: _herb),
      CategoryPlant(name: 'Dill', scientificName: 'Anethum graveolens', imagePath: _herb),
      CategoryPlant(name: 'Lavender', scientificName: 'Lavandula angustifolia', imagePath: _flower),
      CategoryPlant(name: 'Lemongrass', scientificName: 'Cymbopogon citratus', imagePath: _herb),
    ],
    'vegetables': [
      CategoryPlant(name: 'Tomato', scientificName: 'Solanum lycopersicum', imagePath: _veg),
      CategoryPlant(name: 'Chili Pepper', scientificName: 'Capsicum annuum', imagePath: _veg),
      CategoryPlant(name: 'Cucumber', scientificName: 'Cucumis sativus', imagePath: _veg),
      CategoryPlant(name: 'Lettuce', scientificName: 'Lactuca sativa', imagePath: _herb),
      CategoryPlant(name: 'Spinach', scientificName: 'Spinacia oleracea', imagePath: _herb),
      CategoryPlant(name: 'Eggplant', scientificName: 'Solanum melongena', imagePath: _veg),
      CategoryPlant(name: 'Strawberry', scientificName: 'Fragaria × ananassa', imagePath: _veg),
      CategoryPlant(name: 'Lemon', scientificName: 'Citrus limon', imagePath: _tree),
      CategoryPlant(name: 'Bean', scientificName: 'Phaseolus vulgaris', imagePath: _veg),
      CategoryPlant(name: 'Zucchini', scientificName: 'Cucurbita pepo', imagePath: _veg),
      CategoryPlant(name: 'Kale', scientificName: 'Brassica oleracea', imagePath: _herb),
      CategoryPlant(name: 'Radish', scientificName: 'Raphanus sativus', imagePath: _veg),
    ],
    'trees': [
      CategoryPlant(name: 'Fiddle Leaf Fig', scientificName: 'Ficus lyrata', imagePath: _fiddle),
      CategoryPlant(name: 'Rubber Plant', scientificName: 'Ficus elastica', imagePath: _rubber),
      CategoryPlant(name: 'Corn Plant', scientificName: 'Dracaena fragrans', imagePath: _corn),
      CategoryPlant(name: 'Olive', scientificName: 'Olea europaea', imagePath: _tree),
      CategoryPlant(name: 'Lemon Tree', scientificName: 'Citrus limon', imagePath: _tree),
      CategoryPlant(name: 'Maple', scientificName: 'Acer palmatum', imagePath: _tree),
      CategoryPlant(name: 'Oak', scientificName: 'Quercus robur', imagePath: _tree),
      CategoryPlant(name: 'Birch', scientificName: 'Betula pendula', imagePath: _tree),
      CategoryPlant(name: 'Willow', scientificName: 'Salix babylonica', imagePath: _tree),
      CategoryPlant(name: 'Pine', scientificName: 'Pinus sylvestris', imagePath: _tree),
      CategoryPlant(name: 'Magnolia', scientificName: 'Magnolia grandiflora', imagePath: _flower),
      CategoryPlant(name: 'Crape Myrtle', scientificName: 'Lagerstroemia indica', imagePath: _tree),
    ],
    'ferns': [
      CategoryPlant(name: 'Boston Fern', scientificName: 'Nephrolepis exaltata', imagePath: _fern),
      CategoryPlant(name: 'Maidenhair Fern', scientificName: 'Adiantum raddianum', imagePath: _fern),
      CategoryPlant(name: 'Staghorn Fern', scientificName: 'Platycerium bifurcatum', imagePath: _fern),
      CategoryPlant(name: 'Bird’s Nest Fern', scientificName: 'Asplenium nidus', imagePath: _fern),
      CategoryPlant(name: 'Kimberly Queen', scientificName: 'Nephrolepis obliterata', imagePath: _fern),
      CategoryPlant(name: 'Autumn Fern', scientificName: 'Dryopteris erythrosora', imagePath: _fern),
      CategoryPlant(name: 'Japanese Painted Fern', scientificName: 'Athyrium niponicum', imagePath: _fern),
      CategoryPlant(name: 'Rabbit’s Foot Fern', scientificName: 'Davallia fejeensis', imagePath: _fern),
      CategoryPlant(name: 'Holly Fern', scientificName: 'Cyrtomium falcatum', imagePath: _fern),
      CategoryPlant(name: 'Cinnamon Fern', scientificName: 'Osmundastrum cinnamomeum', imagePath: _fern),
      CategoryPlant(name: 'Leatherleaf Fern', scientificName: 'Rumohra adiantiformis', imagePath: _fern),
      CategoryPlant(name: 'Button Fern', scientificName: 'Pellaea rotundifolia', imagePath: _fern),
      CategoryPlant(name: 'Asparagus Fern', scientificName: 'Asparagus setaceus', imagePath: _fern),
      CategoryPlant(name: 'Blue Star Fern', scientificName: 'Phlebodium aureum', imagePath: _fern),
    ],
    'cacti': [
      CategoryPlant(name: 'Aloe Vera', scientificName: 'Aloe vera', imagePath: _aloe),
      CategoryPlant(name: 'Jade Plant', scientificName: 'Crassula ovata', imagePath: _jade),
      CategoryPlant(name: 'Snake Plant', scientificName: 'Dracaena trifasciata', imagePath: _snake),
      CategoryPlant(name: 'Golden Barrel', scientificName: 'Echinocactus grusonii', imagePath: _cactus),
      CategoryPlant(name: 'Prickly Pear', scientificName: 'Opuntia ficus-indica', imagePath: _cactus),
      CategoryPlant(name: 'Christmas Cactus', scientificName: 'Schlumbergera truncata', imagePath: _cactus),
      CategoryPlant(name: 'Echeveria', scientificName: 'Echeveria elegans', imagePath: _jade),
      CategoryPlant(name: 'Haworthia', scientificName: 'Haworthia fasciata', imagePath: _aloe),
      CategoryPlant(name: 'Zebra Cactus', scientificName: 'Haworthiopsis attenuata', imagePath: _aloe),
      CategoryPlant(name: 'Bunny Ears', scientificName: 'Opuntia microdasys', imagePath: _cactus),
      CategoryPlant(name: 'Panda Plant', scientificName: 'Kalanchoe tomentosa', imagePath: _jade),
      CategoryPlant(name: 'String of Pearls', scientificName: 'Senecio rowleyanus', imagePath: _cactus),
    ],
    'groundcover': [
      CategoryPlant(name: 'Creeping Thyme', scientificName: 'Thymus serpyllum', imagePath: _ground),
      CategoryPlant(name: 'Irish Moss', scientificName: 'Sagina subulata', imagePath: _ground),
      CategoryPlant(name: 'Ajuga', scientificName: 'Ajuga reptans', imagePath: _ground),
      CategoryPlant(name: 'Pachysandra', scientificName: 'Pachysandra terminalis', imagePath: _ground),
      CategoryPlant(name: 'Vinca', scientificName: 'Vinca minor', imagePath: _ground),
      CategoryPlant(name: 'Sedum', scientificName: 'Sedum spurium', imagePath: _cactus),
      CategoryPlant(name: 'Sweet Woodruff', scientificName: 'Galium odoratum', imagePath: _ground),
      CategoryPlant(name: 'Liriope', scientificName: 'Liriope muscari', imagePath: _ground),
      CategoryPlant(name: 'Ivy', scientificName: 'Hedera helix', imagePath: _monstera),
      CategoryPlant(name: 'Creeping Jenny', scientificName: 'Lysimachia nummularia', imagePath: _ground),
      CategoryPlant(name: 'Mondograss', scientificName: 'Ophiopogon japonicus', imagePath: _ground),
      CategoryPlant(name: 'Clover', scientificName: 'Trifolium repens', imagePath: _ground),
    ],
    'edible': [
      CategoryPlant(name: 'Tomato', scientificName: 'Solanum lycopersicum', imagePath: _veg),
      CategoryPlant(name: 'Basil', scientificName: 'Ocimum basilicum', imagePath: _herb),
      CategoryPlant(name: 'Mint', scientificName: 'Mentha spicata', imagePath: _herb),
      CategoryPlant(name: 'Strawberry', scientificName: 'Fragaria × ananassa', imagePath: _veg),
      CategoryPlant(name: 'Lemon', scientificName: 'Citrus limon', imagePath: _tree),
      CategoryPlant(name: 'Chili Pepper', scientificName: 'Capsicum annuum', imagePath: _veg),
      CategoryPlant(name: 'Lettuce', scientificName: 'Lactuca sativa', imagePath: _herb),
      CategoryPlant(name: 'Rosemary', scientificName: 'Salvia rosmarinus', imagePath: _herb),
      CategoryPlant(name: 'Kale', scientificName: 'Brassica oleracea', imagePath: _herb),
      CategoryPlant(name: 'Cucumber', scientificName: 'Cucumis sativus', imagePath: _veg),
      CategoryPlant(name: 'Sage', scientificName: 'Salvia officinalis', imagePath: _herb),
      CategoryPlant(name: 'Thyme', scientificName: 'Thymus vulgaris', imagePath: _herb),
    ],
  };
}
