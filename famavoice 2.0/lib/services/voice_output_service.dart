
import 'package:flutter_tts/flutter_tts.dart';

class VoiceOutputService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    // Strip emojis and asterisks for cleaner TTS output
    final sanitizedText = text
        .replaceAll(RegExp(r'\*'), '') // Remove asterisks
        .replaceAll(
            RegExp(
                '(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'),
            '');
    await _flutterTts.speak(sanitizedText);
  }

  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }
}
