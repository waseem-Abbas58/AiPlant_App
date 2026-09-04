import '../../../my_garden/model/my_garden_model.dart';
import '../../model/plant_disease_hint_x.dart';
import '../../model/plant_identify_result.dart';

/// Maps Kindwise Plant.id JSON → locked app models.
/// Identify never reads disease. Diagnose never reads species.
class KindwiseMappers {
  KindwiseMappers._();

  static const _minIdentifyConfidence = 0.18;
  static const _minDiagnoseConfidence = 0.28;
  static const _minAltDiagnoseConfidence = 0.18;

  static PlantIdentifyResult identify(
    Map<String, dynamic> json, {
    required String imagePath,
    String categoryId = 'plant',
  }) {
    final result = _map(json['result']);
    if (!_isPlant(result)) {
      return PlantIdentifyResult.notAPlant(imagePath);
    }

    final suggestions = _suggestionList(result['classification']);
    if (suggestions.isEmpty) {
      return PlantIdentifyResult.noMatch(imagePath);
    }

    final top = suggestions.first;
    final confidence = _probability(top);
    if (confidence < _minIdentifyConfidence) {
      return PlantIdentifyResult.noMatch(imagePath);
    }

    final details = _map(top['details']);
    final scientific = _string(top['name']);
    final common = _firstString(details['common_names']).isNotEmpty
        ? _firstString(details['common_names'])
        : scientific;
    if (common.isEmpty) {
      return PlantIdentifyResult.noMatch(imagePath);
    }

    final similar = <PlantIdentifyMatch>[];
    for (var i = 1; i < suggestions.length && similar.length < 3; i++) {
      final item = suggestions[i];
      final itemDetails = _map(item['details']);
      final name = _firstString(itemDetails['common_names']);
      final science = _string(item['name']);
      final label = name.isNotEmpty ? name : science;
      if (label.isEmpty) continue;
      if (_probability(item) < PlantIdentifyResult.meaningfulSimilarMinConfidence) {
        continue;
      }
      similar.add(
        PlantIdentifyMatch(
          commonName: label,
          scientificName: science,
          confidence: _probability(item),
          imageUrl: _imageUrl(itemDetails, item['similar_images']),
        ),
      );
    }

    final watering = _map(details['watering']);
    final lightText = _string(details['best_light_condition']);
    final waterText = _string(details['best_watering']);
    final soilText = _string(details['best_soil_type']);
    final toxicityText = _string(details['toxicity']);

    return PlantIdentifyResult(
      imagePath: imagePath,
      commonName: common,
      scientificName: scientific,
      confidence: confidence,
      careHighlights: _careHighlights(
        watering: watering,
        waterText: waterText,
        lightText: lightText,
        soilText: soilText,
      ),
      similarMatches: similar,
      kind: _kindFor(categoryId, details),
      toxicity: _toxicity(toxicityText),
      care: _care(watering: watering, lightText: lightText),
      sampleImageUrl: _imageUrl(details, top['similar_images']),
      referenceImageUrls: _imageUrls(details, top['similar_images']),
      isIdentified: true,
      isLocalPreview: false,
    );
  }

