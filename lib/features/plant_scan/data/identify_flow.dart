import 'dart:async';

import 'package:image_picker/image_picker.dart';

import '../../../core/helpers/navigation_helper.dart';
import '../../../core/helpers/plant_image_upload.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/services/connectivity_service.dart';
import '../model/identify_fail_action.dart';
import 'identify_scan_session.dart';
import 'plant_image_preprocess.dart';
import 'plant_photo_quality.dart';
import 'plant_identify_repository.dart';
import 'plant_scene_gate.dart';
import '../model/plant_identify_result.dart';
import '../view/identify_failed_view.dart';
import '../view/identify_processing_view.dart';

/// Shared identify + fail/retry loop for Scan and Garden add flows.
class IdentifyFlow {
  IdentifyFlow._();

  static const identifyTimeout = Duration(seconds: 45);
  static const diagnoseTimeout = Duration(seconds: 45);

  static Future<PlantIdentifyResult?> run({
    required List<String> imagePaths,
    String categoryId = 'plant',
    String? scanId,
  }) async {
    if (imagePaths.isEmpty) return null;

    var paths = List<String>.of(imagePaths);
    final sessionId = scanId ?? IdentifyScanSession.newId();

    while (true) {
      final result = await NavigationHelper.to<PlantIdentifyResult>(
        () => IdentifyProcessingView(
          imagePaths: paths,
          categoryId: categoryId,
          scanId: sessionId,
        ),
      );

      if (result == null) return null;
      if (result.isIdentified) return result;

      final action = await NavigationHelper.to<IdentifyFailAction>(
        () => IdentifyFailedView(
          reason: result.failReason,
          categoryId: categoryId,
          imagePath: result.imagePath,
        ),
      );

      switch (action) {
        case IdentifyFailAction.retrySame:
          continue;
        case IdentifyFailAction.pickGallery:
          final picked = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            imageQuality: 88,
            maxWidth: 1600,
          );
          if (picked == null) return null;
          paths = [picked.path];
          continue;
        case IdentifyFailAction.back:
        case null:
          return null;
      }
    }
  }

  /// Convenience for single-image callers (Garden add flow).
  static Future<PlantIdentifyResult?> runSingle({
    required String imagePath,
    String categoryId = 'plant',
  }) =>
      run(imagePaths: [imagePath], categoryId: categoryId);

  static Future<PlantIdentifyResult> identifySafe({
    required PlantIdentifyRepository repository,
    required List<String> imagePaths,
    String categoryId = 'plant',
    required String scanId,
  }) async {
    if (imagePaths.isEmpty) {
      return PlantIdentifyResult.failed('', IdentifyFailReason.lowQuality);
    }

    final prepared = await PlantImagePreprocess.prepareAll(
      imagePaths,
      scanId: scanId,
    );
    if (prepared.isEmpty) {
      return PlantIdentifyResult.failed(
        imagePaths.first,
        IdentifyFailReason.lowQuality,
      );
    }

    if (prepared.length > 1) {
      final dup = await PlantPhotoQuality.firstDuplicateIn(prepared);
      if (dup != null) {
        return PlantIdentifyResult.failed(prepared.first, dup);
      }
    }

    for (final path in prepared) {
      final quality = await PlantPhotoQuality.check(path);
      if (quality != null) {
        AppLogger.info('Identify blocked locally: ${quality.name}');
        return PlantIdentifyResult.failed(path, quality);
      }
    }

    final primary = prepared.first;

    if (PlantSceneGate.enabled) {
      final plantLike = await PlantSceneGate.looksLikePlant(
        primary,
        categoryId: categoryId,
      );
      if (!plantLike) {
        AppLogger.info('Identify blocked locally: notPlant');
        return PlantIdentifyResult.notAPlant(primary);
      }
    }

    final upload = await PlantImageUpload.prepareWithReason(primary);
    if (!upload.isOk) {
      return PlantIdentifyResult.failed(primary, IdentifyFailReason.lowQuality);
    }

    if (repository is! LocalPlantIdentifyRepository) {
      final online = await ConnectivityService().isOnline;
      if (!online) return PlantIdentifyResult.offline(primary);
    }

    try {
      return await repository
          .identifyFromImages(
            prepared,
            categoryId: categoryId,
          )
          .timeout(identifyTimeout);
    } on TimeoutException {
      AppLogger.warning('Identify timed out');
      return PlantIdentifyResult.timeout(primary);
    } catch (error) {
      AppLogger.warning('Identify failed: $error');
      return PlantIdentifyResult.serverError(primary);
    }
  }

  static Future<PlantDiseaseHint> diagnoseSafe({
    required PlantIdentifyRepository repository,
    required List<String> imagePaths,
    String plantName = '',
    String symptomId = '',
  }) async {
    final valid = <String>[];
    for (final path in imagePaths) {
      final upload = await PlantImageUpload.prepareWithReason(path);
      if (upload.isOk) valid.add(path);
    }
    if (valid.isEmpty) {
      return const PlantDiseaseHint(
        healthy: false,
        title: 'Photo needs a clearer leaf',
        summary:
            'Use a JPEG or PNG under 8 MB, with one leaf in clear light.',
        isLocalPreview: true,
        failReason: DiagnoseFailReason.noMatch,
      );
    }

    if (repository is! LocalPlantIdentifyRepository) {
      final online = await ConnectivityService().isOnline;
      if (!online) return PlantDiseaseHint.offline;
    }

    try {
      return await repository
          .diagnoseFromImages(
            valid,
            plantName: plantName,
            symptomId: symptomId,
          )
          .timeout(diagnoseTimeout);
    } on TimeoutException {
      return PlantDiseaseHint.timeout;
    } catch (_) {
      return PlantDiseaseHint.serverError;
    }
  }
}
