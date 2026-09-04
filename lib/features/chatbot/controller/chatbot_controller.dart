import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/helpers/permission_helper.dart';
import '../../../shared/components/custom_snackbar.dart';
import '../../my_garden/controller/my_garden_controller.dart';
import '../../my_garden/model/my_garden_model.dart';
import '../data/botanist_api.dart';
import '../data/botanist_chat.dart';
import '../model/chat_message.dart';

class ChatbotController extends GetxController {
  ChatbotController({BotanistApi? botanistApi})
      : _botanistApi = botanistApi ?? BotanistApi();

  final BotanistApi _botanistApi;

  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode inputFocus = FocusNode();
  final SpeechToText _speech = SpeechToText();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxList<ChatThread> recents = <ChatThread>[].obs;
  final RxnString activeThreadId = RxnString();
  final Rxn<ChatPlantContext> plantContext = Rxn<ChatPlantContext>();
  final RxBool isBusy = false.obs;
  final RxBool isListening = false.obs;
  final RxString draft = ''.obs;
  final RxnString pendingImagePath = RxnString();
  final RxBool finding = false.obs;
  final RxString findQuery = ''.obs;
  final RxInt findHitIndex = 0.obs;
  final RxList<ChatFindHit> findHits = <ChatFindHit>[].obs;
  final TextEditingController findController = TextEditingController();
  final FocusNode findFocus = FocusNode();

  bool get hasThread => messages.any((line) => line.fromUser && !line.isTyping);
  bool get hasPendingPhoto {
    final path = pendingImagePath.value;
    return path != null && path.trim().isNotEmpty;
  }

  bool get canSend => draft.value.trim().isNotEmpty || hasPendingPhoto;

  bool get activePinned {
    final id = activeThreadId.value;
    if (id == null) return false;
    return recents.any((thread) => thread.id == id && thread.pinned);
  }

  bool get activeArchived {
    final id = activeThreadId.value;
    if (id == null) return false;
    return recents.any((thread) => thread.id == id && thread.archived);
  }

  ({
    List<ChatThread> pinned,
    List<ChatThread> recents,
    List<ChatThread> archived,
  }) historyGroups(String query) {
    final needle = query.trim().toLowerCase();
    final pinned = <ChatThread>[];
    final open = <ChatThread>[];
    final archived = <ChatThread>[];
    for (final thread in recents) {
      if (needle.isNotEmpty && !_historyMatch(thread, needle)) continue;
      if (thread.archived) {
        archived.add(thread);
      } else if (thread.pinned) {
        pinned.add(thread);
      } else {
        open.add(thread);
      }
    }
    int byDate(ChatThread a, ChatThread b) =>
        b.updatedAt.compareTo(a.updatedAt);
    pinned.sort(byDate);
    open.sort(byDate);
    archived.sort(byDate);
    return (pinned: pinned, recents: open, archived: archived);
  }

  bool _historyMatch(ChatThread thread, String needle) {
    if (thread.title.toLowerCase().contains(needle)) return true;
    final plant = thread.plant?.name.toLowerCase() ?? '';
    if (plant.contains(needle)) return true;
    for (final line in thread.messages) {
      if (line.text.toLowerCase().contains(needle)) return true;
      final file = line.fileName?.toLowerCase() ?? '';
      if (file.contains(needle)) return true;
    }
    return false;
  }  

  @override
  void onInit() {
    super.onInit();
    inputController.addListener(_syncDraft);
  }

  void _syncDraft() {
    draft.value = inputController.text;
  }

  void startForPlant(ChatPlantContext plant) {
    final current = plantContext.value;
    if (plant.sameAs(current) && hasThread) return;
    _commitActive();
    activeThreadId.value = null;
    plantContext.value = plant;
    messages.clear();
  }

  void clearPlantContext() {
    plantContext.value = null;
    _commitActive();
  }

  void newChat() {
    _commitActive();
    activeThreadId.value = null;
    messages.clear();
    plantContext.value = null;
    inputController.clear();
    pendingImagePath.value = null;
    closeFind();
  }

  void openThread(ChatThread thread) {
    if (activeThreadId.value == thread.id) return;
    _commitActive();
    activeThreadId.value = thread.id;
    plantContext.value = thread.plant;
    messages.assignAll(thread.messages);
    inputController.clear();
    pendingImagePath.value = null;
    closeFind();
  }

  void deleteThread(String id) {
    recents.removeWhere((thread) => thread.id == id);
    if (activeThreadId.value != id) return;
    activeThreadId.value = null;
    messages.clear();
    plantContext.value = null;
    pendingImagePath.value = null;
    closeFind();
  }

  void deleteActive() {
    final id = activeThreadId.value;
    if (!hasThread && id == null) {
      CustomSnackbar.info(
        title: 'Nothing to delete',
        message: 'Start a chat first.',
      );
      return;
    }
    _commitActive();
    final activeId = activeThreadId.value;
    if (activeId == null) {
      newChat();
      return;
    }
    deleteThread(activeId);
  }