  static PlantDiseaseHint diagnose(
    Map<String, dynamic> json, {
    String plantName = '',
    String symptomId = '',
  }) {
    final result = _map(json['result']);
    final healthyBlock = _map(result['is_healthy']);
    final healthyFlag = healthyBlock['binary'] as bool? ??
        ((_num(healthyBlock['probability']) ?? 0) >= 0.6);

    final suggestions = _suggestionList(result['disease']);
    final ranked = _rankDiseases(suggestions, symptomId);
    final top = ranked.isEmpty ? null : ranked.first;
    final topConfidence = top == null ? 0.0 : _probability(top);
    Map<String, dynamic>? topHarmful;
    for (final item in ranked) {
      if (_isHarmful(item) && _probability(item) >= _minDiagnoseConfidence) {
        topHarmful = item;
        break;
      }
    }

    final useIssue = topHarmful != null &&
        (!healthyFlag || _probability(topHarmful) >= 0.45);
    final fallback = !useIssue &&
        !healthyFlag &&
        top != null &&
        topConfidence >= _minDiagnoseConfidence;

    if (!useIssue && !fallback) {
      if (healthyFlag) {
        return _healthyHint(plantName: plantName, symptomId: symptomId);
      }
      return _unnamedIssue();
    }

    final chosen = topHarmful ?? top;
    if (chosen == null) {
      return const PlantDiseaseHint(
        healthy: false,
        title: 'Could not diagnose',
        summary:
            'We could not match a clear issue from these photos. Try one damaged leaf in brighter light.',
        failReason: DiagnoseFailReason.noMatch,
      );
    }

    final primary = _issueFromSuggestion(
      chosen,
      plantName: plantName,
      symptomId: symptomId,
    );
    final used = <String>{
      (primary.diseaseName.isEmpty ? primary.title : primary.diseaseName)
          .trim()
          .toLowerCase(),
    };
    final alternatives = <PlantDiseaseHint>[];
    for (final item in ranked) {
      if (identical(item, chosen)) continue;
      if (_probability(item) < _minAltDiagnoseConfidence) continue;
      final extra = _issueFromSuggestion(item);
      final key = (extra.diseaseName.isEmpty ? extra.title : extra.diseaseName)
          .trim()
          .toLowerCase();
      if (key.isEmpty || used.contains(key)) continue;
      used.add(key);
      alternatives.add(extra);
      if (alternatives.length == 3) break;
    }
    return primary.copyWith(alternatives: alternatives);
  }

  static PlantDiseaseHint _issueFromSuggestion(
    Map<String, dynamic> chosen, {
    String plantName = '',
    String symptomId = '',
  }) {
    final details = _map(chosen['details']);
    final diseaseName = _firstNonEmpty([
      _string(details['local_name']),
      _firstString(details['common_names']),
      _string(chosen['name']),
    ]);
    final description = _string(details['description']);
    final treatment = _map(details['treatment']);
    final biological = _adviceList(treatment['biological']);
    final chemical = _adviceList(treatment['chemical']);
    final prevention = _adviceList(treatment['prevention']);
    final kind = _diseaseKind(details, diseaseName);
    final confidence = _probability(chosen);

    return PlantDiseaseHint(
      healthy: false,
      title: _diseaseTitle(diseaseName, kind),
      diseaseName: diseaseName,
      summary: _diagnoseSummary(
        description: description,
        plantName: plantName,
        symptomId: symptomId,
        diseaseName: diseaseName,
      ),
      confidence: confidence,
      kind: kind,
      severity: _severity(confidence),
      symptoms: _symptoms(description, symptomId),
      steps: [...biological, ...chemical].take(6).toList(),
      prevention: prevention.join(' '),
      caution: chemical.isEmpty
          ? ''
          : 'Keep sprays away from pets and kids. Follow the product label.',
      imageUrl: _imageUrl(details, chosen['similar_images']),
      isLocalPreview: false,
    );
  }

  static PlantDiseaseHint _unnamedIssue() {
    return const PlantDiseaseHint(
      healthy: false,
      title: 'Issue not named',
      summary:
          'This photo looks unhealthy, but no disease name was confident enough to show.',
      steps: [
        'Photograph one damaged leaf so it fills the frame.',
        'Use clear daylight and keep the camera steady.',
        'Add that closer photo here to confirm the issue.',
      ],
    );
  }

  static PlantDiseaseHint _healthyHint({
    required String plantName,
    required String symptomId,
  }) {
    final who = plantName.trim().isEmpty ? 'This plant' : plantName.trim();
    final marked = symptomId.trim().isEmpty
        ? ''
        : ' You marked ${_humanSymptom(symptomId).toLowerCase()} — watch that area for a few days.';
    return PlantDiseaseHint(
      healthy: true,
      title: 'Looks healthy',
      diseaseName: '',
      summary:
          '$who did not show a clear disease, pest, or nutrient problem in these photos.$marked',
      confidence: 0.7,
      steps: const [
        'Keep your usual watering and light routine.',
        'Scan again if new spots, pests, or drooping appear.',
      ],
      isLocalPreview: false,
    );
  }

