import 'package:shared_preferences/shared_preferences.dart';

import '../../app/routes/route_names.dart';

class AppSession {
  AppSession._();

  static const _onboardingKey = 'onboarding_seen';
  static const _loggedInKey = 'session_logged_in';

  static Future<String> nextRoute() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_loggedInKey) ?? false) {
      return RouteNames.home;
    }
    if (prefs.getBool(_onboardingKey) ?? false) {
      return RouteNames.authentication;
    }
    return RouteNames.onboarding;
  }

  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<void> markLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
  }
}
