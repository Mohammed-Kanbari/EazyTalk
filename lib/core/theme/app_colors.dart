import 'package:flutter/material.dart';
import 'package:eazytalk/services/theme/theme_service.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF00D0FF);
  static const Color primaryDark = Color(0xFF0088FF);

  // Background colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFF1F3F5);
  
  // Dark theme background colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkBackgroundGrey = Color(0xFF2A2A2A);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Text colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF787579);
  
  // Dark theme text colors
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFAAAAAA);

  // UI element colors
  static const Color iconGrey = Color(0xFFC7C7C7);
  static const Color darkIconGrey = Color(0xFF8A8A8A);

  static const Color wordCardBackground = Color(0xFFB1EEFF);
  static const Color defaultSectionColor = Color(0xFFE6DAFF);
  
  // Dark theme variants
  static const Color darkWordCardBackground = Color(0xFF0A536B);
  static const Color darkDefaultSectionColor = Color(0xFF3A2E69);

  static const Color dividerColor = Color(0xFFE8E8E8);
  static const Color darkDividerColor = Color(0xFF323232);
  
  static const Color placeholderText = Color(0xFF9E9E9E);
  static const Color menuTextColor = Color(0xFF333333);
  static const Color userEmailColor = Color(0xFF706E71);
  static const Color instructionBackground = Color(0xFFE8F8FC);
  static const Color instructionBorder = Color(0xFFCCEEF5);
  
  static const Color darkPlaceholderText = Color(0xFF676767);
  static const Color darkMenuTextColor = Color(0xFFBBBBBB);
  static const Color darkUserEmailColor = Color(0xFFACACAC);
  static const Color darkInstructionBackground = Color(0xFF0A3A42);
  static const Color darkInstructionBorder = Color(0xFF085F6B);
  
  // Helper methods to get theme-aware colors
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : background;
  }
  
  static Color getBackgroundGreyColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackgroundGrey
        : backgroundGrey;
  }
  
  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : textPrimary;
  }
  
  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : textSecondary;
  }
  
  static Color getIconGreyColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkIconGrey
        : iconGrey;
  }
  
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkDividerColor
        : dividerColor;
  }
  
  static Color getWordCardBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkWordCardBackground
        : wordCardBackground;
  }
  
  static Color getDefaultSectionColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkDefaultSectionColor
        : defaultSectionColor;
  }
  
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : Colors.white;
  }
}