  static bool _isPlant(Map<String, dynamic> result) {
    final block = result['is_plant'];
    if (block is Map) {
      final map = Map<String, dynamic>.from(block);
      if (map['binary'] is bool) return map['binary'] as bool;
      final probability = _num(map['probability']);
      if (probability != null) return probability >= 0.35;
    }
    if (block is bool) return block;
    if (block is num) return block >= 0.35;
    return true;
  }

  static List<Map<String, dynamic>> _suggestionList(dynamic raw) {
    final root = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
    final list = root['suggestions'];
    if (list is! List) return const [];
    return list.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  static List<Map<String, dynamic>> _rankDiseases(
    List<Map<String, dynamic>> suggestions,
    String symptomId,
  ) {
    if (suggestions.isEmpty) return suggestions;
    final keywords = _symptomKeywords(symptomId);
    if (keywords.isEmpty) return suggestions;

    final top = _probability(suggestions.first);
    final scored = [...suggestions]..sort((a, b) {
        final ap = _probability(a);
        final bp = _probability(b);
        final aBoost = ap >= top - 0.15 && _matchesKeywords(a, keywords) ? 0.08 : 0;
        final bBoost = bp >= top - 0.15 && _matchesKeywords(b, keywords) ? 0.08 : 0;
        return (bp + bBoost).compareTo(ap + aBoost);
      });
    return scored;
  }

  static bool _matchesKeywords(Map<String, dynamic> item, List<String> keywords) {
    final details = _map(item['details']);
    final hay = [
      _string(item['name']),
      _string(details['local_name']),
      _string(details['description']),
      ..._stringList(details['common_names']),
      ..._stringList(details['classification']),
    ].join(' ').toLowerCase();
    return keywords.any(hay.contains);
  }

  static List<String> _symptomKeywords(String symptomId) {
    return switch (symptomId) {
      'yellow_leaves' => const ['yellow', 'chlorosis', 'nitrogen', 'nutrient', 'water'],
      'brown_spots' => const ['spot', 'blight', 'rust', 'anthracnose', 'leaf spot'],
      'drooping' => const ['wilt', 'droop', 'overwater', 'underwater', 'root'],
      'holes' => const ['insect', 'feeding', 'chew', 'pest', 'slug', 'hole'],
      'white_coating' => const ['powdery', 'mildew', 'mealy', 'mold', 'white'],
      'pests' => const ['pest', 'insect', 'mite', 'aphid', 'scale', 'whitefly'],
      _ => const [],
    };
  }

  static bool _isHarmful(Map<String, dynamic> item) {
    final details = _map(item['details']);
    final flag = details['is_harmful'];
    if (flag is bool) return flag;
    final name = _string(item['name']).toLowerCase();
    return !name.contains('senescence') &&
        !name.contains('flower') &&
        !name.contains('lichen') &&
        !name.contains('harmless');
  }

  static IdentifiedKind _kindFor(String categoryId, Map<String, dynamic> details) {
    final taxonomy = _map(details['taxonomy']);
    final kingdom = _string(taxonomy['kingdom']).toLowerCase();
    if (kingdom.contains('fungi')) return IdentifiedKind.mushroom;
    return switch (categoryId) {
      'tree' => IdentifiedKind.tree,
      'mushroom' => IdentifiedKind.mushroom,
      'weed' => IdentifiedKind.weed,
      'disease' => IdentifiedKind.plant,
      _ => IdentifiedKind.plant,
    };
  }

  static PlantToxicity? _toxicity(String text) {
    if (text.isEmpty) return null;
    final pets = _toxicToward(text, const ['cat', 'dog', 'pet', 'animal']);
    final kids = _toxicToward(text, const ['human', 'child', 'kid', 'people', 'ingest']);
    return PlantToxicity(
      toxicToPets: pets,
      toxicToKids: kids,
      summary: text,
      petsDetail: pets ? text : '',
      kidsDetail: kids ? text : '',
    );
  }

  static bool _toxicToward(String text, List<String> subjects) {
    final lower = text.toLowerCase();
    for (final subject in subjects) {
      if (RegExp('non[- ]?toxic[^.\\n]{0,40}$subject').hasMatch(lower)) {
        continue;
      }
      if (RegExp('not toxic[^.\\n]{0,40}$subject').hasMatch(lower)) {
        continue;
      }
      if (RegExp('toxic[^.\\n]{0,40}$subject').hasMatch(lower)) return true;
    }
    return false;
  }

  static GardenCareSchedule _care({
    required Map<String, dynamic> watering,
    required String lightText,
  }) {
    final min = _num(watering['min']) ?? 2;
    final max = _num(watering['max']) ?? 3;
    final avg = (min + max) / 2;
    final waterDays = avg <= 1.5
        ? 14
        : avg <= 2.5
            ? 10
            : avg <= 3.5
                ? 7
                : avg <= 4.5
                    ? 4
                    : 3;
    final waterAmount = avg <= 2.2
        ? 'Light'
        : avg <= 3.6
            ? 'Moderate'
            : 'Generous';
    return GardenCareSchedule(
      waterDays: waterDays,
      waterAmount: waterAmount,
      lightLevel: _lightLevel(lightText),
      syncCalendar: true,
    );
  }

  static List<String> _careHighlights({
    required Map<String, dynamic> watering,
    required String waterText,
    required String lightText,
    String soilText = '',
  }) {
    final highlights = <String>[];
    if (waterText.isNotEmpty) {
      highlights.add(_firstSentence(waterText));
    } else if (watering.isNotEmpty) {
      highlights.add('When the top soil is dry');
    }
    if (lightText.isNotEmpty) {
      highlights.add(_firstSentence(lightText));
    }
    if (soilText.isNotEmpty) {
      highlights.add(_firstSentence(soilText));
    }
    return highlights.take(3).toList();
  }

  static String _lightLevel(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('full sun') ||
        lower.contains('direct') ||
        lower.contains('bright')) {
      return 'Bright';
    }
    if (lower.contains('low') || lower.contains('shade') || lower.contains('dark')) {
      return 'Low';
    }
    return 'Medium';
  }

