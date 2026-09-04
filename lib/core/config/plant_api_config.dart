import 'package:flutter/foundation.dart';

/// Scan AI config. Secrets stay in backend/.env, not in the Flutter app.
///
/// Physical Android + emulator both use the PC Wi-Fi IP in debug.
/// If your PC IP changes, update [debugLanHost] or pass:
/// `flutter run --dart-define=API_BASE_URL=http://NEW_IP:3000/api/v1`
class PlantApiConfig {
  const PlantApiConfig({
    this.plantIdApiKey = '',
    this.apiBaseUrl = '',
  });

  /// This Windows PC Wi-Fi IPv4 (not the phone). Phone ADB was 192.168.100.12.
  static const debugLanHost = '192.168.100.7';

  factory PlantApiConfig.fromEnvironment() {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    final trimmed = fromEnv.trim();
    return PlantApiConfig(
      plantIdApiKey: const String.fromEnvironment('PLANT_ID_API_KEY'),
      apiBaseUrl: trimmed.isNotEmpty
          ? trimmed
          : (kDebugMode ? debugBackendUrl : ''),
    );
  }

  static String get debugBackendUrl {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://$debugLanHost:3000/api/v1';
    }
    return 'http://127.0.0.1:3000/api/v1';
  }

  final String plantIdApiKey;
  final String apiBaseUrl;

  String get normalizedBaseUrl => apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');

  bool get hasBackend => normalizedBaseUrl.isNotEmpty;

  bool get hasPlantIdKey => plantIdApiKey.trim().isNotEmpty;

  bool get hasRemote => hasBackend || hasPlantIdKey;
}
