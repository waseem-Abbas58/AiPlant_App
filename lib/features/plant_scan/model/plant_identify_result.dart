import '../../my_garden/model/my_garden_model.dart';

enum IdentifiedKind { plant, tree, mushroom, weed, disease, unknown }

class PlantIdentifyMatch {
  const PlantIdentifyMatch({
    required this.commonName,
    this.scientificName = '',
    this.confidence = 0,
    this.imageAsset,
  });

  final String commonName;
  final String scientificName;
  final double confidence;
  final String? imageAsset;
}

class PlantToxicity {
  const PlantToxicity({
    required this.toxicToPets,
    required this.toxicToKids,
    required this.summary,
    this.petsDetail = '',
    this.kidsDetail = '',
  });

  final bool toxicToPets;
  final bool toxicToKids;
  final String summary;
  final String petsDetail;
  final String kidsDetail;
}

class PlantDiseaseHint {
  const PlantDiseaseHint({
    required this.title,
    required this.summary,
    this.healthy = true,
    this.steps = const [],
    this.imageAsset,
    this.isLocalPreview = false,
  });

  final bool healthy;
  final String title;
  final String summary;
  final List<String> steps;
  final String? imageAsset;
  final bool isLocalPreview;
}

class PlantIdentifyResult {
  const PlantIdentifyResult({
    required this.imagePath,
    required this.commonName,
    this.scientificName = '',
    this.confidence = 0,
    this.careHighlights = const [],
    this.similarMatches = const [],
    this.kind = IdentifiedKind.unknown,
    this.toxicity,
    this.diseaseHint,
    this.care,
    this.sampleImageAsset,
    this.isIdentified = true,
    this.isLocalPreview = false,
  });

  final String imagePath;
  final String commonName;
  final String scientificName;
  final double confidence;
  final List<String> careHighlights;
  final List<PlantIdentifyMatch> similarMatches;
  final IdentifiedKind kind;
  final PlantToxicity? toxicity;
  final PlantDiseaseHint? diseaseHint;
  final GardenCareSchedule? care;
  final String? sampleImageAsset;
  final bool isIdentified;

  /// True while the app uses the local stub. Backend should return false.
  final bool isLocalPreview;

  String get kindLabel => switch (kind) {
        IdentifiedKind.plant => 'Plant',
        IdentifiedKind.tree => 'Tree',
        IdentifiedKind.mushroom => 'Mushroom',
        IdentifiedKind.weed => 'Weed',
        IdentifiedKind.disease => 'Disease',
        IdentifiedKind.unknown => 'Unknown',
      };

  String get kindHint => switch (kind) {
        IdentifiedKind.weed =>
          'Preview weed match. Confirm before you treat or pull it.',
        IdentifiedKind.tree =>
          'Preview tree match. Live ID will tell species when AI is connected.',
        IdentifiedKind.mushroom =>
          'Preview mushroom match. Never eat a sample ID.',
        IdentifiedKind.disease =>
          'Preview health check. Photograph a damaged leaf for a closer look.',
        IdentifiedKind.plant =>
          'Preview houseplant match. Confirm the name if this is not your plant.',
        IdentifiedKind.unknown =>
          'Preview only. Live identification connects later.',
      };

  int get confidencePercent => (confidence.clamp(0, 1) * 100).round();

  bool get wantsWatering => switch (kind) {
        IdentifiedKind.plant ||
        IdentifiedKind.tree ||
        IdentifiedKind.disease =>
          true,
        _ => false,
      };

  PlantIdentifyResult copyWith({
    String? imagePath,
    String? commonName,
    String? scientificName,
    double? confidence,
    List<String>? careHighlights,
    List<PlantIdentifyMatch>? similarMatches,
    IdentifiedKind? kind,
    PlantToxicity? toxicity,
    PlantDiseaseHint? diseaseHint,
    GardenCareSchedule? care,
    String? sampleImageAsset,
    bool? isIdentified,
    bool? isLocalPreview,
  }) {
    return PlantIdentifyResult(
      imagePath: imagePath ?? this.imagePath,
      commonName: commonName ?? this.commonName,
      scientificName: scientificName ?? this.scientificName,
      confidence: confidence ?? this.confidence,
      careHighlights: careHighlights ?? this.careHighlights,
      similarMatches: similarMatches ?? this.similarMatches,
      kind: kind ?? this.kind,
      toxicity: toxicity ?? this.toxicity,
      diseaseHint: diseaseHint ?? this.diseaseHint,
      care: care ?? this.care,
      sampleImageAsset: sampleImageAsset ?? this.sampleImageAsset,
      isIdentified: isIdentified ?? this.isIdentified,
      isLocalPreview: isLocalPreview ?? this.isLocalPreview,
    );
  }
}
