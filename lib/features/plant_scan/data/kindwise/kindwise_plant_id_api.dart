import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/helpers/plant_image_upload.dart';

/// Kindwise Plant.id v3 — identify and health only. No chat, no storage.
class KindwisePlantIdApi {
  KindwisePlantIdApi({
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: defaultBaseUrl,
                connectTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 45),
                receiveTimeout: const Duration(seconds: 45),
                headers: {
                  'Api-Key': apiKey,
                  'Content-Type': 'application/json',
                },
              ),
            );

  static const defaultBaseUrl = 'https://plant.id/api/v3';

  static const identifyDetails =
      'common_names,url,description,taxonomy,image,watering,'
      'best_watering,best_light_condition,best_soil_type,toxicity,'
      'propagation_methods';

  static const diagnoseDetails =
      'local_name,description,treatment,classification,common_names,url';

  final String apiKey;
  final Dio _dio;

  Future<Map<String, dynamic>> identify({
    required List<PlantImageUploadReady> images,
    String categoryId = 'plant',
  }) {
    return _post(
      '/identification',
      images: images,
      details: identifyDetails,
      extra: {
        'similar_images': true,
        if (_filterFor(categoryId) != null)
          'suggestion_filter': _filterFor(categoryId),
      },
    );
  }

  /// Health assessment only — not species identify (`health=only`).
  Future<Map<String, dynamic>> diagnose({
    required List<PlantImageUploadReady> images,
  }) {
    return _post(
      '/identification',
      images: images,
      details: diagnoseDetails,
      extra: {
        'similar_images': true,
        'health': 'only',
      },
    );
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    required List<PlantImageUploadReady> images,
    required String details,
    Map<String, dynamic> extra = const {},
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      queryParameters: {
        'details': details,
        'language': 'en',
      },
      data: {
        'images': [
          for (final image in images) base64Encode(image.bytes),
        ],
        ...extra,
      },
    );
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Empty Plant.id response',
      );
    }
    return data;
  }

  static Map<String, dynamic>? _filterFor(String categoryId) {
    return switch (categoryId) {
      'tree' => const {'classification': 'tree'},
      _ => null,
    };
  }
}
