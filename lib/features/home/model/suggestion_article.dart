class SuggestionSection {
  const SuggestionSection({
    required this.heading,
    this.paragraphs = const [],
    this.steps = const [],
    this.bullets = const [],
  });

  final String heading;
  final List<String> paragraphs;
  final List<String> steps;
  final List<String> bullets;
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
            'The four cacti in the same terracotta pots are four species — not four “looks” of one plant. A species is the plant as it exists in nature. A variety is a natural twist inside that species: same kind, a slightly different look.',
            'Garden shops often say “variety” when they mean a cultivar. That mix-up is why two labels on the same shelf can look like two different plants.',
          ],
        ),
        SuggestionSection(
          heading: 'What a species is',
          paragraphs: [
            'The scientific name has two parts: genus + species. Written in italics, such as Monstera deliciosa. Plants of the same species share enough traits that they can typically reproduce with one another in the wild.',
          ],
        ),
        SuggestionSection(
          heading: 'What a variety is',
          paragraphs: [
            'A variety shows up in nature — leaf color, flower form, or habit — and is written with “var.”, for example Hedera helix var. helix.',
          ],
          bullets: [
            'Variety — wild difference, written with var.',
            'Cultivar — chosen or bred by people, written in quotes, such as ‘Golden Pothos’.',
            'Same species can have many varieties and cultivars. The species name stays the same.',
          ],
        ),
      ],
    ),
    SuggestionArticle(
      imagePath: 'assets/images/home/suggestions/plant_styling.png',
      category: 'Life Style',
      title: 'Style a plant corner at home',
      sections: [
        SuggestionSection(
          heading: 'Overview',
          paragraphs: [
            'A plant corner is not one hero pot. It is a table, a few cuttings, hanging vines, and space to pot without rushing. Group greens at different heights so the room feels full, not cluttered.',
          ],
        ),
        SuggestionSection(
          heading: 'What to set out',
          bullets: [
            'A tray or table you can get dirty — soil will spill.',
            'Nursery pots, a mix bin, and a bowl of clay pebbles for drainage.',
            'A jar of cuttings and one plant you are potting now.',
            'A hanging vine or tall snake plant behind, so the table is not a flat line.',
          ],
        ),
        SuggestionSection(
          heading: 'While you pot',
          steps: [
            'Work in good light so you can see the roots.',
            'Gloves help with mix; they are not required for every plant.',
            'Set the plant at the same soil line it had before.',
            'Wipe the table when you are done — leftover mix invites fungus gnats.',
          ],
        ),
      ],
    ),
    SuggestionArticle(
      imagePath: 'assets/images/home/suggestions/beginner_houseplants.png',
      category: 'Plant Care',
      title: 'Easy houseplants to start with',
      sections: [
        SuggestionSection(
          heading: 'Overview',
          paragraphs: [
            'These six are the usual first shelf: snake plant, peace lily, spider plant, pothos, ZZ plant, and Chinese evergreen. They forgive a missed watering better than a fussy fern. Learn their names on the pot — then you can look up water and light without guessing.',
          ],
        ),
        SuggestionSection(
          heading: 'The six',
          bullets: [
            'Snake plant — upright swords; dries out between drinks.',
            'Peace lily — droops when thirsty; likes even moisture, not a swamp.',
            'Spider plant — arching striped leaves; pups for free plants.',
            'Pothos — heart-shaped vines; bright or medium light.',
            'ZZ plant — waxy leaflets; very dry-tolerant.',
            'Chinese evergreen — patterned leaves; skip harsh sun.',
          ],
        ),
        SuggestionSection(
          heading: 'How to not lose them',
          bullets: [
            'Pot with a hole. Saucer, not a sealed cachepot full of water.',
            'Start in bright indirect light. Move closer to the window only if they stretch.',
            'Water when the top of the mix is dry — not on a fixed weekday.',
          ],
        ),
      ],
    ),
    SuggestionArticle(
      imagePath: 'assets/images/home/suggestions/repotting_basics.png',
      category: 'Plant Care',
      title: 'When it’s time to repot a plant',
      sections: [
        SuggestionSection(
          heading: 'Overview',
          paragraphs: [
            'Repotting is not a yearly ritual. Move up when roots have filled the pot, water races straight through, or growth has stalled despite decent light. One size up — about 2–5 cm wider — is enough. A huge pot stays wet too long and can rot roots.',
          ],
        ),
        SuggestionSection(
          heading: 'Signs it is time',
          bullets: [
            'Roots circling the surface or pushing out of the holes.',
            'The pot dries in a day, or the plant tips over easily.',
            'Spring and early summer are the gentlest seasons to repot.',
          ],
        ),
        SuggestionSection(
          heading: 'How to do it',
          steps: [
            'Water the day before so the root ball slides out cleanly.',
            'Tease circling roots. Set the plant at the same soil line as before.',
            'Fill gaps with a mix that matches the plant — chunky for aroids, gritty for succulents.',
            'Wait about a week before a heavy watering if you disturbed many roots.',
          ],
        ),
      ],
    ),
    SuggestionArticle(
      imagePath: 'assets/images/home/suggestions/seasonal_care.png',
      category: 'Plant Care',
      title: 'Seasonal care for indoor plants',
      sections: [
        SuggestionSection(
          heading: 'Overview',
          paragraphs: [
            'Indoor plants still follow the year. A bright windowsill in winter can outshine a shaded porch in summer. Longer days push new leaves; short, dry winter air slows growth. Care that worked in July often fails in January. Watch the plant, not only the calendar.',
          ],
        ),
        SuggestionSection(
          heading: 'Spring and summer',
          bullets: [
            'Water as the mix dries faster.',
            'Feed a diluted fertilizer every two to four weeks while it is growing.',
            'Prune, propagate, and repot in this window.',
            'Keep leaves off hot glass — midday sun through a window can scorch.',
          ],
        ),
        SuggestionSection(
          heading: 'Autumn and winter',
          bullets: [
            'Cut back on water. Stop or reduce fertilizer while growth pauses.',
            'Group plants or use a pebble tray if the air is very dry.',
            'Move sensitive plants away from heaters and cold drafts.',
            'Check undersides of leaves every week or two — pests show up on stressed plants.',
          ],
        ),
      ],
    ),
  ];
}
