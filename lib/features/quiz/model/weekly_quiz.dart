import 'package:shared_preferences/shared_preferences.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.why,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String why;
}

class WeeklyQuiz {
  WeeklyQuiz._();

  static const weekLabel = 'Week 34';
  static const prompt = 'How much of a botanist are you?';
  static const _weekKey = 'weekly_quiz_week';
  static const _scoreKey = 'weekly_quiz_score';

  static const questions = <QuizQuestion>[
    QuizQuestion(
      prompt: 'When should you water most houseplants?',
      options: [
        'On the same weekday every week',
        'When the top inch of mix feels dry',
        'As soon as the surface looks pale',
        'Only when the leaves droop',
      ],
      correctIndex: 1,
      why: 'Most houseplants prefer a short dry spell over a fixed watering day.',
    ),
    QuizQuestion(
      prompt: 'Why rotate a houseplant a quarter turn each week?',
      options: [
        'To mix the soil',
        'So every side gets light and it grows full',
        'To stop the pot from sticking',
        'To dry the soil faster',
      ],
      correctIndex: 1,
      why: 'Indoor light comes from one side, so a weekly turn keeps growth even.',
    ),
    QuizQuestion(
      prompt: 'What does trimming spent blooms (deadheading) do?',
      options: [
        'It stops the plant from growing taller',
        'It redirects energy into new blooms',
        'It waters the plant through the stem',
        'It makes the soil drain faster',
      ],
      correctIndex: 1,
      why: 'Removing faded flowers sends energy into new blooms instead of seed.',
    ),
  ];

  static String resultTitle(int score, int total) {
    if (score >= total) return "You're a botanist";
    if (score >= total - 1) return 'Almost there';
    return 'Keep growing';
  }

  static String shareText(int score, int total) {
    if (score >= total) {
      return 'I got $score/$total on the $weekLabel Quiz. $prompt';
    }
    return '$weekLabel Quiz — I scored $score/$total. $prompt';
  }

  static Future<int?> loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_weekKey) != weekLabel) return null;
    return prefs.getInt(_scoreKey);
  }

  static Future<void> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weekKey, weekLabel);
    await prefs.setInt(_scoreKey, score);
  }
}
