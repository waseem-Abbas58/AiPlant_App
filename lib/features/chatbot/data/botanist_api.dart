import 'package:dio/dio.dart';

import '../../../core/config/plant_api_config.dart';
import '../../../core/services/app_logger.dart';

class BotanistApi {
  BotanistApi({PlantApiConfig? config, Dio? dio})
      : _config = config ?? PlantApiConfig.fromEnvironment(),
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 45),
              ),
            );

  final PlantApiConfig _config;
  final Dio _dio;

  bool get isReady => _config.hasBackend;

  Future<String?> ask({
    required String message,
    String plantName = '',
    String issue = '',
  }) async {
    if (!_config.hasBackend) return null;
    try {
      final url = '${_config.normalizedBaseUrl}/ai/chat';
      AppLogger.info('Backend POST $url');
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: {
          'message': message,
          if (plantName.trim().isNotEmpty) 'plantName': plantName.trim(),
          if (issue.trim().isNotEmpty) 'issue': issue.trim(),
        },
      );
      final body = response.data;
      final data = body?['data'];
      if (data is Map && data['reply'] is String) {
        final reply = (data['reply'] as String).trim();
        if (reply.isNotEmpty) return reply;
      }
      return null;
    } on DioException catch (error) {
      AppLogger.warning(
        'Ask AI HTTP ${error.response?.statusCode ?? error.type.name}',
      );
      return null;
    }
  }
}
