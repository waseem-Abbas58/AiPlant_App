import '../../plant_scan/model/plant_identify_result.dart';

class TrendingPest {
  const TrendingPest({required this.title, required this.imagePath});

  final String title;
  final String imagePath;

  static const spiderMites = TrendingPest(
    title: 'Spider Mites',
    imagePath: 'assets/images/home/diseases/spider_mites.png',
  );
  static const powdery = TrendingPest(
    title: 'Powdery Mildew',
    imagePath: 'assets/images/home/diseases/powdery_mildew.png',
  );
  static const botrytis = TrendingPest(
    title: 'Botrytis',
    imagePath: 'assets/images/home/diseases/botrytis.png',
  );
  static const anthracnose = TrendingPest(
    title: 'Anthracnose',
    imagePath: 'assets/images/home/diseases/anthracnose.png',
  );
  static const downy = TrendingPest(
    title: 'Downy Mildew',
    imagePath: 'assets/images/home/diseases/downy_mildew.png',
  );

  static const house = [spiderMites, powdery, botrytis];
  static const flowering = [powdery, botrytis, downy];
  static const succulent = [spiderMites, anthracnose, botrytis];
}

class TrendingPlant {
  const TrendingPlant({
    required this.name,
    required this.scientificName,
    required this.imagePath,
    required this.overview,
    required this.lightChip,
    required this.waterChip,
    required this.soilChip,
    required this.placeChip,
    required this.waterNote,
    required this.lightNote,
    required this.soilNote,
    required this.temperature,
    required this.hardiness,
    required this.order,
    required this.genus,
    required this.family,
    required this.taxonClass,
    required this.nameStory,
    required this.pests,
    required this.toxicity,
  });

  final String name;
  final String scientificName;
  final String imagePath;
  final String overview;
  final String lightChip;
  final String waterChip;
  final String soilChip;
  final String placeChip;
  final String waterNote;
  final String lightNote;
  final String soilNote;
  final String temperature;
  final String hardiness;
  final String order;
  final String genus;
  final String family;
  final String taxonClass;
  final String nameStory;
  final List<TrendingPest> pests;
  final PlantToxicity toxicity;

  String get aboutText {
    if (overview.contains('Fertilizer care guide')) return overview;
    return '$overview\n\nFertilizer care guide for $name: use a balanced slow-release feed in the growing season. Water first, then feed — never on bone-dry roots.';
  }

  String get funFact =>
      '$name is listed as $scientificName. Growers keep it for $placeChip use and a $lightChip light habit.';

  String get gardenUse =>
      '$name suits $placeChip spots in $soilChip. Give it $lightChip and follow $waterChip watering so it holds its shape.';

  String get interestingFacts =>
      'The botanical name $scientificName is how nurseries track this plant. Care stays simple: $lightChip, $waterChip, $soilChip.';

  String get symbolism =>
      'In gardens $name often stands for a steady, living habit — people grow $scientificName for presence as much as for flowers or foliage.';

  String get nextWaterLine {
    switch (waterChip) {
      case 'Every 1–2 weeks':
        return 'Water every 1–2 weeks';
      case 'Keep moist':
        return 'Keep the mix moist';
      case 'When bark dries':
        return 'Water when bark dries';
      case 'Sparse':
        return 'Water sparingly';
      case 'When dry':
        return 'Water when soil is dry';
      default:
        return 'Water · $waterChip';
    }
  }

  String get difficultyChip {
    switch (name) {
      case 'Orchid':
      case 'Fiddle Leaf Fig':
      case 'Rubber Plant':
        return 'Medium';
      default:
        return 'Easy';
    }
  }