  void togglePin() {
    if (!_ensureThread()) return;
    final id = activeThreadId.value!;
    final index = recents.indexWhere((thread) => thread.id == id);
    if (index < 0) return;
    recents[index] = recents[index].copyWith(
      pinned: !recents[index].pinned,
    );
    recents.refresh();
  }

  void toggleArchive() {
    if (!_ensureThread()) return;
    final id = activeThreadId.value!;
    final index = recents.indexWhere((thread) => thread.id == id);
    if (index < 0) return;
    final thread = recents[index];
    recents[index] = thread.copyWith(
      archived: !thread.archived,
      pinned: thread.archived ? thread.pinned : false,
    );
    recents.refresh();
  }

  bool _ensureThread() {
    if (!hasThread) {
      CustomSnackbar.info(
        title: 'Chat is empty',
        message: 'Ask something first.',
      );
      return false;
    }
    _commitActive();
    return activeThreadId.value != null;
  }

  void openFind() {
    finding.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!findFocus.hasFocus) findFocus.requestFocus();
    });
  }

  void closeFind() {
    if (!finding.value && findQuery.value.isEmpty) return;
    finding.value = false;
    findQuery.value = '';
    findHits.clear();
    findHitIndex.value = 0;
    findController.clear();
    findFocus.unfocus();
  }

  void setFindQuery(String query) {
    findQuery.value = query;
    _rebuildFindHits();
  }

  void findStep(int delta) {
    if (findHits.isEmpty) return;
    final next = (findHitIndex.value + delta) % findHits.length;
    findHitIndex.value = next < 0 ? next + findHits.length : next;
    _scrollToFindHit();
  }

  void _rebuildFindHits() {
    final needle = findQuery.value.trim().toLowerCase();
    final hits = <ChatFindHit>[];
    if (needle.isNotEmpty) {
      for (var i = messages.length - 1; i >= 0; i--) {
        final line = messages[i];
        if (line.isTyping) continue;
        final lower = line.text.toLowerCase();
        var from = 0;
        while (true) {
          final at = lower.indexOf(needle, from);
          if (at < 0) break;
          hits.add(
            ChatFindHit(
              messageId: line.id,
              start: at,
              length: needle.length,
            ),
          );
          from = at + needle.length;
        }
      }
    }
    findHits.assignAll(hits);
    findHitIndex.value = 0;
    _scrollToFindHit();
  }

  void _scrollToFindHit() {
    if (findHits.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (findHits.isEmpty) return;
      final hit = findHits[findHitIndex.value];
      final context = GlobalObjectKey(hit.messageId).currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: 0.35,
      );
    });
  }

  void pickGardenPlant(GardenPlant plant) {
    startForPlant(
      ChatPlantContext( 
        name: plant.name, 
        imagePath: plant.imagePath,
        isAssetImage: plant.isAssetImage,  
        plantId: plant.id,  
      ),
    ); 
  }

  Future<void> attachPhoto(ImageSource source) async {
    await stopVoice();
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (file == null) return;
    _stagePhoto(file.path);
  }

  void clearPendingPhoto() {
    pendingImagePath.value = null;
  }

  void _stagePhoto(String path) {
    pendingImagePath.value = path;
    inputFocus.requestFocus();
  }

  Future<void> attachDocument() async {
    await stopVoice();
    final result = await FilePicker.platform.pickFiles();
    final file = result?.files.single;
    final path = file?.path;
    final name = file?.name.trim() ?? '';
    if (file == null || path == null || path.isEmpty || name.isEmpty) return;

    const imageExts = {'png', 'jpg', 'jpeg', 'webp', 'gif', 'heic', 'heif'};
    final ext = name.split('.').last.toLowerCase();
    if (imageExts.contains(ext)) {
      _stagePhoto(path);
      return;
    }

    await send(
      preset: 'I attached $name',
      fileName: name,
      filePath: path,
    );
  }

  Future<void> sendSticker(String sticker) {
    return send(preset: sticker);
  }

  Future<void> sendHint(ChatHint hint) {
    return send(preset: hint.prompt);
  }

  Future<void> toggleVoice() async {
    if (isListening.value) {
      await stopVoice();
      return;
    }

    await PermissionHelper.request(AppPermission.microphone);
    if (!await PermissionHelper.isGranted(AppPermission.microphone)) {
      final locked =
          await PermissionHelper.isPermanentlyDenied(AppPermission.microphone);
      CustomSnackbar.warning(
        title: 'Microphone needed',
        message: locked
            ? 'Enable microphone in Settings to speak to Ask Botanist.'
            : 'Microphone permission is required for voice questions.',
        actionLabel: locked ? 'Settings' : null,
        onAction: locked ? PermissionHelper.openSettings : null,
      );
      return;
    }

    final ready = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          isListening.value = false;
        }
      },
      onError: (_) {
        isListening.value = false;
      },
    );
    if (!ready) {
      CustomSnackbar.info(
        title: 'Voice unavailable',
        message: 'Speech is not available on this device right now.',
      );
      return;
    }

    isListening.value = true;
    await _speech.listen(
      onResult: (result) {
        inputController.text = result.recognizedWords;
        inputController.selection = TextSelection.collapsed(
          offset: inputController.text.length,
        );
      },
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
    );
  }

  Future<void> stopVoice() async {
    if (!_speech.isListening && !isListening.value) return;
    await _speech.stop();
    isListening.value = false;
  }

  Future<String?> send({
    String? preset,
    String? imagePath,
    String? fileName,
    String? filePath,
  }) async {
    await stopVoice();
    final fromComposer =
        preset == null && imagePath == null && fileName == null;
    final photo = imagePath ?? (fromComposer ? pendingImagePath.value : null);
    final text = (preset ?? inputController.text).trim();
    if ((text.isEmpty && photo == null && fileName == null) || isBusy.value) {
      return null;
    }

    inputController.clear();
    if (fromComposer) pendingImagePath.value = null;
    isBusy.value = true;

    messages.add(
      ChatMessage(
        id: 'u-${DateTime.now().microsecondsSinceEpoch}',
        text: text,
        fromUser: true,
        imagePath: photo,
        fileName: fileName,
        filePath: filePath,
      ),
    );
    _scrollToEnd();

    final typingId = 't-${DateTime.now().microsecondsSinceEpoch}';
    messages.add(
      ChatMessage(
        id: typingId,
        fromUser: false,
        isTyping: true,
      ),
    );
    _scrollToEnd();

    final question = text.isEmpty ? 'photo' : text;
    final plant = plantContext.value;
    final liveReply = await _botanistApi.ask(
      message: question,
      plantName: plant?.name ?? '',
      issue: plant?.issue ?? '',
    );
    if (isClosed) return null;

    messages.removeWhere((line) => line.id == typingId);
    final live = liveReply?.trim() ?? '';
    if (live.isEmpty) {
      CustomSnackbar.info(
        title: 'Ask AI offline',
        message: 'Start the backend with npm run dev, then send again.',
      );
    }
    final reply = live.isNotEmpty
        ? live
        : BotanistChat.replyFor(question, plant);
    messages.add(
      ChatMessage(
        id: 'b-${DateTime.now().microsecondsSinceEpoch}',
        fromUser: false,
        text: reply,
      ),
    );
    isBusy.value = false;
    _commitActive();
    _scrollToEnd();
    return reply;
  }

  Future<void> copyReply(ChatMessage message) async {
    final text = message.text.trim();
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
  }

  void rateReply(String id, ChatReplyMood mood) {
    final index = messages.indexWhere((line) => line.id == id);
    if (index < 0) return;
    final current = messages[index];
    if (current.fromUser || current.isTyping) return;
    messages[index] = current.copyWith(
      mood: mood,
      clearMood: current.mood == mood,
    );
    _commitActive();
  }

  Future<void> shareReply(ChatMessage message) async {
    final text = message.text.trim();
    if (text.isEmpty) return;
    final plant = plantContext.value?.name.trim() ?? '';
    final body = plant.isEmpty
        ? 'Ask Botanist\n\n$text'
        : 'Ask Botanist — $plant\n\n$text';
    await Share.share(body, subject: 'Ask Botanist');
  }

  void _commitActive() {
    final stored = messages.where((line) => !line.isTyping).toList();
    if (stored.every((line) => !line.fromUser)) return;

    final id = activeThreadId.value ??
        'chat-${DateTime.now().microsecondsSinceEpoch}';
    activeThreadId.value = id;
    ChatThread? previous;
    final prevIndex = recents.indexWhere((thread) => thread.id == id);
    if (prevIndex >= 0) previous = recents[prevIndex];
    recents.removeWhere((thread) => thread.id == id);
    recents.insert(
      0,
      ChatThread(
        id: id,
        title: _titleFor(stored, plantContext.value),
        updatedAt: DateTime.now(),
        plant: plantContext.value,
        pinned: previous?.pinned ?? false,
        archived: previous?.archived ?? false,
        messages: stored,
      ),
    );
  }

  String _titleFor(List<ChatMessage> stored, ChatPlantContext? plant) {
    final plantName = plant?.name.trim() ?? '';
    if (plantName.isNotEmpty) return plantName;
    for (final line in stored) {
      if (!line.fromUser) continue;
      if (line.hasFile) return line.fileName ?? 'Document';
      if (line.hasPhoto) return 'Photo question';
      final text = line.text.trim();
      if (text.isEmpty) continue;
      if (!RegExp(r'[A-Za-z0-9]').hasMatch(text)) continue;
      return text.length > 42 ? '${text.substring(0, 42)}…' : text;
    }
    return 'Chat';
  }

  List<GardenPlant> gardenPlants() {
    if (!Get.isRegistered<MyGardenController>()) return const [];
    return Get.find<MyGardenController>().plants.toList();
  }

  void showEmptyGardenHint() {
    CustomSnackbar.info(
      title: 'No plants yet',
      message: 'Add a plant to your garden, then ask about it here.',
    );
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void onClose() {
    inputController.removeListener(_syncDraft);
    inputController.dispose();
    findController.dispose();
    findFocus.dispose();
    scrollController.dispose();
    inputFocus.dispose();
    _speech.cancel();
    super.onClose();
  }
}
