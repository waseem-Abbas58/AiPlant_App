import 'package:get/get.dart';

import '../../quiz/model/weekly_quiz.dart';

class HomeController extends GetxController {
  final showAllPlantTools = false.obs;
  final showAllCategories = false.obs;
  final quizScore = RxnInt();

  @override
  void onInit() {
    super.onInit();
    WeeklyQuiz.loadScore().then((score) => quizScore.value = score);
  }

  void togglePlantTools() => showAllPlantTools.toggle();
  void toggleCategories() => showAllCategories.toggle();
}
