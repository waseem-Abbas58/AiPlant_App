import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/helpers/navigation_helper.dart';
import '../../../core/helpers/permission_helper.dart';
import '../../../shared/components/custom_snackbar.dart';
import '../data/botanist_chat.dart';
import 'chatbot_controller.dart';

class BotanistCallController extends GetxController {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  final RxBool inCall = false.obs;
  final RxBool muted = false.obs;
  final RxBool listening = false.obs;
  final RxBool speaking = false.obs;
  final RxString caption = ''.obs;

  bool _speechReady = false;
  bool _turnBusy = false;

  ChatbotController get _chat => Get.find<ChatbotController>();

  String get plantLabel {
    final name = _chat.plantContext.value?.name.trim() ?? '';
    return name.isEmpty ? 'Ask Botanist' : name;
  }

  @override
  void onInit() {
    super.onInit();
    startCall();
  }

  Future<void> startCall() async {
    await _chat.stopVoice();
    await PermissionHelper.request(AppPermission.microphone);
    if (!await PermissionHelper.isGranted(AppPermission.microphone)) {
      final locked =
          await PermissionHelper.isPermanentlyDenied(AppPermission.microphone);
      CustomSnackbar.warning(
        title: 'Microphone needed',
        message: locked
            ? 'Enable microphone in Settings to talk with Ask Botanist.'
            : 'Microphone permission is required for a voice call.',
        actionLabel: locked ? 'Settings' : null,
        onAction: locked ? PermissionHelper.openSettings : null,
      );
      hangUp();
      return;
    }

    _speechReady = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: (_) {
        listening.value = false;
        if (inCall.value && !muted.value && !_turnBusy && !speaking.value) {
          _listenRound();
        }
      },
    );
    if (!_speechReady) {
      CustomSnackbar.info(
        title: 'Voice unavailable',
        message: 'Speech is not available on this device right now.',
      );
      hangUp();
      return;
    }

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.46);
    await _tts.awaitSpeakCompletion(true);

    inCall.value = true;
    caption.value = 'Listening…';
    await _speak('Hi, ask me about your plants.');
    if (inCall.value && !muted.value) {
      await _listenRound();
    }
  }

  Future<void> toggleMute() async {
    muted.value = !muted.value;
    if (muted.value) {
      await _speech.stop();
      listening.value = false;
      caption.value = 'Muted';
      return;
    }
    caption.value = 'Listening…';
    await _listenRound();
  }

  Future<void> hangUp() async {
    inCall.value = false;
    _turnBusy = false;
    muted.value = false;
    listening.value = false;
    speaking.value = false;
    await _speech.stop();
    await _tts.stop();
    if (Get.key.currentState?.canPop() ?? false) {
      NavigationHelper.back();
    }
  }

  Future<void> _listenRound() async {
    if (!inCall.value || muted.value || speaking.value || _turnBusy) return;
    if (_speech.isListening) return;

    listening.value = true;
    if (caption.value.isEmpty || caption.value == 'Muted') {
      caption.value = 'Listening…';
    }

    await _speech.listen(
      onResult: (result) {
        if (!inCall.value || muted.value) return;
        final words = result.recognizedWords.trim();
        if (words.isNotEmpty) caption.value = words;
        if (result.finalResult) {
          _onFinalWords(words);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.dictation,
    );
  }

  void _onSpeechStatus(String status) {
    if (!inCall.value) return;
    if (status != 'done' && status != 'notListening') return;
    listening.value = false;
    if (muted.value || speaking.value || _turnBusy) return;
    Future<void>.delayed(const Duration(milliseconds: 280), _listenRound);
  }

  Future<void> _onFinalWords(String words) async {
    if (!inCall.value || _turnBusy || words.isEmpty) return;
    _turnBusy = true;
    listening.value = false;
    await _speech.stop();

    final reply = await _chat.send(preset: words) ??
        BotanistChat.replyFor(words, _chat.plantContext.value);
    caption.value = reply;
    await _speak(reply);
    _turnBusy = false;
    if (inCall.value && !muted.value) {
      caption.value = 'Listening…';
      await _listenRound();
    }
  }

  Future<void> _speak(String text) async {
    if (!inCall.value || text.trim().isEmpty) return;
    speaking.value = true;
    try {
      await _tts.speak(text);
    } finally {
      speaking.value = false;
    }
  }

  @override
  void onClose() {
    inCall.value = false;
    _speech.stop();
    _tts.stop();
    super.onClose();
  }
}
