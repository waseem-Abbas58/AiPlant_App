import 'asset_constants.dart';

class AppImages {
  AppImages._();

  static const String _root = AssetConstants.images;

  static const String onboarding = '$_root/onboarding';
  static const String home = '$_root/home';
  static const String garden = '$_root/garden';
  static const String gardenSoil = '$garden/soil';
  static const String plants = '$_root/plants';
  static const String disease = '$_root/disease';
  static const String profile = '$_root/profile';
  static const String emptyStates = '$_root/empty_states';
  static const String illustrations = '$_root/illustrations';

  static const String onboardingIdentifyPlant =
      '$onboarding/identify_plant.png';
  static const String onboardingDiseaseDetection =
      '$onboarding/disease_detection.png';
  static const String onboardingPlantCareReminders =
      '$onboarding/plant_care_reminders.png';
  static const String onboardingMyGarden = '$onboarding/my_garden.png';

  static const String authLogo = '$_root/authlogo.png';

  static const String weeklyQuiz = '$home/quiz/weekly_quiz.png';
  static const String premiumCardBg = '$home/premium/premium_card_bg.png';

  static const String soilChalk = '$gardenSoil/chalk.png';
  static const String soilClay = '$gardenSoil/clay.png';
  static const String soilLoam = '$gardenSoil/loam.png';
  static const String soilSand = '$gardenSoil/sand.png';

  static String path(String category, String name, {String extension = 'png'}) {
    return '$category/$name.$extension';
  }
}
