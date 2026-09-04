import '../../my_garden/model/my_garden_model.dart';
import '../model/plant_identify_result.dart';

/// Swap [LocalPlantIdentifyRepository] for [ApiPlantIdentifyRepository].
///
/// Contract (locked):
/// - [identifyFromImages] → species only → [PlantIdentifyResult]
/// - [diagnoseFromImages] → leaf disease only → [PlantDiseaseHint]
/// Never return disease diagnosis from identify, or species from diagnose.
///
/// Before upload, prepare bytes with [PlantImageUpload.prepareWithReason]
/// (JPEG/PNG, max 8 MB, multipart field `image`).
abstract class PlantIdentifyRepository {
  Future<PlantIdentifyResult> identifyFromImages(
    List<String> imagePaths, {
    String categoryId = 'plant',
  });

  Future<PlantDiseaseHint> diagnoseFromImages(
    List<String> imagePaths, {
    String plantName = '',
    String symptomId = '',
  });
}

/// On-device gate only. No fake species or disease names
/// unless [demoUiSuccess] is on for screen walkthrough.
class LocalPlantIdentifyRepository implements PlantIdentifyRepository {
  static const unnamedPlant = 'Unnamed plant';

  /// Off now that live Kindwise / backend identify is wired.
  static const demoUiSuccess = false;

  @override
  Future<PlantIdentifyResult> identifyFromImages(
    List<String> imagePaths, {
    String categoryId = 'plant',
  }) async {
    if (imagePaths.isEmpty) {
      return PlantIdentifyResult.failed('', IdentifyFailReason.lowQuality);
    }
    final imagePath = imagePaths.first;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!demoUiSuccess) {
      return PlantIdentifyResult.aiUnavailable(imagePath);
    }
    final angleNote = imagePaths.length > 1
        ? ' · ${imagePaths.length} angles'
        : '';
    return PlantIdentifyResult(
      imagePath: imagePath,
      commonName: 'Demo plant$angleNote',
      scientificName: 'UI preview only',
      confidence: 0.82,
      careHighlights: const [
        'When top soil is dry',
        'Bright, indirect',
        'Normal home air',
      ],
      similarMatches: const [
        PlantIdentifyMatch(
          commonName: 'Similar demo A',
          scientificName: 'Preview match',
          confidence: 0.61,
        ),
        PlantIdentifyMatch(
          commonName: 'Similar demo B',
          scientificName: 'Preview match',
          confidence: 0.48,
        ),
      ],
      kind: IdentifiedKind.plant,
      toxicity: const PlantToxicity(
        toxicToPets: false,
        toxicToKids: false,
        summary: 'Demo toxicity — not a real reading.',
      ),
      care: const GardenCareSchedule(
        waterDays: 7,
        lightLevel: 'Bright',
        waterAmount: 'Moderate',
        syncCalendar: true,
      ),
      isIdentified: true,
      isLocalPreview: true,
    );
  }

  @override
  Future<PlantDiseaseHint> diagnoseFromImages(
    List<String> imagePaths, {
    String plantName = '',
    String symptomId = '',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!demoUiSuccess) {
      return PlantDiseaseHint.unavailable;
    }
    return const PlantDiseaseHint(
      healthy: false,
      title: 'Leaf spots — possible fungal issue',
      diseaseName: 'Demo leaf spot',
      summary:
          'UI preview only. Dark or tan patches on the leaf often mean a fungal spot. Live AI will replace this with a real reading.',
      confidence: 0.74,
      kind: 'Fungus',
      severity: 'Moderate',
      symptoms: [
        'Round or irregular brown / tan patches on the leaf',
        'Yellow ring sometimes around the spot',
        'Older leaves show marks first',
      ],
      steps: [
        'Isolate the plant from others so spores do not splash across.',
        'Pick off the worst marked leaves and bag them — do not compost.',
        'Water the soil, not the leaves. Let the top dry between waterings.',
        'Give space and airflow. If new spots keep appearing, use a houseplant fungicide labeled for leaf spot.',
      ],
      prevention:
          'Avoid wet leaves overnight. Space pots. Check new plants before they join the shelf.',
      caution:
          'Keep sprays away from pets and kids. Follow the product label.',
      hosts: 'Many houseplants and outdoor foliage',
      spreadsWhen: 'Warm, still, damp air and crowded pots',
      isLocalPreview: true,
    );
  }
}