  String seasonLine([DateTime? now]) {
    final month = (now ?? DateTime.now()).month;
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final label = names[month - 1];
    final outdoor = placeChip == 'Outdoor';
    final sparse = waterChip == 'Sparse';
    final moist = waterChip == 'Keep moist';
    final bark = waterChip == 'When bark dries';

    if (month == 12 || month == 1 || month == 2) {
      if (sparse) return '$label · water even less — rest season';
      if (bark) return '$label · bark stays wet longer; wait';
      if (moist) return '$label · growth slows; don’t keep soggy';
      return '$label · wait a little longer between drinks';
    }
    if (month >= 3 && month <= 5) {
      if (sparse) return '$label · more light, still soak then dry';
      if (moist && outdoor) return '$label · blooming — keep evenly moist';
      return '$label · growth pick-up; check soil more often';
    }
    if (month >= 6 && month <= 8) {
      if (outdoor) return '$label · heat dries hanging pots fast';
      if (sparse) return '$label · pots dry faster; still wait until dry';
      if (bark) return '$label · bark dries quicker in warm rooms';
      if (moist) return '$label · don’t let it bake; keep even moisture';
      return '$label · top dries faster; water when dry';
    }
    if (sparse) return '$label · taper drinks as light drops';
    if (moist && outdoor) return '$label · blooms may fade; ease off a little';
    return '$label · light drops; wait a bit longer between drinks';
  }

  List<TrendingPlant> similar({int count = 6}) {
    final scored = catalog
        .where((plant) => plant.imagePath != imagePath)
        .map((plant) {
          var score = 0;
          if (plant.placeChip == placeChip) score += 3;
          if (plant.waterChip == waterChip) score += 3;
          if (plant.difficultyChip == difficultyChip) score += 2;
          if (plant.soilChip == soilChip) score += 1;
          return (plant, score);
        })
        .toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    return scored.take(count).map((pair) => pair.$1).toList();
  }

  static TrendingPlant? byImagePath(String path) {
    for (final plant in catalog) {
      if (plant.imagePath == path) return plant;
    }
    return null;
  }

  static TrendingPlant? byName(String name) {
    final n = name.trim().toLowerCase();
    if (n.isEmpty) return null;
    for (final plant in catalog) {
      if (plant.name.toLowerCase() == n) return plant;
    }
    return null;
  }

