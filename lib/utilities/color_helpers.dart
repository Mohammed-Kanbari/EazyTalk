import 'package:flutter/material.dart';

/// Utility functions for working with colors
class ColorHelpers {
  /// Converts a hex color string to a Flutter Color
  static Color hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
  
  /// Generates a lighter version of a color
  static Color lightenColor(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
  
  /// Generates a darker version of a color
  static Color darkenColor(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}