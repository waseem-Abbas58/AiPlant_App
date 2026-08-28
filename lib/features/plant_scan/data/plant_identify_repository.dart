import '../../my_garden/data/plant_care_engine.dart';
import '../../my_garden/model/my_garden_model.dart';
import '../model/plant_identify_result.dart';

/// Swap [LocalPlantIdentifyRepository] for an API implementation later.
/// Keep this interface so garden and scan stay unchanged.
abstract class PlantIdentifyRepository {
  Future<PlantIdentifyResult> identifyFromImage(
    String imagePath, {
    String categoryId = 'plant',
  });

  Future<PlantDiseaseHint> diagnoseFromImage(String imagePath);
}

class LocalPlantIdentifyRepository implements PlantIdentifyRepository {
  static const unnamedPlant = 'Unnamed plant';

  static const _monstera =
      'assets/images/home/trending/trending_monstera.png';
  static const _snakePlant =
      'assets/images/home/trending/trending_snake_plant.png';
  static const _peaceLily =
      'assets/images/home/trending/trending_peace_lily.png';
  static const _rubber = 'assets/images/home/trending/trending_rubber_plant.png';
  static const _fiddle = 'assets/images/home/trending/trending_fiddle_leaf.png';
  static const _corn = 'assets/images/home/trending/trending_corn_plant.png';
  static const _aloe = 'assets/images/home/trending/trending_aloe.png';
  static const _jade = 'assets/images/home/trending/trending_jade.png';
  static const _orchid = 'assets/images/home/trending/trending_orchid.png';

