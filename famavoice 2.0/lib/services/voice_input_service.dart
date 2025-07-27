
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';

class VoiceInputService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Timer? _listenTimer;

  Future<void> init() async {
    _isInitialized = await _speechToText.initialize();
  }

  void startListening({
    required Function(String) onResult,
    required Function(bool) onListening,
    required String localeId,
    Function(String)? onPartialResult,
  }) {
    if (!_isInitialized) return;

    _listenTimer?.cancel(); // Cancel any previous timer

    _speechToText.listen(
      onResult: (result) {
        _listenTimer?.cancel(); // Reset timer on new speech
        _listenTimer = Timer(const Duration(seconds: 3), () {
          _speechToText.stop();
          onListening(false);
        });

        if (result.finalResult) {
          onResult(result.recognizedWords);
          _listenTimer?.cancel(); // Stop timer on final result
          onListening(false);
        } else if (onPartialResult != null) {
          onPartialResult(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(partialResults: true),
      localeId: localeId,
      onSoundLevelChange: (level) {},
    );
    onListening(_speechToText.isListening);

    // Start initial timer for silence detection
    _listenTimer = Timer(const Duration(seconds: 3), () {
      _speechToText.stop();
      onListening(false);
    });
  }

  void stopListening() {
    if (!_isInitialized) return;
    _listenTimer?.cancel();
    _speechToText.stop();
  }

  void cancelListening() {
    if (!_isInitialized) return;
    _listenTimer?.cancel();
    _speechToText.cancel();
  }

  void dispose() {
    _listenTimer?.cancel();
  }
}
