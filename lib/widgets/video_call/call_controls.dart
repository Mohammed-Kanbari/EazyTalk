// lib/widgets/video_call/call_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class CallControls extends StatelessWidget {
  final bool isMicOn;
  final bool isVideoOn;
  final bool isSpeechToTextOn;  // New parameter for speech-to-text
  final VoidCallback onToggleMic;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleSpeechToText;  // New callback for speech-to-text
  final VoidCallback onSwitchCamera;
  final VoidCallback onEndCall;
  final bool isLoading;
  final bool isDarkMode;
  
  const CallControls({
    Key? key,
    required this.isMicOn,
    required this.isVideoOn,
    this.isSpeechToTextOn = false,
    required this.onToggleMic,
    required this.onToggleVideo,
    required this.onToggleSpeechToText,
    required this.onSwitchCamera,
    required this.onEndCall,
    this.isLoading = false,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black54 : Colors.white54,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mic toggle button
          _buildControlButton(
            icon: isMicOn ? Icons.mic : Icons.mic_off,
            onPressed: onToggleMic,
            backgroundColor: isMicOn 
                ? Colors.transparent
                : Colors.red.withOpacity(0.8),
            isEnabled: isMicOn,
          ),
          
          SizedBox(width: 12.w),
          
          // Video toggle button
          _buildControlButton(
            icon: isVideoOn ? Icons.videocam : Icons.videocam_off,
            onPressed: onToggleVideo,
            backgroundColor: isVideoOn
                ? Colors.transparent
                : Colors.red.withOpacity(0.8),
            isEnabled: isVideoOn,
          ),
          
          SizedBox(width: 12.w),
          
          // Speech-to-text toggle button
          _buildControlButton(
            icon: isSpeechToTextOn ? Icons.closed_caption : Icons.closed_caption_off,
            onPressed: onToggleSpeechToText,
            backgroundColor: isSpeechToTextOn
                ? AppColors.primary.withOpacity(0.8)
                : Colors.transparent,
            isEnabled: isSpeechToTextOn,
          ),
          
          SizedBox(width: 12.w),
          
          // Switch camera button
          _buildControlButton(
            icon: Icons.switch_camera,
            onPressed: onSwitchCamera,
            backgroundColor: Colors.transparent,
          ),
          
          SizedBox(width: 12.w),
          
          // End call button
          _buildControlButton(
            icon: Icons.call_end,
            onPressed: onEndCall,
            backgroundColor: Colors.red,
            iconColor: Colors.white,
            showLoadingOverlay: isLoading,
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.transparent,
    Color? iconColor,
    bool isEnabled = true,
    bool showLoadingOverlay = false,
  }) {
    final effectiveIconColor = iconColor ?? 
        (isDarkMode ? Colors.white : Colors.black);
    
    return Container(
      width: 46.h,
      height: 46.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDarkMode ? Colors.white30 : Colors.black12,
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(
              icon,
              color: effectiveIconColor,
              size: 22.sp,
            ),
            onPressed: showLoadingOverlay ? null : onPressed,
            padding: EdgeInsets.zero,
          ),
          if (showLoadingOverlay)
            SizedBox(
              width: 24.h,
              height: 24.h,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }
}