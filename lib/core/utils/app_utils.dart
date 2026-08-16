class AppUtils {
  AppUtils._();

  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }
}
