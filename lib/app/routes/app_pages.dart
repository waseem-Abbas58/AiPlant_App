import 'package:get/get.dart';

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
import '../../features/main_navigation/bindings/main_navigation_binding.dart';
import '../../features/main_navigation/view/main_navigation_view.dart';
import '../../features/my_garden/bindings/my_garden_binding.dart';
import '../../features/my_garden/bindings/plant_finder_binding.dart';
import '../../features/my_garden/view/my_garden_view.dart';
import '../../features/my_garden/view/plant_finder_view.dart';
import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../features/onboarding/view/onboarding_view.dart';
import '../../features/plant_scan/bindings/plant_scan_binding.dart';
import '../../features/plant_scan/view/plant_scan_view.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/view/profile_view.dart';
import '../../features/quiz/view/quiz_welcome_view.dart';
import '../../features/suggestions/view/suggestion_detail_view.dart';
import '../../features/chatbot/bindings/chatbot_binding.dart';
import '../../features/chatbot/view/chatbot_view.dart';
import '../../features/search/bindings/search_binding.dart';
import '../../features/search/view/search_view.dart';
import '../../features/settings/bindings/settings_binding.dart';
import '../../features/settings/view/settings_view.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/view/splash_view.dart';
import '../../features/subscription/bindings/subscription_binding.dart';
import '../../features/subscription/view/subscription_view.dart';
import '../../features/home/model/suggestion_article.dart';
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
      page: MainNavigationView.new,
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: RouteNames.plantScan,
      page: PlantScanView.new,
      binding: PlantScanBinding(),
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
      name: RouteNames.plantFinder,
      page: PlantFinderView.new,
      binding: PlantFinderBinding(),
    ),
    GetPage(
      name: RouteNames.chat,
      page: ChatbotView.new,
      binding: ChatbotBinding(),
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
    GetPage(
      name: RouteNames.weeklyQuiz,
      page: QuizWelcomeView.new,
    ),
    GetPage(
      name: RouteNames.suggestionDetail,
      page: () {
        final args = Get.arguments;
        final article = args is SuggestionArticle
            ? args
            : SuggestionArticle.samples.first;
        return SuggestionDetailView(article: article);
      },
    ),
  ];
}
