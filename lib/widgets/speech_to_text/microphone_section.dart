import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';
import 'package:eazytalk/widgets/speech_to_text/sound_wave_painter.dart';

class MicrophoneSection extends StatelessWidget {
  final bool isListening;
  final double soundLevel;
  final double maxSoundLevel;
  final VoidCallback onToggleListening;
  final VoidCallback onStopListening;
  final bool isDarkMode;
  
  const MicrophoneSection({
    Key? key,
    required this.isListening,
    required this.soundLevel,
    required this.maxSoundLevel,
    required this.onToggleListening,
    required this.onStopListening,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextPrimaryColor(context);
    final textSecondaryColor = isDarkMode 
        ? Colors.grey[400]
        : AppColors.textSecondary;
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.45,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Tap the mic and start talking — we'll do the typing!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
              color: textSecondaryColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 80.w),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Sound wave animations - only visible when listening
                  if (isListening) ...[
                    // Static background ripples
                    for (int i = 1; i <= 2; i++)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: (1000 + (i * 300)).toInt()),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: (1 - value).clamp(0.0, 0.5),
                            child: Transform.scale(
                              scale: 1 + (value * 0.5),
                              child: Container(
                                width: 120.w,
                                height: 120.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                            ),
                          );
                        },
                        key: ValueKey('static_ripple_$i'),
                      ),
                    
                    // Dynamic sound level-based ripples
                    _buildSoundWaves(),
                  ],
                  
                  // Main mic button
                  GestureDetector(
                    onTap: onToggleListening,
                    child: Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 25.w),
              IconButton(
                icon: Icon(
                  Icons.stop,
                  size: 28.w,
                  color: isListening 
                      ? Colors.red 
                      : (isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                ),
                onPressed: isListening ? onStopListening : null,
              ),
            ],
          ),
          Text(
            isListening ? 'Listening' : '',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 20.sp,
              color: textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build sound wave visualization based on current sound level
  Widget _buildSoundWaves() {
    // Normalize sound level for visualization
    // If max level is too small, use a default value
    double normalizedLevel = maxSoundLevel > 0.1 
        ? (soundLevel / maxSoundLevel).clamp(0.3, 1.0)
        : 0.5;
    
    return CustomPaint(
      size: Size(200.w, 200.h),
      painter: SoundWavePainter(
        soundLevel: normalizedLevel,
        color: AppColors.primary,
      ),
    );
  }
}