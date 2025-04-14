import 'dart:async';
import 'package:eazytalk/services/speech/speech_recognition_service.dart';
import 'package:flutter/material.dart';

class VideoCallSpeechService {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();

  bool _isInitialized = false;
  bool _isListening = false;
  String _transcribedText = '';
  double _soundLevel = 0.0;

  final StreamController<String> _transcriptController = StreamController<String>.broadcast();
  Stream<String> get transcriptStream => _transcriptController.stream;

  final StreamController<double> _soundLevelController = StreamController<double>.broadcast();
  Stream<double> get soundLevelStream => _soundLevelController.stream;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get transcribedText => _transcribedText;

  Future<bool> initialize() async {
    if (!_isInitialized) {
      print('VideoCallSpeechService: Initializing...');
      _isInitialized = await _speechService.initialize();
      print('VideoCallSpeechService: Initialized: $_isInitialized');
    }
    return _isInitialized;
  }

  Future<bool> startListening({String language = 'en-US', int? sampleRate}) async {
    if (_isListening) {
      print('VideoCallSpeechService: Already listening');
      return true;
    }

    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      print('VideoCallSpeechService: Not initialized');
      return false;
    }

    try {
      void handleStatus(String status) {
        print('VideoCallSpeechService: Status: $status');
        if (status == 'done' && _isListening) {
          final accumulatedText = _transcribedText;
          Future.delayed(const Duration(milliseconds: 1000), () { // NEW: Longer delay
            if (_isListening) {
              print('VideoCallSpeechService: Restarting with text: $accumulatedText');
              _startListeningInternal(
                accumulatedText: accumulatedText,
                language: language,
                sampleRate: sampleRate,
                statusHandler: handleStatus,
              );
            }
          });
        }
      }

      print('VideoCallSpeechService: Starting listening');
      await _startListeningInternal(
        language: language,
        sampleRate: sampleRate,
        statusHandler: handleStatus,
      );

      _isListening = true;
      return true;
    } catch (e) {
      print('VideoCallSpeechService: Error starting: $e');
      return false;
    }
  }

  Future<void> _startListeningInternal({
    String accumulatedText = '',
    required String language,
    int? sampleRate,
    required Function(String) statusHandler,
  }) async {
    await _speechService.startListening(
      onResult: (text) {
        print('VideoCallSpeechService: Result: $text');
        _transcribedText = text;
        _transcriptController.add(text);
      },
      onSoundLevelChange: (level) {
        print('VideoCallSpeechService: Sound level: $level');
        _soundLevel = level;
        _soundLevelController.add(level);
      },
      onStatus: statusHandler,
      accumulatedText: accumulatedText,
      pauseTimeout: const Duration(seconds: 3),
      language: language,
      sampleRate: sampleRate ?? 16000,
    );
  }

  Future<void> stopListening() async {
    if (!_isListening) {
      print('VideoCallSpeechService: Not listening');
      return;
    }

    print('VideoCallSpeechService: Stopping');
    await _speechService.stopListening();
    _isListening = false;
    _transcribedText = '';
    _transcriptController.add('');
  }

  void clearTranscript() {
    print('VideoCallSpeechService: Clearing transcript');
    _transcribedText = '';
    _transcriptController.add('');
  }

  void dispose() {
    print('VideoCallSpeechService: Disposing');
    if (_isListening) {
      _speechService.stopListening();
    }
    _transcriptController.close();
    _soundLevelController.close();
  }
}