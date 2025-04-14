import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (!_isInitialized) {
      print('SpeechRecognitionService: Initializing...'); // NEW: Debug
      _isInitialized = await _speech.initialize(
        onStatus: (status) => print('SpeechRecognitionService: Status: $status'),
        onError: (error) => print('SpeechRecognitionService: Error: $error'),
      );
      print('SpeechRecognitionService: Initialized: $_isInitialized');
    }
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(double) onSoundLevelChange,
    required Function(String) onStatus,
    String accumulatedText = '',
    Duration pauseTimeout = const Duration(seconds: 5), // NEW: Shorter for calls
    String language = 'en-US',
    int sampleRate = 16000, // NEW: Explicit sample rate
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_speech.isNotListening) {
      print('SpeechRecognitionService: Starting listening (language: $language, sampleRate: $sampleRate)'); // NEW: Debug
      await _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            final text = accumulatedText + ' ' + result.recognizedWords;
            print('SpeechRecognitionService: Result: $text'); // NEW: Debug
            onResult(text);
          }
        },
        listenFor: const Duration(minutes: 30),
        pauseFor: pauseTimeout,
        partialResults: true,
        onSoundLevelChange: (level) {
          print('SpeechRecognitionService: Sound level: $level'); // NEW: Debug
          onSoundLevelChange(level);
        },
        cancelOnError: false,
        listenMode: stt.ListenMode.confirmation, // NEW: Try confirmation mode
        localeId: language,
        sampleRate: sampleRate, // NEW: Set sample rate
      );

      _speech.statusListener = (status) {
        print('SpeechRecognitionService: Status listener: $status'); // NEW: Debug
        onStatus(status);
      };
    } else {
      print('SpeechRecognitionService: Already listening');
    }
  }

  Future<void> stopListening() async {
    print('SpeechRecognitionService: Stopping listening');
    await _speech.stop();
  }

  bool get isAvailable => _isInitialized;
  bool get isListening => _speech.isListening;
  bool get isNotListening => _speech.isNotListening;
}