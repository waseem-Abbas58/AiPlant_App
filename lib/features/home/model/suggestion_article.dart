class SuggestionSection {
  const SuggestionSection({
    required this.heading,
    required this.paragraphs,
  });

  final String heading;
  final List<String> paragraphs;
}

class SuggestionArticle {
  const SuggestionArticle({
    required this.imagePath,
    required this.category,
    required this.title,
    required this.sections,
  });

  final String imagePath;
  final String category;
  final String title;
  final List<SuggestionSection> sections;

  static const List<SuggestionArticle> samples = [
    SuggestionArticle(
      imagePath: 'assets/images/home/suggestions/species_vs_variety.png',
      category: 'Life Style',
      title: 'Differences between Species and Varieties',
      sections: [
        SuggestionSection(
          heading: 'Overview',
          paragraphs: [
            'Distinguishing between a species and a subspecies can be difficult: most people are aware of the definition of a species, but when it comes to defining a subspecies, it can be a bit hazy and subjective.',
            'Technically, a species is a population or groups of populations that can potentially interbreed freely within and among themselves. This is a naturally-defined concept, something which exists by itself. Subspecies, on the other hand, are subgroups within a species that have different traits and are defined by scientists. Let’s examine this concept more closely.',
          ],
        ),
        SuggestionSection(
          heading: 'What a species is',
          paragraphs: [
            'In 1735, Carl von Linné revolutionized biology by introducing a new system of classification — modern taxonomy. The basic unit of this taxonomy is a species. Species are then grouped together into a genus, genera are grouped into families, and so on, all the way up to the grouping of domain.',
            'A plant’s scientific name is a two-part binomial: the genus and the specific epithet. Together they name one species, written in italics, such as Monstera deliciosa. Plants of the same species share enough traits that they can typically reproduce with one another in nature.',
          ],
        ),
        SuggestionSection(
          heading: 'What a variety is',
          paragraphs: [
            'A variety is a naturally occurring variation within a species — often a difference in leaf color, flower form, or growth habit that shows up in the wild. It is written with “var.”, for example Hedera helix var. helix.',
            'Gardeners often mix this up with cultivars. A cultivar is selected or bred by people and named in quotes, such as ‘Golden Pothos’. Varieties happen in nature; cultivars are maintained by horticulture.',
          ],
        ),
      ],
    ),
    SuggestionArticle(
      imagePath: 'assets/images/home/suggestions/plant_styling.png',
      category: 'Plant Identification',
      title: 'Identifying Plant in 10 Steps',
      sections: [
        SuggestionSection(
          heading: 'Overview',
          paragraphs: [
            'Identifying a plant is easier when you work through the same checks every time. Use these ten steps with a clear photo of the leaves, stem, and pot or habitat.',
          ],
        ),
        SuggestionSection(
          heading: 'The 10 steps',
          paragraphs: [
            '1. Photograph the whole plant, then a close-up of one mature leaf.\n2. Note leaf shape: heart, oval, lance, palmate, or needle.\n3. Check the leaf edge: smooth, toothed, or lobed.\n4. Look at venation — parallel, pinnate, or palmate veins.\n5. Record stem type: woody, succulent, vining, or rosette.\n6. If there are flowers or fruit, photograph color and arrangement.\n7. Observe the potting mix and whether it stays wet or dries fast.\n8. Compare growth habit: upright, trailing, clumping, or climbing.\n9. Match these traits in a plant ID tool or field guide.\n10. Confirm with a second source before you treat pests or repot.',
          ],
        ),
      ],
    ),
    SuggestionArticle(
      imagePath: 'assets/images/home/suggestions/beginner_houseplants.png',
      category: 'Life Style',
      title: 'Same seeds but different looking plants',
      sections: [
        SuggestionSection(
          heading: 'Overview',
          paragraphs: [
            'Two plants grown from the same seed packet can still look unlike each other. Light, pot size, watering, and temperature all change how a seedling develops — even when the genetics are the same.',
            'Gardeners often assume a “different look” means a different species. More often it is the growing environment. Leaf size, color, and internodal spacing respond quickly to stress or to better care.',
          ],
        ),
        SuggestionSection(
          heading: 'Why seedlings diverge',
          paragraphs: [
            'A plant in a bright window stretches less and keeps thicker leaves. The same variety in a dim corner grows long, thin stems and paler foliage. That is etiolation, not a new cultivar.',
            'Uneven watering does the same thing. One pot that stays soggy may yellow and stall; its sibling that dries between drinks stays compact. Always compare care before you rename the plant.',
          ],
        ),
        SuggestionSection(
          heading: 'What to check',
          paragraphs: [
            'Match light hours, pot volume, and soil mix if you want even growth. Rotate pots weekly so one side does not lean. If you truly have two varieties mixed in a packet, wait until true leaves appear — cotyledons look alike on many species.',
          ],
        ),
      ],
    ),
    SuggestionArticle(
      imagePath: 'assets/images/home/suggestions/repotting_basics.png',
      category: 'Plant Care',
      title: 'When to Repot',
      sections: [
        SuggestionSection(
          heading: 'Overview',
          paragraphs: [
            'Repotting is not a yearly ritual. A plant needs a new pot when roots have filled the old one, when water races straight through, or when growth has stalled despite decent light and feeding.',
            'Moving too soon into a huge pot keeps soil wet for too long and can lead to root rot. One size up — about 2–5 cm wider — is enough for most houseplants.',
          ],
        ),
        SuggestionSection(
          heading: 'Signs it is time',
          paragraphs: [
            'Roots circling the surface or pushing out of drainage holes, a pot that dries in a day, or a plant that tips over easily are the usual cues. Spring and early summer are the gentlest seasons to repot, when the plant can grow into fresh mix quickly.',
          ],
        ),
        SuggestionSection(
          heading: 'How to do it',
          paragraphs: [
            'Water the day before so the root ball slides out cleanly. Tease circling roots, set the plant at the same soil line as before, and fill gaps with a mix that matches the species — chunky for aroids, gritty for succulents. Wait about a week before a heavy watering if you disturbed many roots.',
          ],
        ),
      ],
    ),
    SuggestionArticle(
      imagePath: 'assets/images/home/suggestions/seasonal_care.png',
      category: 'Plant Care',
      title: 'Seasonal Plant Care',
      sections: [
        SuggestionSection(
          heading: 'Overview',
          paragraphs: [
            'Indoor plants still follow the year. Longer days in spring push new leaves; shorter, drier winter air slows growth. Care that worked in July often fails in January if you do not adjust water, light, and feeding.',
            'Watch the plant, not the calendar alone. A south window in winter can be brighter than a shaded porch in summer. Change one habit at a time so you can see what helped.',
          ],
        ),
        SuggestionSection(
          heading: 'Spring and summer',
          paragraphs: [
            'Increase watering as soil dries faster, and resume a diluted fertilizer every two to four weeks for plants that are actively growing. This is also the window to prune, propagate, and repot. Keep leaves off hot glass; midday sun through a window can scorch.',
          ],
        ),
        SuggestionSection(
          heading: 'Autumn and winter',
          paragraphs: [
            'Cut back on water and stop or reduce fertilizer while growth pauses. Group plants, use a pebble tray, or run a humidifier if indoor air is very dry. Move sensitive species away from heaters and cold drafts. Most pests show up in winter on stressed plants — check undersides of leaves every week or two.',
          ],
        ),
      ],
    ),
  ];
}
