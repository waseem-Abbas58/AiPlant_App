import 'package:get/get.dart';

import '../../features/articles/bindings/articles_binding.dart';
import '../../features/articles/view/articles_view.dart';
import '../../features/authentication/bindings/authentication_binding.dart';
import '../../features/authentication/bindings/forgot_password_binding.dart';
import '../../features/authentication/bindings/otp_verification_binding.dart';
import '../../features/authentication/bindings/reset_password_binding.dart';
import '../../features/authentication/bindings/signup_binding.dart';
import '../../features/authentication/view/authentication_view.dart';
import '../../features/authentication/view/forgot_password_view.dart';
import '../../features/authentication/view/otp_verification_view.dart';
import '../../features/authentication/view/password_reset_success_view.dart';
import '../../features/authentication/view/reset_password_view.dart';
import '../../features/authentication/view/signup_view.dart';
import '../../features/disease_detection/bindings/disease_detection_binding.dart';
import '../../features/disease_detection/view/disease_detection_view.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/view/home_view.dart';
import '../../features/my_garden/bindings/my_garden_binding.dart';
import '../../features/my_garden/view/my_garden_view.dart';
import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../features/onboarding/view/onboarding_view.dart';
import '../../features/plant_details/bindings/plant_details_binding.dart';
import '../../features/plant_details/view/plant_details_view.dart';
import '../../features/plant_scan/bindings/plant_scan_binding.dart';
import '../../features/plant_scan/view/plant_scan_view.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/view/profile_view.dart';
import '../../features/reminder/bindings/reminder_binding.dart';
import '../../features/reminder/view/reminder_view.dart';
import '../../features/search/bindings/search_binding.dart';
import '../../features/search/view/search_view.dart';
import '../../features/settings/bindings/settings_binding.dart';
import '../../features/settings/view/settings_view.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/view/splash_view.dart';
import '../../features/subscription/bindings/subscription_binding.dart';
import '../../features/subscription/view/subscription_view.dart';
import 'route_names.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: RouteNames.splash,
      page: SplashView.new,
      binding: SplashBinding(),
    ),
    GetPage(
      name: RouteNames.onboarding,
      page: OnboardingView.new,
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: RouteNames.authentication,
      page: AuthenticationView.new,
      binding: AuthenticationBinding(),
    ),
    GetPage(
      name: RouteNames.signup,
      page: SignupView.new,
      binding: SignupBinding(),
    ),
    GetPage(
      name: RouteNames.forgotPassword,
      page: ForgotPasswordView.new,
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: RouteNames.otpVerification,
      page: OtpVerificationView.new,
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: RouteNames.resetPassword,
      page: ResetPasswordView.new,
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: RouteNames.passwordResetSuccess,
      page: PasswordResetSuccessView.new,
    ),
    GetPage(
      name: RouteNames.home,
      page: HomeView.new,
      binding: HomeBinding(),
    ),
    GetPage(
      name: RouteNames.plantScan,
      page: PlantScanView.new,
      binding: PlantScanBinding(),
    ),
    GetPage(
      name: RouteNames.diseaseDetection,
      page: DiseaseDetectionView.new,
      binding: DiseaseDetectionBinding(),
    ),
    GetPage(
      name: RouteNames.plantDetails,
      page: PlantDetailsView.new,
      binding: PlantDetailsBinding(),
    ),
    GetPage(
      name: RouteNames.search,
      page: SearchView.new,
      binding: SearchBinding(),
    ),
    GetPage(
      name: RouteNames.myGarden,
      page: MyGardenView.new,
      binding: MyGardenBinding(),
    ),
    GetPage(
      name: RouteNames.reminder,
      page: ReminderView.new,
      binding: ReminderBinding(),
    ),
    GetPage(
      name: RouteNames.articles,
      page: ArticlesView.new,
      binding: ArticlesBinding(),
    ),
    GetPage(
      name: RouteNames.subscription,
      page: SubscriptionView.new,
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: RouteNames.profile,
      page: ProfileView.new,
      binding: ProfileBinding(),
    ),
    GetPage(
      name: RouteNames.settings,
      page: SettingsView.new,
      binding: SettingsBinding(),
    ),
  ];
}