  @override
  Future<PlantIdentifyResult> identifyFromImage(
    String imagePath, {
    String categoryId = 'plant',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    return _previewFor(categoryId, imagePath);
  }

  PlantIdentifyResult previewForName(String name, String imagePath) {
    final n = name.toLowerCase();
    final categoryId = n.contains('fiddle') || n.contains('olive')
        ? 'tree'
        : n.contains('agaric') || n.contains('mushroom')
            ? 'mushroom'
            : n.contains('oxalis') || n.contains('weed') || n.contains('clover')
                ? 'weed'
                : n.contains('lily') && n.contains('peace')
                    ? 'disease'
                    : 'plant';
    return _previewFor(categoryId, imagePath).copyWith(
      commonName: name,
      imagePath: imagePath,
    );
  }

  PlantIdentifyResult _previewFor(String categoryId, String imagePath) {
    return switch (categoryId) {
      'tree' => _wateredPreview(
          commonName: 'Fiddle Leaf Fig',
          extras: const [
            'Bright, indirect light',
            'Wipe dusty leaves',
          ],
          result: (care, highlights) => PlantIdentifyResult(
            imagePath: imagePath,
            commonName: 'Fiddle Leaf Fig',
            scientificName: 'Ficus lyrata',
            confidence: 0,
            careHighlights: highlights,
            care: care,
            sampleImageAsset: _fiddle,
            similarMatches: const [
              PlantIdentifyMatch(
                commonName: 'Rubber Plant',
                scientificName: 'Ficus elastica',
                imageAsset: _rubber,
              ),
              PlantIdentifyMatch(
                commonName: 'Corn Plant',
                scientificName: 'Dracaena fragrans',
                imageAsset: _corn,
              ),
              PlantIdentifyMatch(
                commonName: 'Olive',
                scientificName: 'Olea europaea',
                imageAsset: _fiddle,
              ),
            ],
            kind: IdentifiedKind.tree,
            isLocalPreview: true,
          ),
        ),
      'mushroom' => PlantIdentifyResult(
          imagePath: imagePath,
          commonName: 'Fly Agaric',
          scientificName: 'Amanita muscaria',
          confidence: 0,
          careHighlights: const [
            'Do not eat a preview ID',
            'Note the cap, gills, and stem',
            'Keep away from pets and kids',
          ],
          similarMatches: const [
            PlantIdentifyMatch(
              commonName: 'Destroying Angel',
              scientificName: 'Amanita virosa',
            ),
            PlantIdentifyMatch(
              commonName: 'Panther Cap',
              scientificName: 'Amanita pantherina',
            ),
          ],
          kind: IdentifiedKind.mushroom,
          toxicity: const PlantToxicity(
            toxicToPets: true,
            toxicToKids: true,
            summary: 'Poisonous if eaten. Preview only — never forage from this.',
            petsDetail: 'Keep dogs and cats away. Call a vet if anything is eaten.',
            kidsDetail: 'Not a toy or snack. Wash hands after touching.',
          ),
          isLocalPreview: true,
        ),
      'weed' => PlantIdentifyResult(
          imagePath: imagePath,
          commonName: 'Oxalis',
          scientificName: 'Oxalis corniculata',
          confidence: 0,
          careHighlights: const [
            'Pull before it sets seed',
            'Check the whole patch',
            'Do not compost the roots',
          ],
          similarMatches: const [
            PlantIdentifyMatch(
              commonName: 'Clover',
              scientificName: 'Trifolium repens',
              imageAsset: _jade,
            ),
            PlantIdentifyMatch(
              commonName: 'Wood sorrel',
              scientificName: 'Oxalis stricta',
              imageAsset: _jade,
            ),
          ],
          kind: IdentifiedKind.weed,
          isLocalPreview: true,
        ),
      'disease' => _wateredPreview(
          commonName: 'Peace Lily',
          extras: const [
            'Photograph a damaged leaf',
            'Keep leaves dry when watering',
          ],
          result: (care, highlights) => PlantIdentifyResult(
            imagePath: imagePath,
            commonName: 'Peace Lily',
            scientificName: 'Spathiphyllum wallisii',
            confidence: 0,
            careHighlights: highlights,
            care: care,
            sampleImageAsset: _peaceLily,
            similarMatches: const [
              PlantIdentifyMatch(
                commonName: 'Peace Lily',
                scientificName: 'Spathiphyllum wallisii',
                imageAsset: _peaceLily,
              ),
              PlantIdentifyMatch(
                commonName: 'Orchid',
                scientificName: 'Phalaenopsis',
                imageAsset: _orchid,
              ),
            ],
            kind: IdentifiedKind.disease,
            diseaseHint: const PlantDiseaseHint(
              healthy: true,
              title: 'Preview only — no diagnosis yet',
              summary:
                  'Live diagnosis connects when AI is ready. Photograph a damaged leaf for a closer check.',
              steps: [
                'Snap a close-up of the damaged leaf',
                'Keep soil from staying soggy',
                'Watch new growth for spots',
              ],
              isLocalPreview: true,
            ),
            isLocalPreview: true,
          ),
        ),
      _ => _wateredPreview(
          commonName: 'Snake Plant',
          extras: const [
            'Bright to low light',
            'Let extra water drain',
          ],
          result: (care, highlights) => PlantIdentifyResult(
            imagePath: imagePath,
            commonName: 'Snake Plant',
            scientificName: 'Dracaena trifasciata',
            confidence: 0,
            careHighlights: highlights,
            care: care,
            sampleImageAsset: _snakePlant,
            similarMatches: const [
              PlantIdentifyMatch(
                commonName: 'Monstera',
                scientificName: 'Monstera deliciosa',
                imageAsset: _monstera,
              ),
              PlantIdentifyMatch(
                commonName: 'Peace Lily',
                scientificName: 'Spathiphyllum wallisii',
                imageAsset: _peaceLily,
              ),
              PlantIdentifyMatch(
                commonName: 'Aloe Vera',
                scientificName: 'Aloe vera',
                imageAsset: _aloe,
              ),
            ],
            kind: IdentifiedKind.plant,
            toxicity: const PlantToxicity(
              toxicToPets: true,
              toxicToKids: true,
              summary:
                  'Mildly toxic if chewed — keep away from pets and small children.',
              petsDetail:
                  'Can irritate cats and dogs if leaves are chewed. Call a vet if they eat any.',
              kidsDetail:
                  'Sap can irritate skin and mouths. Wash hands after pruning.',
            ),
            diseaseHint: const PlantDiseaseHint(
              healthy: true,
              title: 'Preview health check',
              summary:
                  'Preview only. Photograph a damaged leaf for a closer check.',
              steps: [
                'Wipe dusty leaves so pores can breathe',
                'Keep soil from staying soggy',
                'Watch new growth for spots',
              ],
              isLocalPreview: true,
            ),
            isLocalPreview: true,
          ),
        ),
    };
  }

  PlantIdentifyResult _wateredPreview({
    required String commonName,
    required List<String> extras,
    required PlantIdentifyResult Function(
      GardenCareSchedule care,
      List<String> highlights,
    ) result,
  }) {
    final care = PlantCareEngine.sampleCareFor(commonName);
    return result(care, [PlantCareEngine.waterHighlight(care), ...extras]);
  }

  @override
  Future<PlantDiseaseHint> diagnoseFromImage(String imagePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    return const PlantDiseaseHint(
      healthy: true,
      title: 'Preview only — no diagnosis yet',
      summary:
          'Live diagnosis connects when AI is ready. Photograph a damaged leaf for a closer check.',
      steps: [
        'Snap a close-up of the damaged leaf',
        'Keep soil from staying soggy',
        'Watch new growth for spots',
      ],
      isLocalPreview: true,
    );
  }
}