  static String _diseaseKind(Map<String, dynamic> details, String name) {
    final raw = [
      ..._stringList(details['classification']),
      name,
    ].join(' ').toLowerCase();
    if (raw.contains('fung')) return 'Fungus';
    if (raw.contains('bacter')) return 'Bacteria';
    if (raw.contains('virus')) return 'Virus';
    if (raw.contains('insect') ||
        raw.contains('pest') ||
        raw.contains('mite') ||
        raw.contains('aphid')) {
      return 'Pest';
    }
    if (raw.contains('nutrient') || raw.contains('deficien')) return 'Nutrient';
    if (raw.contains('water') || raw.contains('abiotic')) return 'Abiotic';
    final first = _firstString(details['classification']);
    if (first.isEmpty) return 'Issue';
    return first[0].toUpperCase() + first.substring(1);
  }

  static String _diseaseTitle(String name, String kind) {
    if (name.isEmpty) return 'Possible $kind issue';
    return name;
  }

  static String _severity(double confidence) {
    if (confidence >= 0.75) return 'High';
    if (confidence >= 0.5) return 'Moderate';
    return 'Mild';
  }

  static String _diagnoseSummary({
    required String description,
    required String plantName,
    required String symptomId,
    required String diseaseName,
  }) {
    final buffer = StringBuffer();
    if (plantName.trim().isNotEmpty) {
      buffer.write('On ${plantName.trim()}: ');
    }
    if (description.isNotEmpty) {
      buffer.write(description);
    } else if (diseaseName.isNotEmpty) {
      buffer.write('Photos most closely match $diseaseName.');
    } else {
      buffer.write('A possible health issue showed up in the photos.');
    }
    if (symptomId.trim().isNotEmpty) {
      buffer.write(' You marked ${_humanSymptom(symptomId).toLowerCase()}.');
    }
    return buffer.toString();
  }

