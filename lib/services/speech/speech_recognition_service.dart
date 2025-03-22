import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  // Initialize the speech recognition service
  Future<bool> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize();
    }
    return _isInitialized;
  }

 // Start listening with continuous recognition
  Future<void> startListening({
    required Function(String) onResult,
    required Function(double) onSoundLevelChange,
    required Function(String) onStatus,
    String accumulatedText = '',
    Duration pauseTimeout = const Duration(seconds: 15), // Increased pause timeout to 15 seconds
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_speech.isNotListening) {
      await _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            final text = accumulatedText + ' ' + result.recognizedWords;
            onResult(text);
          }
        },
        listenFor: const Duration(minutes: 30),
        pauseFor: pauseTimeout, // Use the provided pause timeout
        partialResults: true,
        onSoundLevelChange: onSoundLevelChange,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation, // Use dictation mode for continuous speech
      );
      
      _speech.statusListener = onStatus;
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    await _speech.stop();
  }

  // Check if speech recognition is available
  bool get isAvailable => _isInitialized;

  // Check if currently listening
  bool get isListening => _speech.isListening;

  // Check if not currently listening
  bool get isNotListening => _speech.isNotListening;
}