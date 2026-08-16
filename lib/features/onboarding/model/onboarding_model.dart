import '../../../core/constants/app_images.dart';

class OnboardingModel {
  const OnboardingModel({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  final String title;
  final String subtitle;
  final String imagePath;

  static const OnboardingModel identifyPlant = OnboardingModel(
    title: 'Identify Any Plant',
    subtitle:
        'Snap a photo and discover plants, flowers, trees, and weeds in seconds.',
    imagePath: AppImages.onboardingIdentifyPlant,
  );

  static const OnboardingModel diseaseDetection = OnboardingModel(
    title: 'Keep Your Plants Healthy',
    subtitle:
        'Detect plant diseases and discover possible causes, treatments, and prevention.',
    imagePath: AppImages.onboardingDiseaseDetection,
  );

  static const OnboardingModel plantCareReminders = OnboardingModel(
    title: 'Never Forget Plant Care',
    subtitle:
        'Get personalized watering guidance and reminders for watering, fertilizing, and repotting.',
    imagePath: AppImages.onboardingPlantCareReminders,
  );

  static const OnboardingModel myGarden = OnboardingModel(
    title: 'Create Your My Garden',
    subtitle:
        'Save your plants, track their care, and keep your personal collection organized.',
    imagePath: AppImages.onboardingMyGarden,
  );
}
