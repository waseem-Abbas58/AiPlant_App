import 'plant_identify_result.dart';

extension PlantDiseaseHintX on PlantDiseaseHint {
  PlantDiseaseHint copyWith({List<PlantDiseaseHint>? alternatives}) {
    return PlantDiseaseHint(
      healthy: healthy,
      title: title,
      summary: summary,
      steps: steps,
      symptoms: symptoms,
      severity: severity,
      kind: kind,
      prevention: prevention,
      caution: caution,
      hosts: hosts,
      spreadsWhen: spreadsWhen,
      imageAsset: imageAsset,
      imageUrl: imageUrl,
      confidence: confidence,
      diseaseName: diseaseName,
      isLocalPreview: isLocalPreview,
      failReason: failReason,
      alternatives: alternatives ?? this.alternatives,
    );
  }

  static List<PlantDiseaseHint> alternativesOf(Map<String, dynamic> json) {
    final raw = json['alternatives'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => PlantDiseaseHint.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
