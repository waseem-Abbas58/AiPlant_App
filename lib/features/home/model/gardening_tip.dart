class GardeningTip {
  const GardeningTip({
    required this.imagePath,
    required this.title,
    required this.cardLine,
    required this.overview,
    this.cardTitle,
    required this.steps,
  });

  final String imagePath;
  final String title;
  final String cardLine;
  final String overview;
  final String? cardTitle;
  final List<String> steps;

  String get listTitle => cardTitle ?? title;

  static const catalog = <GardeningTip>[
    GardeningTip(
      imagePath: 'assets/images/home/tips/trim_spent_blooms.png',
      cardTitle: 'Trim Spent Blooms',
      title: 'Trim Spent Blooms to Encourage New Growth',
      cardLine:
          'Deadheading flowering houseplants like begonias, peace lilies, or African violets helps them conserve energy and redirect it into new blooms.',
      overview:
          'Deadheading flowering houseplants like begonias, peace lilies, or African violets helps them conserve energy and redirect it into new blooms. Use sterilized scissors and snip off the faded flowers just above the leaf joint. This small step keeps your plants looking tidy and encourages longer bloom cycles.',
      steps: [
        'Wait until the bloom is brown or papery — leave anything still opening.',
        'Follow the stalk down to a leaf joint, or to the base of a spent peace-lily spathe.',
        'Snip with clean scissors, or pinch a soft stem between thumb and finger.',
        'Bin the spent bloom so it does not mold in the pot.',
      ],
    ),
    GardeningTip(
      imagePath: 'assets/images/home/tips/let_soil_dry.png',
      title: 'Let Soil Dry First',
      cardLine:
          'Check the top inch with your finger before watering. Most houseplants prefer a light dry spell over soggy roots.',
      overview:
          'Before you water, press a finger into the top inch of mix. If it still feels cool and wet, wait. Most houseplants prefer a short dry spell over sitting in soggy roots. Water thoroughly when that top layer is dry, then let extra drain away. This simple check prevents rot better than watering on a fixed calendar.',
      steps: [
        'Press a finger into the top inch of mix — not just the dry crust on top.',
        'If it feels cool and wet, wait. If it is dry, it is time to water.',
        'Water until it runs from the holes, then empty the saucer.',
        'Check again in a few days. Do not water on a fixed weekday.',
      ],
    ),
    GardeningTip(
      imagePath: 'assets/images/home/tips/rotate_for_light.png',
      title: 'Rotate for Even Light',
      cardLine:
          'Turn the pot a quarter turn each week so every side gets sun and the plant grows full instead of leaning.',
      overview:
          'Indoor light almost always comes from one window, so a plant leans toward it and the back stays thin. Give the pot a quarter turn once a week so every side gets a share of the sun. The habit stays compact and full instead of stretching to one side. Mark a spot on the pot if you forget which way you last turned it.',
      steps: [
        'Note which side faces the window today.',
        'Turn the pot a quarter turn on the same day each week.',
        'If it still leans hard, turn a little more often.',
        'A small mark on the pot helps you remember the last turn.',
      ],
    ),
    GardeningTip(
      imagePath: 'assets/images/home/tips/wipe_dusty_leaves.png',
      title: 'Wipe Dusty Leaves',
      cardLine:
          'Dust blocks light. Wipe leaves with a soft damp cloth so the plant can photosynthesize and stay glossy.',
      overview:
          'Dust on leaves blocks light, so the plant cannot photosynthesize well and looks dull. Wipe both sides with a soft damp cloth, supporting the leaf with your other hand so it does not tear. Skip harsh shine sprays. A clean leaf stays glossy and can breathe. Do this when you see a film, not so often that you bruise new growth.',
      steps: [
        'Dampen a soft cloth. Skip leaf-shine sprays.',
        'Hold the leaf from below so it does not tear.',
        'Wipe the top, then the dusty underside.',
        'Stop on soft new growth — do not scrub it.',
      ],
    ),
    GardeningTip(
      imagePath: 'assets/images/home/tips/bottom_watering.png',
      title: 'Bottom Watering',
      cardLine:
          'Set the pot in a saucer of water and let the soil drink from below. Stop once the top feels evenly moist.',
      overview:
          'Set the pot in a saucer or tray of water and let the mix drink from the drainage holes. Stop when the top feels evenly moist, then lift the pot out so it is not sitting in a puddle. Bottom watering wets the root ball without washing mix off the surface. Use it when the top crusts dry but the plant still needs a full drink — not as the only method if salts build up.',
      steps: [
        'Fill a saucer or tray with a few centimetres of water.',
        'Set the pot in so the drainage holes can drink.',
        'Stop when the top of the mix feels evenly moist.',
        'Lift the pot out. Do not leave it sitting in leftover water.',
      ],
    ),
  ];
}
