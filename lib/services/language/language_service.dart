import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  // Key for storing language preference
  static const String _languageKey = 'language_code';
  
  // Default language is English
  static String _currentLanguage = 'en';
  
  // Supported languages
  static const Map<String, String> availableLanguages = {
    'en': 'English',
    'ar': 'العربية',
  };
  
  // Stream controller for language changes
  static final ValueNotifier<Locale> localeNotifier = 
      ValueNotifier(Locale(_currentLanguage));
      
  // Initialize language from shared preferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? 'en';
    
    // Update locale notifier
    localeNotifier.value = Locale(_currentLanguage);
  }
  
  // Get current language code
  static String getCurrentLanguage() {
    return _currentLanguage;
  }
  
  // Check if current language is RTL
  static bool isRtl() {
    return _currentLanguage == 'ar';
  }
  
  // Toggle between supported languages
  static Future<String> toggleLanguage() async {
    // Switch between English and Arabic
    _currentLanguage = _currentLanguage == 'en' ? 'ar' : 'en';
    
    // Update locale notifier
    localeNotifier.value = Locale(_currentLanguage);
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, _currentLanguage);
    
    return _currentLanguage;
  }
  
  // Set language to specific code
  static Future<String> setLanguage(String languageCode) async {
    if (availableLanguages.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      
      // Update locale notifier
      localeNotifier.value = Locale(_currentLanguage);
      
      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, _currentLanguage);
    }
    
    return _currentLanguage;
  }
}