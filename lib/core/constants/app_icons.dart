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

  static const String home = '$root/Homeicon.svg';
  static const String garden = '$root/gardenicon.svg';
  static const String scan = '$root/scanicon.svg';
  static const String reminders = '$root/Remindersicon.svg';
  static const String chat = '$root/chaticon.svg';
  static const String profile = '$root/proFileicon.svg';

  static const String tools = '$root/tools';
  static const String plantIdentifier = '$tools/plant_identifier.svg';
  static const String diseaseIdentifier = '$tools/disease_identifier.svg';
  static const String treeIdentifier = '$tools/tree_identifier.svg';
  static const String waterMeter = '$tools/water_meter.svg';
  static const String askBotanist = '$tools/ask_botanist.svg';
  static const String mushroomIdentifier = '$tools/mushroom_identifier.svg';
  static const String weedIdentification = '$tools/weed_identification.svg';
  static const String toxicityIdentifier = '$tools/toxicity_identifier.svg';
  static const String plantFinder = '$tools/plant_finder.svg';
  static const String plantStatistics = '$tools/plant_statistics.svg';

  static String path(String category, String name, {String extension = 'svg'}) {
    return '$category/$name.$extension';
  }
}
