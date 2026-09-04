import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/my_app.dart';
import 'core/config/plant_api_config.dart';
import 'core/services/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,   
    DeviceOrientation.portraitDown,   
  ]);
  final api = PlantApiConfig.fromEnvironment();     
  AppLogger.info(
    api.hasBackend
        ? 'Scan AI: backend ${api.normalizedBaseUrl}' 
        : api.hasPlantIdKey
            ? 'Scan AI: Kindwise Plant.id live'    
            : 'Scan AI: local/demo — start backend, then run a debug build',
  );
  runApp(const MyApp());
}
