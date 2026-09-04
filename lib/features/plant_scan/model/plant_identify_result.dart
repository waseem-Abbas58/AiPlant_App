import '../../my_garden/model/my_garden_model.dart';

/// Locked wire models for Identify + Diagnose APIs.
///
/// Identify (`POST /ai/identify`) → [PlantIdentifyResult]
/// Diagnose (`POST /ai/diagnose`) → [PlantDiseaseHint]
/// Do not merge species ID and leaf disease into one response.
///
/// Confidence is 0.0–1.0. Backend must send `isLocalPreview: false`.

enum IdentifiedKind { plant, tree, mushroom, weed, disease, unknown }

enum IdentifyConfidenceTier { high, medium, low }

extension IdentifyConfidenceTierX on IdentifyConfidenceTier {
  String get label => switch (this) {
        IdentifyConfidenceTier.high => 'High confidence',
        IdentifyConfidenceTier.medium => 'Possible match',
        IdentifyConfidenceTier.low => 'Low confidence',
      };
}

enum IdentifyFailReason {
  none,
  notPlant,
  noMatch,
  lowQuality,
  tooBlurry,
  tooDark,
  subjectTooSmall,
  duplicateAngle,
  multiplePlants,
  aiUnavailable,
  offline,
  timeout,
  serverError,
}

extension IdentifyFailReasonX on IdentifyFailReason {
  bool get isRetryable =>
      this == IdentifyFailReason.offline ||
      this == IdentifyFailReason.timeout ||
      this == IdentifyFailReason.serverError;

  bool get isPhotoIssue =>
      this == IdentifyFailReason.lowQuality ||
      this == IdentifyFailReason.tooBlurry ||
      this == IdentifyFailReason.tooDark ||
      this == IdentifyFailReason.subjectTooSmall ||
      this == IdentifyFailReason.duplicateAngle ||
      this == IdentifyFailReason.multiplePlants ||
      this == IdentifyFailReason.notPlant;

  String get apiValue => name;

  static IdentifyFailReason fromApi(String? value) {
    return IdentifyFailReason.values.firstWhere(
      (e) => e.name == value,
      orElse: () => IdentifyFailReason.serverError,
    );
  }
}

enum DiagnoseFailReason {
  none,
  unavailable,
  offline,
  timeout,
  serverError,
  noMatch,
}

extension DiagnoseFailReasonX on DiagnoseFailReason {
  bool get isRetryable =>
      this == DiagnoseFailReason.offline ||
      this == DiagnoseFailReason.timeout ||
      this == DiagnoseFailReason.serverError;

  String get apiValue => name;

  static DiagnoseFailReason fromApi(String? value) {
    return DiagnoseFailReason.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DiagnoseFailReason.serverError,
    );
  }
}

class PlantIdentifyMatch {
  const PlantIdentifyMatch({
    required this.commonName,
    this.scientificName = '',
    this.confidence = 0,
    this.imageAsset,
    this.imageUrl,
  });

  final String commonName;
  final String scientificName;
  final double confidence;
  final String? imageAsset;
  final String? imageUrl;

  Map<String, dynamic> toJson() => {
        'commonName': commonName,
        'scientificName': scientificName,
        'confidence': confidence,
        'imageAsset': imageAsset,
        'imageUrl': imageUrl,
      };

