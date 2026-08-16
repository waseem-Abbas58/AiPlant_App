import '../../core/constants/app_durations.dart';
import '../../core/constants/app_strings.dart';

class AppConfig {
  AppConfig._();

  static const String appName = AppStrings.appName;
  static const String appVersion = '1.0.0';

  static const double designWidth = 375;
  static const double designHeight = 812;

  static const Duration defaultAnimationDuration = AppDurations.normal;
  static const Duration splashDuration = Duration(seconds: 5);
}