  static List<String> _symptoms(String description, String symptomId) {
    final items = <String>[];
    if (symptomId.trim().isNotEmpty) {
      items.add('You selected: ${_humanSymptom(symptomId)}');
    }
    final sentence = _firstSentence(description);
    if (sentence.isNotEmpty && sentence.length < 180) {
      items.add(sentence);
    }
    return items;
  }

  static String _humanSymptom(String id) {
    return switch (id) {
      'yellow_leaves' => 'Yellow leaves',
      'brown_spots' => 'Brown spots',
      'drooping' => 'Drooping',
      'holes' => 'Holes / bites',
      'white_coating' => 'White coating',
      'pests' => 'Pests',
      _ => 'A health concern',
    };
  }

  static List<String> _imageUrls(Map<String, dynamic> details, dynamic similar) {
    final urls = <String>[];
    void add(String value) {
      final url = value.trim();
      if (url.startsWith('http') && !urls.contains(url) && urls.length < 6) {
        urls.add(url);
      }
    }

    final image = details['image'];
    if (image is String) add(image);
    if (image is Map) {
      final map = Map<String, dynamic>.from(image);
      add(_string(map['value']));
      add(_string(map['url']));
    }
    if (similar is List) {
      for (final item in similar) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        add(_string(map['url']));
        add(_string(map['url_small']));
      }
    }
    return urls;
  }

  static String _imageUrl(Map<String, dynamic> details, dynamic similar) {
    final image = details['image'];
    if (image is String && image.startsWith('http')) return image;
    if (image is Map) {
      final map = Map<String, dynamic>.from(image);
      final value = _string(map['value']).isNotEmpty
          ? _string(map['value'])
          : _string(map['url']);
      if (value.startsWith('http')) return value;
    }
    if (similar is List && similar.isNotEmpty && similar.first is Map) {
      final first = Map<String, dynamic>.from(similar.first as Map);
      final url = _string(first['url_small']).isNotEmpty
          ? _string(first['url_small'])
          : _string(first['url']);
      if (url.startsWith('http')) return url;
    }
    return '';
  }

  static Map<String, dynamic> _map(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  static String _string(dynamic raw) => raw is String ? raw.trim() : '';

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  static String _firstString(dynamic raw) {
    final list = _stringList(raw);
    return list.isEmpty ? '' : list.first;
  }

  static String _firstNonEmpty(List<String> values) {
    return values.firstWhere((e) => e.trim().isNotEmpty, orElse: () => '');
  }

  static double _probability(Map<String, dynamic> item) {
    return (_num(item['probability']) ?? 0).clamp(0, 1);
  }

  static double? _num(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return null;
  }

  static List<String> _adviceList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<String>()
          .expand(_splitAdvice)
          .where((e) => e.isNotEmpty)
          .take(6)
          .toList();
    }
    if (raw is String) {
      return _splitAdvice(raw).where((e) => e.isNotEmpty).take(6).toList();
    }
    return const [];
  }

  static Iterable<String> _splitAdvice(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const [];
    final byLine = trimmed
        .split(RegExp(r'[\n•]+|(?:\d+\.\s+)'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (byLine.length > 1) return byLine;
    return [_firstSentence(trimmed)];
  }

  static String _firstSentence(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';
    final match = RegExp(r'(.+?[.!?])(\s|$)').firstMatch(trimmed);
    if (match == null) {
      return trimmed.length > 160 ? '${trimmed.substring(0, 157).trim()}…' : trimmed;
    }
    return match.group(1)!.trim();
  }
}
