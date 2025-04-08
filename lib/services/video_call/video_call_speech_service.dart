import 'dart:async';
import 'package:eazytalk/services/speech/speech_recognition_service.dart';
import 'package:flutter/material.dart';

/// Service to manage speech-to-text functionality during video calls
class VideoCallSpeechService {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  
  // State variables
  bool _isInitialized = false;
  bool _isListening = false;
  String _transcribedText = '';
  double _soundLevel = 0.0;
  
  // Controller for transcript updates
  final StreamController<String> _transcriptController = StreamController<String>.broadcast();
  Stream<String> get transcriptStream => _transcriptController.stream;
  
  // Controller for sound level updates (for visualization)
  final StreamController<double> _soundLevelController = StreamController<double>.broadcast();
  Stream<double> get soundLevelStream => _soundLevelController.stream;
  
  // Getters for state
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get transcribedText => _transcribedText;

  // Initialize the speech service
  Future<bool> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speechService.initialize();
    }
    return _isInitialized;
  }

  // Start speech recognition
Future<bool> startListening({String language = 'en-US'}) async {
  if (_isListening) return true;
  
  if (!_isInitialized) {
    await initialize();
  }
  
  if (!_isInitialized) {
    return false;
  }
  
  try {
    // Define the status handler function that can be reused
    void handleStatus(String status) {
      if (status == 'done' && _isListening) {
        // Save the current text
        final accumulatedText = _transcribedText;
        
        // Restart listening after a brief delay to prevent immediate stopping
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_isListening) {
            _startListeningInternal(
              accumulatedText: accumulatedText,
              language: language,
              statusHandler: handleStatus,
            );
          }
        });
      }
    }
    
    // Start the initial listening session
    await _startListeningInternal(
      language: language,
      statusHandler: handleStatus,
    );
    
    _isListening = true;
    return true;
  } catch (e) {
    print('Error starting speech recognition: $e');
    return false;
  }
}
  
  // Internal method to handle the actual listening logic
  Future<void> _startListeningInternal({
    String accumulatedText = '',
    required String language,
    required Function(String) statusHandler,
  }) async {
    await _speechService.startListening(
      onResult: (text) {
        _transcribedText = text;
        _transcriptController.add(text);
      },
      onSoundLevelChange: (level) {
        _soundLevel = level;
        _soundLevelController.add(level);
      },
      onStatus: statusHandler,
      accumulatedText: accumulatedText,
      pauseTimeout: const Duration(seconds: 5), // Short timeout for video calls
      language: language,
    );
  }

  // Stop speech recognition
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    await _speechService.stopListening();
    _isListening = false;
    
    // Clear the transcript when stopping
    _transcribedText = '';
    _transcriptController.add('');
  }
  
  // Reset the transcript
  void clearTranscript() {
    _transcribedText = '';
    _transcriptController.add('');
  }
  
  // Clean up resources
  void dispose() {
    if (_isListening) {
      _speechService.stopListening();
    }
    _transcriptController.close();
    _soundLevelController.close();
  }
}