import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:eazytalk/core/theme/app_colors.dart';

class SoundWavePainter extends CustomPainter {
  final double soundLevel;
  final Color color;
  
  SoundWavePainter({
    required this.soundLevel, 
    this.color = const Color(0xFF00D0FF),
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Draw multiple perfect circles with varying sizes based on sound level
    for (int i = 0; i < 3; i++) {
      // Vary the opacity based on the wave number
      final opacity = math.max(0.05, 0.3 - (i * 0.05));
      
      // Calculate wave radius based on sound level
      final waveRadius = radius * (0.7 + (i * 0.15)) * (0.8 + (soundLevel * 0.3));
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      // Draw perfect circle
      canvas.drawCircle(center, waveRadius, paint);
    }
  }
  
  @override
  bool shouldRepaint(SoundWavePainter oldDelegate) => 
      oldDelegate.soundLevel != soundLevel;
}