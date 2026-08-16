class AppIcons {
  AppIcons._();

  static const String root = 'assets/icons';
  static const String svgRoot = 'assets/svg';

  static const String common = '$root/common';
  static const String navigation = '$root/navigation';
  static const String actions = '$root/actions';
  static const String status = '$root/status';
  static const String social = '$root/social';

  static const String google = '$social/google.svg';
  static const String apple = '$social/apple.svg';
  static const String facebook = '$social/facebook.svg';

  static String path(String category, String name, {String extension = 'svg'}) {
    return '$category/$name.$extension';
  }
}
