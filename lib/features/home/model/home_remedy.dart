class HomeRemedy {
  const HomeRemedy({
    required this.imagePath,
    required this.title,
    required this.problem,
    required this.steps,
    required this.caution,
    this.duration,
    this.problemLabel,
    this.petsNote,
    this.cardTitle,
    this.overview,
    this.whyToUse,
    this.whenToUse,
  });

  final String imagePath;
  final String title;
  final String problem;
  final List<String> steps;
  final String caution;
  final String? duration;
  final String? problemLabel;
  final String? petsNote;
  final String? cardTitle;
  final String? overview;
  final String? whyToUse;
  final String? whenToUse;

  bool get hasGuide =>
      overview != null && whyToUse != null && whenToUse != null;

  static const catalog = <HomeRemedy>[
    HomeRemedy(
      imagePath: 'assets/images/home/remedies/cinnamon_root_rot.png',
      title: 'Cinnamon Shield for Root Rot',
      problem:
          'Use when the mix stays wet and stems or roots look dark and soft. Kitchen cinnamon is a light first step — not a cure for a collapsed plant.',
      steps: [
        'Unpot the plant and shake off soggy mix. Cut away black, mushy roots with clean scissors.',
        'Let the healthy roots air for 20–30 minutes so the cuts dry.',
        'Dust a thin layer of ground cinnamon on the cuts and remaining roots.',
        'Repot in fresh, draining mix. Water lightly, then wait until the top feels dry.',
      ],
      caution:
          'Cinnamon is a kitchen first step, not a fungicide. If the crown is mush, skip the powder and unpot. Keep it off pets and do not eat treated mix.',
      duration: '10 min',
      problemLabel: 'Root rot',
      petsNote: 'Keep off pets',
      cardTitle: 'Cinnamon Shield',
      overview:
          'Ground kitchen cinnamon on a houseplant stuck in soggy mix. After you unpot, a thin dust on fresh root cuts is a first shield — not a bottle fungicide, and not a rescue if the crown is already gone.',
      whyToUse:
          'Rot spreads where wet mix hugs damaged roots. Unpotting lets you see what is black and cut it away. Cinnamon dries on those cuts so the surface is less slimy while you move the plant into draining mix. Powder on top of soaked soil only cakes; it never reaches the roots.',
      whenToUse:
          'The pot stays wet for days and lower roots or stem feel dark and soft, but the crown is still firm. Skip this when the plant has flopped or the crown is mush — that is a collapse, not a cinnamon tweak.',
    ),
    HomeRemedy(
      imagePath: 'assets/images/home/remedies/aloe_sunburn.png',
      title: 'Aloe Gel for Leaf Burn',
      problem:
          'Use on leaves that feel crisp or show pale, bleached patches after strong sun. Helps the surface; it will not reverse a fully dead patch.',
      steps: [
        'Move the plant out of direct midday sun.',
        'Split a fresh aloe leaf and scoop the clear inner gel. Skip yellow sap near the skin.',
        'Dab a thin coat on the burned spots. Do not soak the crown or soil.',
        'Leave it to dry. Repeat the next day if the leaf still looks tight and dry.',
      ],
      caution:
          'Use only the clear inner gel. Yellow sap can irritate skin and eyes. Aloe is not safe for pets to chew. Dead brown tissue will not turn green again.',
      problemLabel: 'Sunburn',
      petsNote: 'Not for pets to chew',
      cardTitle: 'Aloe Gel',
      overview:
          'Clear gel from a split aloe leaf on a leaf that went pale and tight in harsh sun. It soothes the surface. A brown, papery patch will not turn green again.',
      whyToUse:
          'Midday sun strips the leaf skin. The clear inner gel — not the yellow sap by the skin — sits as a thin coat so the burn does not stay tight while you move the plant out of the glare. It is not feed, and it will not paint over dead tissue.',
      whenToUse:
          'After strong sun, leaves feel crisp or show bleached patches and the rest of the leaf is still alive. Skip once the patch is brown through — that part is gone.',
    ),
    HomeRemedy(
      imagePath: 'assets/images/home/remedies/neem_oil_pests.png',
      title: 'Neem Oil Spray for Pests',
      problem:
          'Use when you see mites, aphids, or a sticky film on leaves. Spray in the evening so sun does not scorch oily leaves.',
      steps: [
        'Mix a few drops of pure neem oil with a drop of mild soap in 1 litre of lukewarm water. Shake well.',
        'Wipe dusty leaves first so the spray can reach the pests.',
        'Spray both sides of the leaves until they glisten. Keep it off open flowers if you can.',
        'Repeat every 5–7 days for two more rounds. Rinse the plant if residue builds up.',
      ],
      caution:
          'Spray in the evening. Sun on oily leaves can burn. Keep spray off kids, pets, and fish water. On herbs you eat, rinse well and use a food-safe label only.',
      problemLabel: 'Pests',
      petsNote: 'Keep spray off pets',
      cardTitle: 'Neem Spray',
      overview:
          'An evening mist of diluted neem on leaves with mites, aphids, or a sticky film. Oil plus a drop of soap in water — not a one-spray clean-out.',
      whyToUse:
          'Pests hide in dust and under leaves. Soap lets the oil mix with water so you can coat both sides. Evening spray so sun does not cook oily leaves. Eggs hatch later, so you repeat; one pass is not enough.',
      whenToUse:
          'You can see mites, aphids, or a sticky film on the leaves. Not in hot midday, not as a weekly splash on clean plants, and keep it off open flowers if you can.',
    ),
    HomeRemedy(
      imagePath: 'assets/images/home/remedies/eggshell_calcium.png',
      title: 'Eggshells for Calcium',
      problem:
          'Use as a slow calcium top-up in potting mix, especially for fruiting plants. It will not fix a plant that is already collapsing.',
      steps: [
        'Rinse shells and let them dry fully so they do not smell.',
        'Crush to a coarse powder — a rolling pin or blender both work.',
        'Mix a spoon into the top of the pot, or work a little into fresh mix at repot.',
        'Water as usual. This breaks down slowly; do not pile a thick crust on the soil.',
      ],
      caution:
          'Rinse shells first. This is a slow soil top-up, not a calcium pill for people. A thick crust can block water and invite mold.',
      problemLabel: 'Calcium',
      cardTitle: 'Eggshells',
      overview:
          'Rinsed, dry, crushed eggshell worked into potting mix as slow calcium — useful on fruiting pots, not a rescue drink for a plant that is already failing.',
      whyToUse:
          'Shells break down slowly in the mix. Rinse and dry so they do not smell. A coarse crush feeds the soil over time; a thick crust on top blocks water and can mold. This is not a tablet for people.',
      whenToUse:
          'The plant is growing or fruiting and otherwise steady. Not for a collapsing plant, and not as an overnight fix for weak new growth.',
    ),
    HomeRemedy(
      imagePath: 'assets/images/home/remedies/banana_peel_fertilizer.png',
      title: 'Banana Peel Fertilizer',
      problem:
          'Use as a mild potassium boost in the growing season. It is a kitchen extra, not a full fertilizer.',
      steps: [
        'Chop a clean peel into small pieces, or soak pieces in water for 1–2 days.',
        'Bury the pieces a finger deep at the pot edge, or water with the soak (not the slime).',
        'Keep peel off the stem so it does not rot against the plant.',
        'Use every few weeks in spring and summer. Skip it if fungus gnats are already a problem.',
      ],
      caution:
          'Do not leave wet peel on the soil surface — it rot and draws gnats. This is a mild extra, not a full feed. Skip it if the mix already stays wet.',
      problemLabel: 'Feed',
      cardTitle: 'Banana Peel',
      overview:
          'Chopped banana peel or a short peel-soak as a mild potassium extra in the growing months — kitchen leftover, not a full bottle fertilizer.',
      whyToUse:
          'Peel holds potassium. Buried a finger deep at the pot edge it breaks down in the mix. Wet peel left on the surface rots and draws fungus gnats. Use the soak water, not the slime.',
      whenToUse:
          'Spring and summer, when the mix is not already soggy and gnats are not a problem. Skip in winter rest or when the pot stays wet.',
    ),
  ];
}