  static const catalog = <TrendingPlant>[
    TrendingPlant(
      name: 'Petunia',
      scientificName: 'Petunia × atkinsiana',
      imagePath: 'assets/images/home/trending/trending_devils_ivy.png',
      overview:
          'A flowering annual with trumpet-shaped blooms, often grown in hanging baskets. It wants full sun and regular water through the blooming season.',
      lightChip: 'Full sun',
      waterChip: 'Keep moist',
      soilChip: 'Loam',
      placeChip: 'Outdoor',
      waterNote:
          'Keep the mix evenly moist while it blooms. Let the top dry slightly, then water — soggy pots rot the roots.',
      lightNote:
          'Full sun for strong flowers. A dim indoor corner makes it stretch and drop blooms.',
      soilNote:
          'Light loam that drains. Hanging baskets dry fast, so a mix that holds a little moisture still needs a hole in the pot.',
      temperature: '15–24°C',
      hardiness: '9 to 11',
      order: 'Solanales',
      genus: 'Petunia',
      family: 'Solanaceae',
      taxonClass: 'Dicotyledonae',
      nameStory:
          'Petunia is named from a Tupi–Guarani word for tobacco — a cousin in the nightshade family. Breeders filled hanging baskets with the trumpet blooms you see on porches today.',
      pests: TrendingPest.flowering,
      toxicity: const PlantToxicity(
        toxicToPets: false,
        toxicToKids: false,
        summary:
            'Petunias are generally non-toxic to pets and kids. Still not a snack.',
        petsDetail:
            'A nibble is unlikely to poison a cat or dog. Keep them from ripping the basket down.',
        kidsDetail:
            'Not considered toxic. Watch hanging chains and don’t let them eat soil or fertilizer.',
      ),
    ),
    TrendingPlant(
      name: 'Corn Plant',
      scientificName: 'Dracaena fragrans',
      imagePath: 'assets/images/home/trending/trending_corn_plant.png',
      overview:
          'An upright dracaena with a woody cane and strappy leaves. Grown indoors for height and a tropical look in low to medium light.',
      lightChip: 'Medium',
      waterChip: 'Every 1–2 weeks',
      soilChip: 'Loam',
      placeChip: 'Indoor',
      waterNote:
          'Water every 1–2 weeks. Let the top of the pot dry; brown tips often mean fluoride or tap salts.',
      lightNote:
          'Medium, indirect light. Too little light thins the cane; hot glass can scorch stripes.',
      soilNote:
          'A standard loam potting mix with drainage is enough. Avoid packing it wet.',
      temperature: '18–24°C',
      hardiness: '10 to 12',
      order: 'Asparagales',
      genus: 'Dracaena',
      family: 'Asparagaceae',
      taxonClass: 'Monocotyledonae',
      nameStory:
          'Corn Plant is a dracaena, not a crop. The cane and strappy leaves reminded growers of maize, so the nickname stuck in living rooms.',
      pests: TrendingPest.house,
      toxicity: const PlantToxicity(
        toxicToPets: true,
        toxicToKids: true,
        summary:
            'Dracaena is toxic if chewed. Keep dogs, cats, and small children from nibbling the leaves.',
        petsDetail:
            'Can cause vomiting and drooling in cats and dogs if they eat the leaves.',
        kidsDetail:
            'Keep leaves out of reach. Wash hands after wiping dust.',
      ),
    ),
    TrendingPlant(
      name: 'Orchid',
      scientificName: 'Phalaenopsis',
      imagePath: 'assets/images/home/trending/trending_orchid.png',
      overview:
          'A moth orchid grown for long-lasting blooms. It prefers bright, indirect light and a bark mix that dries between waterings.',
      lightChip: 'Bright indirect',
      waterChip: 'When bark dries',
      soilChip: 'Bark mix',
      placeChip: 'Indoor',
      waterNote:
          'Water when the bark is dry and silvery. Soak, then drain fully — never leave it in a puddle.',
      lightNote:
          'Bright, indirect light near a window. Direct noon sun burns the leaves.',
      soilNote:
          'Orchid bark, not garden soil. Roots need air as much as moisture.',
      temperature: '18–29°C',
      hardiness: '10 to 12',
      order: 'Asparagales',
      genus: 'Phalaenopsis',
      family: 'Orchidaceae',
      taxonClass: 'Monocotyledonae',
      nameStory:
          'Phalaenopsis means “moth-like.” The flat blooms look like moths in flight, which is why moth orchid became the common name.',
      pests: TrendingPest.house,
      toxicity: const PlantToxicity(
        toxicToPets: false,
        toxicToKids: false,
        summary: 'Phalaenopsis orchids are generally non-toxic to pets and kids.',
        petsDetail: 'A nibble is unlikely to poison a cat or dog.',
        kidsDetail: 'Not considered toxic. Still keep soil and pots off the floor.',
      ),
    ),
    TrendingPlant(
      name: 'Jade Plant',
      scientificName: 'Crassula ovata',
      imagePath: 'assets/images/home/trending/trending_jade.png',
      overview:
          'A succulent shrub with thick, glossy leaves. It likes bright light and soil that dries out before the next drink.',
      lightChip: 'Bright sun',
      waterChip: 'Sparse',
      soilChip: 'Sandy',
      placeChip: 'Indoor',
      waterNote:
          'Water thoroughly, then wait until the pot is dry. Winter drinks are rare.',
      lightNote:
          'Bright sun or a very bright window. Low light makes weak, stretchy stems.',
      soilNote:
          'Gritty, sandy mix with extra perlite. Ordinary wet soil invites rot.',
      temperature: '18–24°C',
      hardiness: '10 to 11',
      order: 'Saxifragales',
      genus: 'Crassula',
      family: 'Crassulaceae',
      taxonClass: 'Dicotyledonae',
      nameStory:
          'Jade is named for the thick, green leaves that look like polished stone. In many homes it is kept as a luck plant by the door.',
      pests: TrendingPest.succulent,
      toxicity: const PlantToxicity(
        toxicToPets: true,
        toxicToKids: false,
        summary: 'Mildly toxic to pets if chewed. Usually safe around kids.',
        petsDetail: 'Can cause vomiting in cats and dogs if they eat the leaves.',
        kidsDetail: 'Not typically a kids hazard. Still don’t let them nibble plants.',
      ),
    ),
    TrendingPlant(
      name: 'Peace Lily',
      scientificName: 'Spathiphyllum wallisii',
      imagePath: 'assets/images/home/trending/trending_peace_lily.png',
      overview:
          'A shade-tolerant plant with dark leaves and white spathes. It flags when thirsty and prefers evenly moist, not soggy, soil.',
      lightChip: 'Low light',
      waterChip: 'Keep moist',
      soilChip: 'Loam',
      placeChip: 'Indoor',
      waterNote:
          'Keep the mix evenly moist. Drooping leaves ask for water; soggy soil yellows them.',
      lightNote:
          'Low to medium, indirect light. It blooms more with a bit of brightness, not direct sun.',
      soilNote:
          'Rich loam that holds moisture but still drains. Empty standing water from the tray.',
      temperature: '18–30°C',
      hardiness: '11 to 12',
      order: 'Alismatales',
      genus: 'Spathiphyllum',
      family: 'Araceae',
      taxonClass: 'Monocotyledonae',
      nameStory:
          'Peace Lily is not a true lily. The white spathe looks like a flag of truce, which gave the plant its common name.',
      pests: TrendingPest.house,
      toxicity: const PlantToxicity(
        toxicToPets: true,
        toxicToKids: true,
        summary: 'Contains calcium oxalate. Not a snack for pets or kids.',
        petsDetail: 'Chewing can cause drooling and mouth pain in cats and dogs.',
        kidsDetail: 'Keep berries and leaves out of reach. Wash hands after handling.',
      ),
    ),
    TrendingPlant(
      name: 'Rubber Plant',
      scientificName: 'Ficus elastica',
      imagePath: 'assets/images/home/trending/trending_rubber_plant.png',
      overview:
          'A bold indoor tree with large, shiny leaves. It likes bright, indirect light and a pot that drains well.',
      lightChip: 'Bright indirect',
      waterChip: 'When dry',
      soilChip: 'Loam',
      placeChip: 'Indoor',
      waterNote:
          'Water when the top 2–3 cm are dry. Wipe leaves; they collect dust and drop if kept wet.',
      lightNote:
          'Bright, indirect light. Rotate weekly so it does not lean toward the window.',
      soilNote:
          'Loam with extra drainage. A pot with a hole is required — it hates wet feet.',
      temperature: '16–27°C',
      hardiness: '10 to 12',
      order: 'Rosales',
      genus: 'Ficus',
      family: 'Moraceae',
      taxonClass: 'Dicotyledonae',
      nameStory:
          'Rubber Plant was once tapped for latex. Indoors it is grown for the glossy, oversized leaves rather than sap.',
      pests: TrendingPest.house,
      toxicity: const PlantToxicity(
        toxicToPets: true,
        toxicToKids: true,
        summary: 'The milky sap is irritating. Not a chew toy.',
        petsDetail: 'Can upset a cat or dog if they chew the leaves.',
        kidsDetail: 'Sap can irritate skin and eyes. Wipe with gloves.',
      ),
    ),
    TrendingPlant(
      name: 'Aloe Vera',
      scientificName: 'Aloe vera',
      imagePath: 'assets/images/home/trending/trending_aloe.png',
      overview:
          'A succulent rosette with fleshy, toothed leaves. It wants bright light and a gritty mix that dries between waterings.',
      lightChip: 'Bright sun',
      waterChip: 'Sparse',
      soilChip: 'Sandy',
      placeChip: 'Indoor',
      waterNote:
          'Soak, then let it go fully dry. Soft, mushy leaves usually mean too much water.',
      lightNote:
          'Bright sun or a south window. Dim rooms make it stretch and pale.',
      soilNote:
          'Sandy cactus mix. Never use a pot without drainage.',
      temperature: '13–27°C',
      hardiness: '9 to 11',
      order: 'Asparagales',
      genus: 'Aloe',
      family: 'Asphodelaceae',
      taxonClass: 'Monocotyledonae',
      nameStory:
          'Aloe vera means “true aloe.” The gel in the leaves made it a household first-aid plant long before it sat on windowsills.',
      pests: TrendingPest.succulent,
      toxicity: const PlantToxicity(
        toxicToPets: true,
        toxicToKids: false,
        summary: 'The latex is risky for pets. Inner gel is used on skin, not as food.',
        petsDetail: 'The yellow latex can upset a cat or dog’s stomach.',
        kidsDetail: 'Not a snack. Gel on a scrape is fine; don’t let them eat the leaf.',
      ),
    ),
    TrendingPlant(
      name: 'Snake Plant',
      scientificName: 'Dracaena trifasciata',
      imagePath: 'assets/images/home/trending/trending_snake_plant.png',
      overview:
          'An upright plant with stiff, sword-like leaves. It tolerates low light and infrequent watering better than most houseplants.',
      lightChip: 'Low light',
      waterChip: 'Sparse',
      soilChip: 'Sandy',
      placeChip: 'Indoor',
      waterNote:
          'Water sparingly — every few weeks is typical. Overwatering is the usual killer.',
      lightNote:
          'Low light is fine; brighter light deepens the stripes. Avoid soaking wet soil in shade.',
      soilNote:
          'Sandy or cactus mix. Tight, wet loam holds too much water for this plant.',
      temperature: '15–29°C',
      hardiness: '9 to 11',
      order: 'Asparagales',
      genus: 'Dracaena',
      family: 'Asparagaceae',
      taxonClass: 'Monocotyledonae',
      nameStory:
          'Snake Plant is named for the upright, patterned leaves. It was Sansevieria for years; botanists now place it with Dracaena.',
      pests: TrendingPest.succulent,
      toxicity: const PlantToxicity(
        toxicToPets: true,
        toxicToKids: true,
        summary:
            'Mildly toxic if chewed — keep away from pets and small children.',
        petsDetail:
            'Can irritate cats and dogs if leaves are chewed. Call a vet if they eat any.',
        kidsDetail: 'Sap can irritate skin and mouths. Wash hands after pruning.',
      ),
    ),
    TrendingPlant(
      name: 'Fiddle Leaf Fig',
      scientificName: 'Ficus lyrata',
      imagePath: 'assets/images/home/trending/trending_fiddle_leaf.png',
      overview:
          'A statement ficus with large violin-shaped leaves. It needs consistent bright light and dislikes being moved often.',
      lightChip: 'Bright light',
      waterChip: 'When dry',
      soilChip: 'Loam',
      placeChip: 'Indoor',
      waterNote:
          'Water when the top of the pot is dry. Keep a steady rhythm — it drops leaves after shocks.',
      lightNote:
          'Consistent bright light, same spot. Moving it or a dim corner causes brown spots and drop.',
      soilNote:
          'Loam that drains. A snug pot is better than a huge wet one.',
      temperature: '18–30°C',
      hardiness: '10 to 12',
      order: 'Rosales',
      genus: 'Ficus',
      family: 'Moraceae',
      taxonClass: 'Dicotyledonae',
      nameStory:
          'Fiddle Leaf Fig is named for violin-shaped leaves. It became a design staple because one plant can fill a corner like a sculpture.',
      pests: TrendingPest.house,
      toxicity: const PlantToxicity(
        toxicToPets: true,
        toxicToKids: true,
        summary: 'Sap and leaves can irritate pets and kids if chewed.',
        petsDetail: 'Keep cats and dogs from chewing the large leaves.',
        kidsDetail: 'Sap can irritate skin. Wash hands after wiping dust.',
      ),
    ),
    TrendingPlant(
      name: 'Monstera',
      scientificName: 'Monstera deliciosa',
      imagePath: 'assets/images/home/trending/trending_monstera.png',
      overview:
          'A climbing aroid known for split, fenestrated leaves. It grows best in bright, indirect light with a chunky, airy mix.',
      lightChip: 'Bright indirect',
      waterChip: 'When dry',
      soilChip: 'Chunky mix',
      placeChip: 'Indoor',
      waterNote:
          'Water when the top inch is dry. Yellow leaves usually mean the mix stayed wet too long.',
      lightNote:
          'Bright, indirect light. Splits show up with enough light; a dark corner stays juvenile.',
      soilNote:
          'Chunky aroid mix — bark, perlite, and peat. Dense garden soil smothers the roots.',
      temperature: '18–30°C',
      hardiness: '10 to 12',
      order: 'Alismatales',
      genus: 'Monstera',
      family: 'Araceae',
      taxonClass: 'Monocotyledonae',
      nameStory:
          'Monstera deliciosa means “delicious monster” — the ripe fruit is edible. The splits in the leaves are how it catches light in a forest.',
      pests: TrendingPest.house,
      toxicity: const PlantToxicity(
        toxicToPets: true,
        toxicToKids: true,
        summary: 'Leaves are irritating if chewed. Ripe fruit is a different story.',
        petsDetail: 'Keep cats and dogs from chewing the leaves.',
        kidsDetail: 'Unripe fruit and sap can irritate. Supervise around the plant.',
      ),
    ),
  ];
}
