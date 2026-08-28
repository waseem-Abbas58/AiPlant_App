import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../view/plant_finder_results_view.dart';

class PlantFinderOption {
  const PlantFinderOption({
    required this.id,
    required this.label,
    this.imagePath,
  });

  final String id;
  final String label;
  final String? imagePath;
}

class PlantFinderController extends GetxController {
  static const lights = [
    PlantFinderOption(id: 'full-sun', label: 'Full Sun'),
    PlantFinderOption(id: 'partial-sun', label: 'Partial Sun'),
    PlantFinderOption(id: 'partial-shade', label: 'Partial Shade'),
    PlantFinderOption(id: 'full-shade', label: 'Full Shade'),
  ];

  static const soils = [
    PlantFinderOption(
      id: 'chalk',
      label: 'Chalk',
      imagePath: AppImages.soilChalk,
    ),
    PlantFinderOption(
      id: 'clay',
      label: 'Clay',
      imagePath: AppImages.soilClay,
    ),
    PlantFinderOption(
      id: 'loam',
      label: 'Loam',
      imagePath: AppImages.soilLoam,
    ),
    PlantFinderOption(
      id: 'sand',
      label: 'Sand',
      imagePath: AppImages.soilSand,
    ),
  ];

  static const phLevels = [
    PlantFinderOption(id: 'neutral', label: 'Neutral'),
    PlantFinderOption(id: 'alkaline', label: 'Alkaline'),
    PlantFinderOption(id: 'acid', label: 'Acid'),
  ];

  static const plantTypes = [
    PlantFinderOption(
      id: 'flowering',
      label: 'Flowering Plants',
      imagePath: 'assets/images/home/categories/flowering_plants.png',
    ),
    PlantFinderOption(
      id: 'shrubs',
      label: 'Shrubs',
      imagePath: 'assets/images/home/categories/shrubs.png',
    ),
    PlantFinderOption(
      id: 'herbs',
      label: 'Herbs',
      imagePath: 'assets/images/home/categories/herbs.png',
    ),
    PlantFinderOption(
      id: 'veg-fruit',
      label: 'Vegetables and Fruits',
      imagePath: 'assets/images/home/categories/vegetables_fruits.png',
    ),
    PlantFinderOption(
      id: 'trees',
      label: 'Trees',
      imagePath: 'assets/images/home/categories/trees.png',
    ),
    PlantFinderOption(
      id: 'ferns',
      label: 'Ferns',
      imagePath: 'assets/images/home/categories/ferns.png',
    ),
    PlantFinderOption(
      id: 'cacti',
      label: 'Cacti and Succulents',
      imagePath: 'assets/images/home/categories/cacti_succulents.png',
    ),
    PlantFinderOption(
      id: 'groundcover',
      label: 'Groundcover',
      imagePath: 'assets/images/home/categories/groundcover.png',
    ),
  ];

  static const lifecycles = [
    PlantFinderOption(id: 'annual', label: 'Annual'),
    PlantFinderOption(id: 'perennial', label: 'Perennial'),
    PlantFinderOption(id: 'biennial', label: 'Biennial'),
  ];

  final selectedLights = <String>{}.obs;
  final selectedSoils = <String>{}.obs;
  final selectedPh = <String>{}.obs;
  final selectedTypes = <String>{}.obs;
  final selectedLifecycles = <String>{}.obs;

