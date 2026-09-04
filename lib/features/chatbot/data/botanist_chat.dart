import '../model/chat_message.dart';

class BotanistChat {
  BotanistChat._();

  static const hints = <ChatHint>[
    ChatHint(
      label: 'Watering',
      prompt: 'How often should I water this plant?',
    ),
    ChatHint(
      label: 'Yellow leaves',
      prompt: 'Why are the leaves turning yellow?',
    ),
    ChatHint(
      label: 'Light',
      prompt: 'How much light does this plant need?',
    ),
    ChatHint(
      label: 'Pests',
      prompt: 'How do I check for pests and treat them?',
    ),
    ChatHint(
      label: 'Toxicity',
      prompt: 'Is this plant toxic to pets?',
    ),
  ];

  static const stickers = <String>[
    '🌱',
    '💧',
    '☀️',
    '🍃',
    '🪴',
    '🌼',
    '🐛',
    '👍',
  ];

  static String replyFor(String question, ChatPlantContext? plant) {
    final q = question.toLowerCase();
    final name = plant?.name ?? 'your plant';
    final issue = plant?.issue?.trim() ?? '';
    final trimmed = question.trim();

    if (trimmed.isNotEmpty && !RegExp(r'[A-Za-z0-9]').hasMatch(trimmed)) {
      return 'Got it. Tell me what you see on $name — yellowing, pests, or dry soil.';
    }
    if (q.contains('attached') || q.contains('.pdf') || q.contains('.doc')) {
      return 'I can see the file. Summarize what it says about $name, or ask a care question and I will guide from there.';
    }

    if (q.contains('water')) {
      return 'For $name, water when the top 2–3 cm of soil feels dry. '
          'Soak until a little drains out, then empty the saucer. '
          'If leaves droop and soil is wet, wait — that is often overwatering.';
    }
    if (q.contains('yellow')) {
      return 'Yellow leaves on $name are usually watering or light. '
          'If soil stays wet, ease up and check drainage. '
          'If soil is bone-dry and lower leaves yellow, water more evenly. '
          'A photo of the leaf helps narrow it down.';
    }
    if (q.contains('light') || q.contains('sun')) {
      return '$name generally likes bright, indirect light. '
          'A few hours of gentle morning sun is fine; harsh afternoon sun can scorch. '
          'Rotate the pot weekly so growth stays even.';
    }
    if (q.contains('pest') || q.contains('bug') || q.contains('mite')) {
      return 'Check $name under leaves and along stems. '
          'Wipe with a damp cloth, then use a mild soap spray or neem if you see webbing, sticky residue, or moving dots. '
          'Isolate from other plants until it looks clear.';
    }
    if (q.contains('toxic') ||
        q.contains('pet') ||
        q.contains('cat') ||
        q.contains('dog')) {
      return 'Treat $name as not pet-safe until you confirm the species. '
          'Keep leaves out of reach of cats and dogs, and do not let anyone chew stems. '
          'If a pet ate some, call a vet with the plant name.';
    }
    if (q.contains('repot') || q.contains('pot')) {
      return 'Repot $name when roots circle the pot or water runs straight through. '
          'Go one size up, use fresh mix, and wait a few days before a full watering.';
    }

    if (issue.isNotEmpty) {
      return 'For $name, the health scan mentioned $issue. '
          'Ask what to do today, how to water, or whether to isolate the plant.';
    }
    return 'Ask about watering, light, yellow leaves, pests, or toxicity for $name. '
        'You can also attach a leaf photo.';
  }
}