  factory PlantIdentifyMatch.fromJson(Map<String, dynamic> json) {
    return PlantIdentifyMatch(
      commonName: json['commonName'] as String? ?? '',
      scientificName: json['scientificName'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      imageAsset: json['imageAsset'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
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

  Map<String, dynamic> toJson() => {
        'toxicToPets': toxicToPets,
        'toxicToKids': toxicToKids,
        'summary': summary,
        'petsDetail': petsDetail,
        'kidsDetail': kidsDetail,
      };

  factory PlantToxicity.fromJson(Map<String, dynamic> json) {
    return PlantToxicity(
      toxicToPets: json['toxicToPets'] as bool? ?? false,
      toxicToKids: json['toxicToKids'] as bool? ?? false,
      summary: json['summary'] as String? ?? '',
      petsDetail: json['petsDetail'] as String? ?? '',
      kidsDetail: json['kidsDetail'] as String? ?? '',
    );
  }
}

/// Leaf / disease check only — not species identify.
///
/// Locked diagnose API shape (map third-party → these fields):
/// - healthy, title, summary, diseaseName, confidence
/// - steps (fix / treatment order)
/// - symptoms, severity, kind, prevention, caution
/// - optional hosts, spreadsWhen, imageUrl
class PlantDiseaseHint {
  const PlantDiseaseHint({
    required this.title,
    required this.summary,
    this.healthy = true,
    this.steps = const [],
    this.symptoms = const [],
    this.severity = '',
    this.kind = '',
    this.prevention = '',
    this.caution = '',
    this.hosts = '',
    this.spreadsWhen = '',
    this.imageAsset,
    this.imageUrl,
    this.confidence = 0,
    this.diseaseName = '',
    this.isLocalPreview = false,
    this.failReason = DiagnoseFailReason.none,
    this.alternatives = const [],
  });

  final bool healthy;
  final String title;
  final String summary;

  /// Ordered fix / treatment steps (“What to do”).
  final List<String> steps;

  /// Visible signs on the leaf / plant.
  final List<String> symptoms;

  /// e.g. Mild / Moderate / Severe / Fast in damp rooms.
  final String severity;

  /// e.g. Fungus, Pest, Water mold, Nutrient.
  final String kind;

  final String prevention;
  final String caution;
  final String hosts;
  final String spreadsWhen;
  final String? imageAsset;
  final String? imageUrl;
  final double confidence;
  final String diseaseName;
  final bool isLocalPreview;
  final DiagnoseFailReason failReason;
  final List<PlantDiseaseHint> alternatives;

  bool get isSuccess =>
      failReason == DiagnoseFailReason.none && !isLocalPreview;

  bool get isRetryable => failReason.isRetryable;

  bool get hasSymptoms => symptoms.isNotEmpty;

  bool get hasSteps => steps.isNotEmpty;

  bool get hasPrevention => prevention.trim().isNotEmpty;

  bool get hasCaution => caution.trim().isNotEmpty;

  int get confidencePercent => (confidence.clamp(0, 1) * 100).round();

  static const unavailable = PlantDiseaseHint(
    healthy: false,
    title: 'Diagnosis not available yet',
    summary:
        'Live leaf diagnosis connects next. We will not show a fake disease name or healthy badge until AI is ready.',
    steps: [
      'Photograph one damaged leaf in clear light',
      'Fill the frame with the leaf',
      'Try again when live diagnosis is connected',
    ],
    isLocalPreview: true,
    failReason: DiagnoseFailReason.unavailable,
  );

  static const offline = PlantDiseaseHint(
    healthy: false,
    title: 'No internet',
    summary: 'Connect to the internet and try diagnosis again.',
    isLocalPreview: true,
    failReason: DiagnoseFailReason.offline,
  );

  static const timeout = PlantDiseaseHint(
    healthy: false,
    title: 'Taking too long',
    summary: 'Diagnosis timed out. Check your connection and try again.',
    isLocalPreview: true,
    failReason: DiagnoseFailReason.timeout,
  );

  static const serverError = PlantDiseaseHint(
    healthy: false,
    title: 'Something went wrong',
    summary: 'We could not finish diagnosis. Please try again.',
    isLocalPreview: true,
    failReason: DiagnoseFailReason.serverError,
  );

  Map<String, dynamic> toJson() => {
        'healthy': healthy,
        'title': title,
        'summary': summary,
        'steps': steps,
        'symptoms': symptoms,
        'severity': severity,
        'kind': kind,
        'prevention': prevention,
        'caution': caution,
        'hosts': hosts,
        'spreadsWhen': spreadsWhen,
        'imageAsset': imageAsset,
        'imageUrl': imageUrl,
        'confidence': confidence,
        'diseaseName': diseaseName,
        'isLocalPreview': isLocalPreview,
        'failReason': failReason.apiValue,
        'alternatives': [
          for (final item in alternatives)
            {
              'healthy': item.healthy,
              'title': item.title,
              'summary': item.summary,
              'steps': item.steps,
              'symptoms': item.symptoms,
              'severity': item.severity,
              'kind': item.kind,
              'prevention': item.prevention,
              'caution': item.caution,
              'hosts': item.hosts,
              'spreadsWhen': item.spreadsWhen,
              'imageAsset': item.imageAsset,
              'imageUrl': item.imageUrl,
              'confidence': item.confidence,
              'diseaseName': item.diseaseName,
              'isLocalPreview': item.isLocalPreview,
              'failReason': item.failReason.apiValue,
            },
        ],
      };

  factory PlantDiseaseHint.fromJson(Map<String, dynamic> json) {
    List<String> stringList(dynamic raw) {
      if (raw is! List) return const [];
      return raw.whereType<String>().toList();
    }

    return PlantDiseaseHint(
      healthy: json['healthy'] as bool? ?? true,
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      steps: stringList(json['steps']),
      symptoms: stringList(json['symptoms']),
      severity: json['severity'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      prevention: json['prevention'] as String? ?? '',
      caution: json['caution'] as String? ?? '',
      hosts: json['hosts'] as String? ?? '',
      spreadsWhen: json['spreadsWhen'] as String? ?? '',
      imageAsset: json['imageAsset'] as String?,
      imageUrl: json['imageUrl'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      diseaseName: json['diseaseName'] as String? ?? '',
      isLocalPreview: json['isLocalPreview'] as bool? ?? false,
      failReason: DiagnoseFailReasonX.fromApi(json['failReason'] as String?),
    );
  }
}

/// Species identify result — not leaf disease (use [PlantDiseaseHint]).
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
    this.care,
    this.sampleImageAsset,
    this.sampleImageUrl,
    this.referenceImageUrls = const [],
    this.isIdentified = true,
    this.failReason = IdentifyFailReason.none,
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
  final GardenCareSchedule? care;
  final String? sampleImageAsset;
  final String? sampleImageUrl;
  final List<String> referenceImageUrls;
  final bool isIdentified;
  final IdentifyFailReason failReason;
  final bool isLocalPreview;

  bool get isLowConfidence =>
      isIdentified && confidenceTier == IdentifyConfidenceTier.low;

  IdentifyConfidenceTier get confidenceTier {
    if (!isIdentified || confidence <= 0) {
      return IdentifyConfidenceTier.low;
    }
    if (confidence >= 0.75) return IdentifyConfidenceTier.high;
    if (confidence >= 0.55) return IdentifyConfidenceTier.medium;
    return IdentifyConfidenceTier.low;
  }

  /// Hide final species name when confidence is too low (live results only).
  bool get shouldHideSpeciesName =>
      isIdentified && confidenceTier == IdentifyConfidenceTier.low && !isLocalPreview;

  /// Alternatives below this look like noise (e.g. ragweed 1%).
  static const meaningfulSimilarMinConfidence = 0.20;

  /// Live Plant.id reference photos for this species. Never invent URLs.
  List<String> get referencePhotos {
    final urls = <String>[];
    void add(String? value) {
      final url = (value ?? '').trim();
      if (url.startsWith('http') && !urls.contains(url) && urls.length < 6) {
        urls.add(url);
      }
    }

    for (final url in referenceImageUrls) {
      add(url);
    }
    add(sampleImageUrl);
    return urls;
  }

  /// Live API alternatives that are actually useful. Never invent species.
  List<PlantIdentifyMatch> get meaningfulSimilarMatches => similarMatches
      .where(
        (match) =>
            match.commonName.trim().isNotEmpty &&
            match.confidence >= meaningfulSimilarMinConfidence,
      )
      .toList();

  factory PlantIdentifyResult.notAPlant(String imagePath) {
    return PlantIdentifyResult(
      imagePath: imagePath,
      commonName: '',
      isIdentified: false,
      failReason: IdentifyFailReason.notPlant,
    );
  }

  factory PlantIdentifyResult.aiUnavailable(String imagePath) {
    return PlantIdentifyResult(
      imagePath: imagePath,
      commonName: '',
      isIdentified: false,
      failReason: IdentifyFailReason.aiUnavailable,
    );
  }

  factory PlantIdentifyResult.offline(String imagePath) {
    return PlantIdentifyResult(
      imagePath: imagePath,
      commonName: '',
      isIdentified: false,
      failReason: IdentifyFailReason.offline,
    );
  }

  factory PlantIdentifyResult.timeout(String imagePath) {
    return PlantIdentifyResult(
      imagePath: imagePath,
      commonName: '',
      isIdentified: false,
      failReason: IdentifyFailReason.timeout,
    );
  }

  factory PlantIdentifyResult.serverError(String imagePath) {
    return PlantIdentifyResult(
      imagePath: imagePath,
      commonName: '',
      isIdentified: false,
      failReason: IdentifyFailReason.serverError,
    );
  }

  factory PlantIdentifyResult.noMatch(String imagePath) {
    return PlantIdentifyResult(
      imagePath: imagePath,
      commonName: '',
      isIdentified: false,
      failReason: IdentifyFailReason.noMatch,
    );
  }

  factory PlantIdentifyResult.lowQuality(String imagePath) {
    return PlantIdentifyResult.failed(imagePath, IdentifyFailReason.lowQuality);
  }

  factory PlantIdentifyResult.failed(
    String imagePath,
    IdentifyFailReason reason,
  ) {
    return PlantIdentifyResult(
      imagePath: imagePath,
      commonName: '',
      isIdentified: false,
      failReason: reason,
    );
  }

  factory PlantIdentifyResult.fromHistory({
    required String imagePath,
    required String commonName,
    String scientificName = '',
    String? sampleImageAsset,
  }) {
    return PlantIdentifyResult(
      imagePath: imagePath,
      commonName: commonName,
      scientificName: scientificName,
      sampleImageAsset: sampleImageAsset,
      isIdentified: true,
    );
  }

  String get kindLabel => switch (kind) {
        IdentifiedKind.plant => 'Plant',
        IdentifiedKind.tree => 'Tree',
        IdentifiedKind.mushroom => 'Mushroom',
        IdentifiedKind.weed => 'Weed',
        IdentifiedKind.disease => 'Disease',
        IdentifiedKind.unknown => 'Unknown',
      };

  String get kindHint => switch (kind) {
        IdentifiedKind.weed => 'Confirm before you treat or pull it.',
        IdentifiedKind.tree => 'Check the leaf and bark match your tree.',
        IdentifiedKind.mushroom =>
          'Never eat a mushroom from an app ID alone.',
        IdentifiedKind.disease =>
          'Photograph a damaged leaf for a closer health check.',
        IdentifiedKind.plant =>
          'Confirm the name if this is not your plant.',
        IdentifiedKind.unknown => 'Confirm details before you change care.',
      };

  int get confidencePercent => (confidence.clamp(0, 1) * 100).round();

  bool get wantsWatering => switch (kind) {
        IdentifiedKind.plant ||
        IdentifiedKind.tree ||
        IdentifiedKind.disease =>
          true,
        _ => false,
      };

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'commonName': commonName,
        'scientificName': scientificName,
        'confidence': confidence,
        'careHighlights': careHighlights,
        'similarMatches': similarMatches.map((e) => e.toJson()).toList(),
        'kind': kind.name,
        'toxicity': toxicity?.toJson(),
        'care': care?.toJson(),
        'sampleImageAsset': sampleImageAsset,
        'sampleImageUrl': sampleImageUrl,
        'referenceImageUrls': referenceImageUrls,
        'isIdentified': isIdentified,
        'failReason': failReason.apiValue,
        'isLocalPreview': isLocalPreview,
      };

  factory PlantIdentifyResult.fromJson(Map<String, dynamic> json) {
    final similarRaw = json['similarMatches'];
    final highlightsRaw = json['careHighlights'];
    final kindName = json['kind'] as String?;
    final toxicityRaw = json['toxicity'];
    final careRaw = json['care'];

    return PlantIdentifyResult(
      imagePath: json['imagePath'] as String? ?? '',
      commonName: json['commonName'] as String? ?? '',
      scientificName: json['scientificName'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      careHighlights: highlightsRaw is List
          ? highlightsRaw.whereType<String>().toList()
          : const [],
      similarMatches: similarRaw is List
          ? similarRaw
              .whereType<Map>()
              .map((e) => PlantIdentifyMatch.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : const [],
      kind: IdentifiedKind.values.firstWhere(
        (e) => e.name == kindName,
        orElse: () => IdentifiedKind.unknown,
      ),
      toxicity: toxicityRaw is Map
          ? PlantToxicity.fromJson(Map<String, dynamic>.from(toxicityRaw))
          : null,
      care: careRaw is Map
          ? GardenCareSchedule.fromJson(Map<String, dynamic>.from(careRaw))
          : null,
      sampleImageAsset: json['sampleImageAsset'] as String?,
      sampleImageUrl: json['sampleImageUrl'] as String?,
      referenceImageUrls: json['referenceImageUrls'] is List
          ? (json['referenceImageUrls'] as List)
              .whereType<String>()
              .map((e) => e.trim())
              .where((e) => e.startsWith('http'))
              .toList()
          : const [],
      isIdentified: json['isIdentified'] as bool? ?? true,
      failReason: IdentifyFailReasonX.fromApi(json['failReason'] as String?),
      isLocalPreview: json['isLocalPreview'] as bool? ?? false,
    );
  }

  PlantIdentifyResult copyWith({
    String? imagePath,
    String? commonName,
    String? scientificName,
    double? confidence,
    List<String>? careHighlights,
    List<PlantIdentifyMatch>? similarMatches,
    IdentifiedKind? kind,
    PlantToxicity? toxicity,
    GardenCareSchedule? care,
    String? sampleImageAsset,
    String? sampleImageUrl,
    List<String>? referenceImageUrls,
    bool? isIdentified,
    IdentifyFailReason? failReason,
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
      care: care ?? this.care,
      sampleImageAsset: sampleImageAsset ?? this.sampleImageAsset,
      sampleImageUrl: sampleImageUrl ?? this.sampleImageUrl,
      referenceImageUrls: referenceImageUrls ?? this.referenceImageUrls,
      isIdentified: isIdentified ?? this.isIdentified,
      failReason: failReason ?? this.failReason,
      isLocalPreview: isLocalPreview ?? this.isLocalPreview,
    );
  }
}