  void toggle(RxSet<String> selected, String id) {
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }
  }

  void reset() {
    selectedLights.clear();
    selectedSoils.clear();
    selectedPh.clear();
    selectedTypes.clear();
    selectedLifecycles.clear();
  }

  void apply() {
    NavigationHelper.to(() => const PlantFinderResultsView());
  }

  bool _hits(Set<String> selected, Set<String> tags) {
    if (selected.isEmpty) return true;
    return selected.any(tags.contains);
  }

  List<FinderSample> get matches => matchSet.plants;

  bool get matchesAreClosest => matchSet.closest;

  ({List<FinderSample> plants, bool closest}) get matchSet {
    final exact = samples.where(_matchesAll).toList();
    if (exact.isNotEmpty) {
      return (plants: exact, closest: false);
    }
    final ranked = [...samples]..sort((a, b) => _score(b).compareTo(_score(a)));
    final close = ranked.where((plant) => _score(plant) > 0).take(3).toList();
    if (close.isNotEmpty) {
      return (plants: close, closest: true);
    }
    return (plants: samples.take(4).toList(), closest: true);
  }

  bool _matchesAll(FinderSample plant) =>
      _hits(selectedLights, plant.lights) &&
      _hits(selectedSoils, plant.soils) &&
      _hits(selectedPh, plant.ph) &&
      _hits(selectedTypes, plant.types) &&
      _hits(selectedLifecycles, plant.lifecycles);

  int _score(FinderSample plant) {
    var score = 0;
    score += _overlap(selectedLights, plant.lights);
    score += _overlap(selectedSoils, plant.soils);
    score += _overlap(selectedPh, plant.ph);
    score += _overlap(selectedTypes, plant.types);
    score += _overlap(selectedLifecycles, plant.lifecycles);
    return score;
  }

  int _overlap(Set<String> selected, Set<String> tags) {
    if (selected.isEmpty) return 0;
    return selected.where(tags.contains).length;
  }

  static const samples = <FinderSample>[
    FinderSample(
      name: 'Snake Plant',
      scientific: 'Dracaena trifasciata',
      imageAsset: 'assets/images/home/trending/trending_snake_plant.png',
      lights: {'full-shade', 'partial-shade'},
      soils: {'sand', 'loam'},
      ph: {'neutral', 'alkaline'},
      types: {'cacti'},
      lifecycles: {'perennial'},
    ),
    FinderSample(
      name: 'Peace Lily',
      scientific: 'Spathiphyllum wallisii',
      imageAsset: 'assets/images/home/trending/trending_peace_lily.png',
      lights: {'partial-shade', 'full-shade'},
      soils: {'loam'},
      ph: {'neutral', 'acid'},
      types: {'flowering'},
      lifecycles: {'perennial'},
    ),
    FinderSample(
      name: 'Aloe',
      scientific: 'Aloe vera',
      imageAsset: 'assets/images/home/trending/trending_aloe.png',
      lights: {'full-sun', 'partial-sun'},
      soils: {'sand'},
      ph: {'neutral', 'alkaline'},
      types: {'cacti'},
      lifecycles: {'perennial'},
    ),
    FinderSample(
      name: 'Monstera',
      scientific: 'Monstera deliciosa',
      imageAsset: 'assets/images/home/trending/trending_monstera.png',
      lights: {'partial-shade', 'partial-sun'},
      soils: {'loam'},
      ph: {'neutral', 'acid'},
      types: {'flowering'},
      lifecycles: {'perennial'},
    ),
    FinderSample(
      name: 'Fiddle Leaf Fig',
      scientific: 'Ficus lyrata',
      imageAsset: 'assets/images/home/trending/trending_fiddle_leaf.png',
      lights: {'partial-sun', 'full-sun'},
      soils: {'loam', 'clay'},
      ph: {'neutral', 'acid'},
      types: {'trees'},
      lifecycles: {'perennial'},
    ),
    FinderSample(
      name: 'Jade',
      scientific: 'Crassula ovata',
      imageAsset: 'assets/images/home/trending/trending_jade.png',
      lights: {'full-sun', 'partial-sun'},
      soils: {'sand', 'chalk'},
      ph: {'neutral', 'alkaline'},
      types: {'cacti'},
      lifecycles: {'perennial'},
    ),
    FinderSample(
      name: 'Orchid',
      scientific: 'Phalaenopsis',
      imageAsset: 'assets/images/home/trending/trending_orchid.png',
      lights: {'partial-shade', 'partial-sun'},
      soils: {'loam'},
      ph: {'acid', 'neutral'},
      types: {'flowering'},
      lifecycles: {'perennial'},
    ),
    FinderSample(
      name: 'Rubber Plant',
      scientific: 'Ficus elastica',
      imageAsset: 'assets/images/home/trending/trending_rubber_plant.png',
      lights: {'partial-sun', 'partial-shade'},
      soils: {'loam', 'clay'},
      ph: {'neutral'},
      types: {'shrubs', 'trees'},
      lifecycles: {'perennial'},
    ),
    FinderSample(
      name: 'Petunia',
      scientific: 'Petunia × atkinsiana',
      imageAsset: 'assets/images/home/trending/trending_devils_ivy.png',
      lights: {'full-sun'},
      soils: {'loam', 'sand'},
      ph: {'neutral', 'acid'},
      types: {'flowering'},
      lifecycles: {'annual'},
    ),
    FinderSample(
      name: 'Corn Plant',
      scientific: 'Dracaena fragrans',
      imageAsset: 'assets/images/home/trending/trending_corn_plant.png',
      lights: {'partial-sun', 'partial-shade'},
      soils: {'loam'},
      ph: {'neutral', 'acid'},
      types: {'shrubs'},
      lifecycles: {'perennial'},
    ),
  ];
}

class FinderSample {
  const FinderSample({
    required this.name,
    required this.scientific,
    required this.imageAsset,
    required this.lights,
    required this.soils,
    required this.ph,
    required this.types,
    required this.lifecycles,
  });

  final String name;
  final String scientific;
  final String imageAsset;
  final Set<String> lights;
  final Set<String> soils;
  final Set<String> ph;
  final Set<String> types;
  final Set<String> lifecycles;
}
