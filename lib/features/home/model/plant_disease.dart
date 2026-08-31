class PlantDisease {
  const PlantDisease({
    required this.imagePath,
    required this.title,
    required this.overview,
    this.kind,
    this.severity,
    this.hosts,
    this.symptoms = const [],
    this.treatSteps = const [],
    this.spreadsWhen,
    this.prevention,
    this.caution,
    this.lookalikeTitle,
    this.lookalikeHint,
  });

  final String imagePath;
  final String title;
  final String overview;
  final String? kind;
  final String? severity;
  final String? hosts;
  final List<String> symptoms;
  final List<String> treatSteps;
  final String? spreadsWhen;
  final String? prevention;
  final String? caution;
  final String? lookalikeTitle;
  final String? lookalikeHint;

  bool get hasGuide =>
      symptoms.isNotEmpty &&
      treatSteps.isNotEmpty &&
      prevention != null &&
      caution != null;

  PlantDisease? get lookalike {
    final name = lookalikeTitle;
    if (name == null || name.isEmpty) return null;
    for (final item in catalog) {
      if (item.title == name) return item;
    }
    return null;
  }

  static const catalog = <PlantDisease>[
    PlantDisease(
      imagePath: 'assets/images/home/diseases/downy_mildew.png',
      title: 'Downy Mildew',
      kind: 'Water mold',
      severity: 'Fast in damp rooms',
      hosts: 'Basil, impatiens, coleus, grapes',
      overview:
          'A water-mold that likes cool, still, damp air. Pale patches show on the top of the leaf; a grey or purple fuzz sits on the underside. It spreads by splash — not by dry dust. Catch it early so new leaves stay clean.',
      symptoms: [
        'Yellow or pale patches on the upper leaf, often angular.',
        'Grey, lilac or dirty-white fuzz on the underside — flip the leaf to check.',
        'Leaves may curl, crisp, or drop if the air stays wet and still.',
      ],
      treatSteps: [
        'Move the plant away from others. Don’t mist.',
        'Pick off marked leaves and bag them. Don’t compost them.',
        'Water the soil, not the leaves. Give space so air can move.',
        'If new fuzz keeps appearing, use a houseplant fungicide labeled for downy mildew — or discard a plant that has collapsed.',
      ],
      spreadsWhen:
          'Cool nights, wet leaves, and pots packed together. Dry, breezy rooms slow it down.',
      prevention:
          'Don’t leave leaves wet overnight. Space pots. Skip misting in a closed room. New plants: check the leaf underside before they join the shelf.',
      caution:
          'Kitchen sprays won’t reach it. Keep treated mix away from pets.',
      lookalikeTitle: 'Powdery Mildew',
      lookalikeHint:
          'White dust on the TOP of the leaf. Downy lives underneath.',
    ),
    PlantDisease(
      imagePath: 'assets/images/home/diseases/anthracnose.png',
      title: 'Anthracnose',
      kind: 'Fungus',
      severity: 'Spreads in wet weather',
      hosts: 'Palms, beans, tomatoes, mango, citrus',
      overview:
          'A leaf-spot fungus that bites sunken, dark patches into leaf and fruit. Spots often have a pale centre and a darker ring. In wet air it throws tiny orange or pink spore dots. It rides splash — not dry dust.',
      symptoms: [
        'Brown or black sunken spots, sometimes with a yellow halo.',
        'Spots may join up; the leaf looks scorched or drops.',
        'On fruit or stems: dark lesions that sink in, sometimes with pink ooze when wet.',
      ],
      treatSteps: [
        'Pick off marked leaves and bag them. Don’t compost them.',
        'Stop wetting the foliage. Water the soil, not the crown.',
        'Give space so leaves dry after watering.',
        'If new spots keep appearing, use a houseplant fungicide labeled for leaf spot / anthracnose.',
      ],
      spreadsWhen:
          'Warm, wet leaves and crowded pots. Splash from watering moves spores. Dry foliage slows it down.',
      prevention:
          'Water the soil, not the leaves. Space plants. Wipe or prune old spotted leaves. Quarantine new plants with dark sunken spots.',
      caution:
          'Kitchen oils won’t clear it. Keep treated mix away from pets. Don’t confuse sunken spots with simple sun scorch — scorch has no pink ooze.',
      lookalikeTitle: 'Late Blight',
      lookalikeHint:
          'Late blight is wet, fast, and greasy. Anthracnose spots stay sunken and slower.',
    ),
    PlantDisease(
      imagePath: 'assets/images/home/diseases/spider_mites.png',
      title: 'Spider Mites',
      kind: 'Pest',
      severity: 'Fast in dry rooms',
      hosts: 'Most houseplants — figs, calathea, roses, herbs',
      overview:
          'Tiny mites, not a fungus. They suck sap from the underside of the leaf. Fine stippling shows on top; silk webbing shows in the crooks when the colony is dense. Dry, warm rooms are a feast.',
      symptoms: [
        'Pale pin-pricks or a dusty, faded look on the upper leaf.',
        'Fine webbing between stem and leaf, or along the underside.',
        'Leaves may crisp, curl, or drop if the air stays dry and hot.',
      ],
      treatSteps: [
        'Move the plant away from others. Wipe or rinse both sides of the leaves.',
        'Raise humidity and ease the heat — mites hate still, dry air less when it is moist.',
        'Spray insecticidal soap or neem on the undersides. Repeat after a few days — eggs hatch later.',
        'If webbing returns, prune the worst stems or discard a plant that has collapsed.',
      ],
      spreadsWhen:
          'Warm, dry rooms and dusty leaves. They crawl to the next pot when plants touch. A humid, rinsed plant slows them down.',
      prevention:
          'Don’t let the air bake. Dust the leaves. Space pots so they don’t touch. Check the underside when you bring a new plant home.',
      caution:
          'This is a pest, not mildew — fungicide will not help. Keep soap and neem away from pets until dry. Don’t blast with oil in hot sun; it can burn the leaf.',
    ),
    PlantDisease(
      imagePath: 'assets/images/home/diseases/botrytis.png',
      title: 'Botrytis',
      kind: 'Fungus',
      severity: 'Fast on dying tissue',
      hosts: 'Flowers, tomatoes, lettuce, succulents after wounds',
      overview:
          'Grey mold. It starts on spent blooms, dead leaves, or a wound, then a soft grey-brown fuzz swallows nearby tissue. Cool, still, damp air is its room. It is a rot, not a dust on a healthy leaf.',
      symptoms: [
        'Grey or brown fuzzy mold on flowers, stems, or soft leaves.',
        'Tissue turns mushy or tan where the fuzz sits.',
        'It often starts on a dead bloom or a cut, then creeps onto green parts.',
      ],
      treatSteps: [
        'Cut away every fuzzy or mushy bit. Bag it. Don’t compost it.',
        'Stop misting. Open space so air can move. Don’t leave dead flowers on the plant.',
        'Water the soil, not the blooms. Let the surface dry between drinks.',
        'If fuzz returns on new tissue, use a houseplant fungicide labeled for grey mold / botrytis — or discard a plant that has collapsed.',
      ],
      spreadsWhen:
          'Cool nights, wet petals, and pots packed together. Dead tissue left on the plant is a starter. Dry, breezy rooms slow it down.',
      prevention:
          'Deadhead spent blooms. Don’t mist flowers. Space pots. Clean up fallen leaves in the saucer.',
      caution:
          'Kitchen sprays won’t reach grey mold. Keep treated mix away from pets. Don’t seal a wet plant in a plastic bag — that is a botrytis tent.',
      lookalikeTitle: 'Late Blight',
      lookalikeHint:
          'Late blight is greasy and fast on tomato-family leaves. Botrytis is grey fuzz on dead or wounded tissue.',
    ),
    PlantDisease(
      imagePath: 'assets/images/home/diseases/late_blight.png',
      title: 'Late Blight',
      kind: 'Water mold',
      severity: 'Fast in cool wet spells',
      hosts: 'Tomato, potato, related nightshades',
      overview:
          'A water-mold famous for collapsing tomatoes and potatoes in cool, wet weather. Dark greasy patches race across leaf and fruit; a pale fuzz may sit on the underside when the air is wet. It is splash-borne and quick — not a slow sunken spot.',
      symptoms: [
        'Water-soaked, greasy brown or black patches on leaves, often from the edge in.',
        'White or grey fuzz on the underside in humid air.',
        'Fruit or stems may brown and rot fast; the plant can collapse in days.',
      ],
      treatSteps: [
        'Isolate the plant. Don’t mist. Don’t let leaves stay wet overnight.',
        'Pick off marked leaves and bag them. Don’t compost them — this one belongs in the bin.',
        'Water the soil, not the leaves. Give space so air can move.',
        'If new greasy patches keep appearing, use a product labeled for late blight / Phytophthora — or discard a plant that has collapsed. Don’t save seed from rotten fruit.',
      ],
      spreadsWhen:
          'Cool nights, wet leaves, and plants packed together. Spores travel on splash and damp air. Dry foliage slows it down.',
      prevention:
          'Don’t wet the leaves at night. Space plants. Clear fallen foliage. New tomato or potato starts: check for greasy spots before they join the shelf.',
      caution:
          'This is not a kitchen-spray problem. Keep treated mix away from pets. Don’t compost blighted material — you can seed the next crop.',
      lookalikeTitle: 'Botrytis',
      lookalikeHint:
          'Botrytis is grey fuzz on spent blooms. Late blight is greasy, fast rot on tomato-family tissue.',
    ),
    PlantDisease(
      imagePath: 'assets/images/home/diseases/powdery_mildew.png',
      title: 'Powdery Mildew',
      kind: 'Fungus',
      severity: 'Common in still rooms',
      hosts: 'Cucurbits, roses, begonia, many houseplants',
      overview:
          'A true fungus that sits as a white or grey dust on the TOP of the leaf — like flour you can wipe. It likes dry days and humid, still nights. Unlike downy mildew, it does not need a wet leaf to start.',
      symptoms: [
        'White or grey powder on the upper leaf, stems, or buds.',
        'You can often rub a little off with a finger.',
        'Leaves may yellow, distort, or drop if it coats them for weeks.',
      ],
      treatSteps: [
        'Move the plant into brighter air. Don’t crowd it.',
        'Wipe or prune the worst leaves and bag them.',
        'Water the soil, not the leaves. Ease off heavy nitrogen feed that makes soft new growth.',
        'If the dust returns, use a houseplant fungicide or potassium bicarbonate labeled for powdery mildew.',
      ],
      spreadsWhen:
          'Still rooms, dry leaf surfaces, and humid nights. Spores ride the air — not only splash. A breeze and space slow it down.',
      prevention:
          'Give air and light. Don’t pack pots. Skip misting as a habit. Check new plants for white dust on the top of the leaf.',
      caution:
          'Milk or kitchen sprays are hit-and-miss and can smell. Keep treated mix away from pets. Don’t confuse this with dust — mildew grows back in the same patches.',
      lookalikeTitle: 'Downy Mildew',
      lookalikeHint:
          'Downy is pale on top and fuzzy underneath. Powdery is a wipeable dust on the TOP.',
    ),
  ];
}
