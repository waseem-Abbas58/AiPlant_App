import 'package:dio/dio.dart';

import '../../../core/config/plant_api_config.dart';
import '../../../core/helpers/plant_image_upload.dart';
import '../../../core/services/app_logger.dart';
import 'kindwise/kindwise_mappers.dart';
import 'kindwise/kindwise_plant_id_api.dart';
import 'plant_identify_repository.dart';
import '../model/plant_disease_hint_x.dart';
import '../model/plant_identify_result.dart';

/// Live identify + diagnose.
///
/// Uses Kindwise Plant.id when [PlantApiConfig.plantIdApiKey] is set.
/// Uses `POST /ai/identify` and `POST /ai/diagnose` when [PlantApiConfig.apiBaseUrl]
/// is set (own backend later — preferred, keeps the key off the device).
class ApiPlantIdentifyRepository implements PlantIdentifyRepository {
  ApiPlantIdentifyRepository({
    required this.config,
    KindwisePlantIdApi? kindwise,
    Dio? dio,
  })  : _kindwise = kindwise ??
            (config.hasPlantIdKey
                ? KindwisePlantIdApi(apiKey: config.plantIdApiKey)
                : null),
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 45),
                receiveTimeout: const Duration(seconds: 45),
              ),
            );

  final PlantApiConfig config;
  final KindwisePlantIdApi? _kindwise;
  final Dio _dio;

  @override
  Future<PlantIdentifyResult> identifyFromImages(
    List<String> imagePaths, {
    String categoryId = 'plant',
  }) async {
    final primary = imagePaths.isEmpty ? '' : imagePaths.first;
    final files = await _prepareAll(imagePaths);
    if (files.isEmpty) {
      return PlantIdentifyResult.failed(primary, IdentifyFailReason.lowQuality);
    }

    try {
      if (config.hasBackend) {
        final json = await _postBackend(
          '/ai/identify',
          files: files,
          fields: {'categoryId': categoryId},
        );
        return PlantIdentifyResult.fromJson(json).copyWith(
          imagePath: files.first.path,
          isLocalPreview: false,
        );
      }

      final api = _kindwise;
      if (api == null) {
        return PlantIdentifyResult.aiUnavailable(files.first.path);
      }
      AppLogger.info('Kindwise identify: ${files.length} image(s)');
      final json = await api.identify(images: files, categoryId: categoryId);
      final mapped = KindwiseMappers.identify(
        json,
        imagePath: files.first.path,
        categoryId: categoryId,
      );
      AppLogger.info(
        mapped.isIdentified
            ? 'Kindwise identify OK: ${mapped.commonName} (${mapped.confidencePercent}%)'
            : 'Kindwise identify fail: ${mapped.failReason.name}',
      );
      return mapped;
    } on DioException catch (error) {
      AppLogger.warning(
        'Identify HTTP ${error.type.name} '
        '${error.requestOptions.uri} '
        '${error.response?.statusCode ?? error.message ?? ''}',
      );
      return _identifyFail(files.first.path, error);
    }
  }

  @override
  Future<PlantDiseaseHint> diagnoseFromImages(
    List<String> imagePaths, {
    String plantName = '',
    String symptomId = '',
  }) async {
    final files = await _prepareAll(imagePaths);
    if (files.isEmpty) {
      return const PlantDiseaseHint(
        healthy: false,
        title: 'Photo needs a clearer leaf',
        summary: 'Use a JPEG or PNG under 8 MB, with one leaf in clear light.',
        failReason: DiagnoseFailReason.noMatch,
      );
    }

    try {
      if (config.hasBackend) {
        final json = await _postBackend(
          '/ai/diagnose',
          files: files,
          fields: {
            if (plantName.trim().isNotEmpty) 'plantName': plantName.trim(),
            if (symptomId.trim().isNotEmpty) 'symptomId': symptomId.trim(),
          },
        );
        return PlantDiseaseHint.fromJson(json).copyWith(
          alternatives: PlantDiseaseHintX.alternativesOf(json),
        );
      }

      final api = _kindwise;
      if (api == null) return PlantDiseaseHint.unavailable;
      AppLogger.info('Kindwise diagnose: ${files.length} image(s)');
      final json = await api.diagnose(images: files);
      final mapped = KindwiseMappers.diagnose(
        json,
        plantName: plantName,
        symptomId: symptomId,
      );
      AppLogger.info(
        mapped.failReason == DiagnoseFailReason.none
            ? 'Kindwise diagnose OK: ${mapped.diseaseName.isEmpty ? mapped.title : mapped.diseaseName}'
            : 'Kindwise diagnose fail: ${mapped.failReason.name}',
      );
      return mapped;
    } on DioException catch (error) {
      AppLogger.warning(
        'Kindwise diagnose HTTP ${error.response?.statusCode ?? error.type.name}',
      );
      return _diagnoseFail(error);
    }
  }

  Future<List<PlantImageUploadReady>> _prepareAll(List<String> paths) async {
    final files = <PlantImageUploadReady>[];
    for (final path in paths) {
      final ready = await PlantImageUpload.prepare(path);
      if (ready != null) files.add(ready);
    }
    return files;
  }

  Future<Map<String, dynamic>> _postBackend(
    String path, {
    required List<PlantImageUploadReady> files,
    Map<String, String> fields = const {},
  }) async {
    final form = FormData();
    for (final file in files) {
      form.files.add(
        MapEntry(
          PlantImageUpload.multipartField,
          MultipartFile.fromBytes(
            file.bytes,
            filename: file.filename,
            contentType: DioMediaType.parse(file.contentType),
          ),
        ),
      );
    }
    for (final entry in fields.entries) {
      form.fields.add(MapEntry(entry.key, entry.value));
    }

    final headers = <String, dynamic>{};
    if (config.hasPlantIdKey && !config.hasBackend) {
      headers['Api-Key'] = config.plantIdApiKey;
    }

    final url = '${config.normalizedBaseUrl}$path';
    AppLogger.info('Backend POST $url (${files.length} image(s))');
    final response = await _dio.post<Map<String, dynamic>>(
      url,
      data: form,
      options: Options(headers: headers),
    );
    final data = response.data;
    if (data != null) return data;
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Empty API response', 
    );
  }

  PlantIdentifyResult _identifyFail(String imagePath, DioException error) {
    if (_isOffline(error)) return PlantIdentifyResult.offline(imagePath);
    if (_isTimeout(error)) return PlantIdentifyResult.timeout(imagePath);
    if (error.response?.statusCode == 401) {
      return PlantIdentifyResult.aiUnavailable(imagePath); 
    }
    return PlantIdentifyResult.serverError(imagePath);
  }
  PlantDiseaseHint _diagnoseFail(DioException error) {
    if (_isOffline(error)) return PlantDiseaseHint.offline;
    if (_isTimeout(error)) return PlantDiseaseHint.timeout;  
    return PlantDiseaseHint.serverError; 
  }

  bool _isOffline(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout;
  }

  bool _isTimeout(DioException error) {
    return error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }
}
