class ChatPlantContext {
  const ChatPlantContext({
    required this.name,
    this.imagePath,
    this.isAssetImage = false,
    this.plantId,
  });

  final String name;
  final String? imagePath;
  final bool isAssetImage;
  final String? plantId;

  bool get hasPhoto => imagePath != null && imagePath!.trim().isNotEmpty;

  bool sameAs(ChatPlantContext? other) {
    if (other == null) return false;
    if (plantId != null && other.plantId != null) return plantId == other.plantId;
    return name == other.name && imagePath == other.imagePath;
  }
}

class ChatHint {
  const ChatHint({required this.label, required this.prompt});

  final String label;
  final String prompt;
}

enum ChatReplyMood { good, bad }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.fromUser,
    this.text = '',
    this.imagePath,
    this.isAssetImage = false,
    this.isTyping = false,
    this.fileName,
    this.filePath,
    this.mood,
  });

  final String id;
  final String text;
  final bool fromUser;
  final String? imagePath;
  final bool isAssetImage;
  final bool isTyping;
  final String? fileName;
  final String? filePath;
  final ChatReplyMood? mood;

  bool get hasPhoto => imagePath != null && imagePath!.trim().isNotEmpty;
  bool get hasFile => fileName != null && fileName!.trim().isNotEmpty;

  ChatMessage copyWith({
    ChatReplyMood? mood,
    bool clearMood = false,
  }) {
    return ChatMessage(
      id: id,
      fromUser: fromUser,
      text: text,
      imagePath: imagePath,
      isAssetImage: isAssetImage,
      isTyping: isTyping,
      fileName: fileName,
      filePath: filePath,
      mood: clearMood ? null : (mood ?? this.mood),
    );
  }
}

class ChatThread {
  ChatThread({
    required this.id,
    required this.title,
    required this.updatedAt,
    this.plant,
    this.pinned = false,
    this.archived = false,
    List<ChatMessage> messages = const [],
  }) : messages = List<ChatMessage>.unmodifiable(messages);

  final String id;
  final String title;
  final DateTime updatedAt;
  final ChatPlantContext? plant;
  final bool pinned;
  final bool archived;
  final List<ChatMessage> messages;

  ChatThread copyWith({
    String? title,
    DateTime? updatedAt,
    ChatPlantContext? plant,
    bool? pinned,
    bool? archived,
    List<ChatMessage>? messages,
  }) {
    return ChatThread(
      id: id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      plant: plant ?? this.plant,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      messages: messages ?? this.messages,
    );
  }
}

class ChatFindHit {
  const ChatFindHit({
    required this.messageId,
    required this.start,
    required this.length,
  });

  final String messageId;
  final int start;
  final int length;
}
