import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  // Key for saving theme preference
  static const String _themeKey = 'isDarkMode';
  
  // Default to light theme
  static bool _isDarkMode = false;
  
  // Getter for current theme mode
  static bool get isDarkMode => _isDarkMode;
  
  // Stream controller for theme changes
  static final ValueNotifier<ThemeMode> themeNotifier = 
      ValueNotifier(ThemeMode.light);
      
  // Initialize theme from shared preferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    
    // Set initial theme mode
    themeNotifier.value = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
  
  // Toggle theme mode
  static Future<bool> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    
    // Update theme notifier
    themeNotifier.value = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    
    return _isDarkMode;
  }
  
  // Get current theme mode
  static ThemeMode getThemeMode() {
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}