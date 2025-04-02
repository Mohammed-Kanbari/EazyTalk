import 'package:eazytalk/Screens/secondary_screens/chatBot.dart';
import 'package:eazytalk/Screens/secondary_screens/speech-to-text.dart';
import 'package:flutter/material.dart';
import 'package:eazytalk/services/speech/speech_recognition_service.dart';

// Navigation destinations
enum NavigationDestination {
  home,
  chat,
  learnSigns,
  smartTools,
  profile,
  chatbot,
  speechToText,
}

class VoiceNavigationService {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  final GlobalKey<NavigatorState> navigatorKey;

  // Callback to change bottom navigation tab
  final Function(int index)? onChangeTab;

  // Flag to track if listening is active
  bool _isListening = false;

  // Constructor that takes navigator key for global navigation
  VoiceNavigationService({required this.navigatorKey, this.onChangeTab});

  // Start listening for voice commands
  Future<void> startListening() async {
    if (_isListening) return;

    bool available = await _speechService.initialize();
    if (!available) {
      print('Speech recognition not available');
      return;
    }

    _isListening = true;

    await _speechService.startListening(
      onResult: (text) => _processCommand(text),
      onSoundLevelChange: (level) {},
      onStatus: (status) {
        if (status == 'done') {
          _isListening = false;
        }
      },
      // We'll accept both English and Arabic commands
      language: 'en-US,ar-SA', // Support both English and Arabic
    );
  }

  // Stop listening for voice commands
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speechService.stopListening();
    _isListening = false;
  }

  // Process the recognized text for commands
  void _processCommand(String text) {
    final normalizedText = text.toLowerCase().trim();

    // Check if the text contains navigation commands
    NavigationDestination? destination = _detectDestination(normalizedText);

    if (destination != null) {
      _navigateToDestination(destination);
    }
  }

  // Detect which destination is mentioned in the text
  NavigationDestination? _detectDestination(String text) {
    // English commands
    if (text.contains('go to home') || text.contains('open home')) {
      return NavigationDestination.home;
    } else if (text.contains('go to chat') ||
        text.contains('open chat') ||
        text.contains('messages') ||
        text.contains('conversations')) {
      return NavigationDestination.chat;
    } else if (text.contains('learn signs') || text.contains('sign language')) {
      return NavigationDestination.learnSigns;
    } else if (text.contains('tools') || text.contains('smart tools')) {
      return NavigationDestination.smartTools;
    } else if (text.contains('profile') || text.contains('my account')) {
      return NavigationDestination.profile;
    } else if (text.contains('chatbot') ||
        text.contains('ai chat') ||
        text.contains('assistant')) {
      return NavigationDestination.chatbot;
    } else if (text.contains('speech to text') ||
        text.contains('voice to text') ||
        text.contains('transcribe')) {
      return NavigationDestination.speechToText;
    }

    // Arabic commands
    if (text.contains('الذهاب إلى الرئيسية') || text.contains('فتح الرئيسية')) {
      return NavigationDestination.home;
    } else if (text.contains('الذهاب إلى المحادثات') ||
        text.contains('فتح المحادثات') ||
        text.contains('الرسائل') ||
        text.contains('المحادثات')) {
      return NavigationDestination.chat;
    } else if (text.contains('تعلم الإشارات') || text.contains('لغة الإشارة')) {
      return NavigationDestination.learnSigns;
    } else if (text.contains('الأدوات') || text.contains('الأدوات الذكية')) {
      return NavigationDestination.smartTools;
    } else if (text.contains('الملف الشخصي') || text.contains('حسابي')) {
      return NavigationDestination.profile;
    } else if (text.contains('المساعد الذكي') ||
        text.contains('المساعد الاصطناعي') ||
        text.contains('المساعد')) {
      return NavigationDestination.chatbot;
    } else if (text.contains('تحويل الكلام إلى نص') ||
        text.contains('تحويل الصوت إلى نص') ||
        text.contains('النسخ')) {
      return NavigationDestination.speechToText;
    }

    return null;
  }

  // Navigate to the detected destination
  void _navigateToDestination(NavigationDestination destination) {
    switch (destination) {
      case NavigationDestination.home:
        // Change to home tab
        if (onChangeTab != null) onChangeTab!(0);
        break;

      case NavigationDestination.chat:
        // Change to chat tab
        if (onChangeTab != null) onChangeTab!(0);
        break;

      case NavigationDestination.learnSigns:
        // Change to learn signs tab
        if (onChangeTab != null) onChangeTab!(1);
        break;

      case NavigationDestination.smartTools:
        // Change to smart tools tab
        if (onChangeTab != null) onChangeTab!(2);
        break;

      case NavigationDestination.profile:
        // Change to profile tab
        if (onChangeTab != null) onChangeTab!(3);
        break;

      case NavigationDestination.chatbot:
        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => const Chatbot()),
        );
        break;

      case NavigationDestination.speechToText:
        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => const Speech()),
        );
        break;
    }
    stopListening();
  }
}
