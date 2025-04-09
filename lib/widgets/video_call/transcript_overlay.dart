// lib/widgets/video_call/transcript_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

class TranscriptOverlay extends StatelessWidget {
  final String transcript;
  final bool isActive;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onLanguagePress;
  final bool isLocalUser;  // Whether this transcript belongs to the local user
  
  const TranscriptOverlay({
    Key? key,
    required this.transcript,
    required this.isActive,
    required this.onToggle,
    this.onLanguagePress,
    this.isLocalUser = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only show if active and there's a transcript, or when we need to show the toggle
    if (!isActive && transcript.isEmpty) return const SizedBox.shrink();
    
    final l10n = AppLocalizations.of(context);
    
    return Positioned(
      bottom: 120.h,  // Position above call controls
      left: 16.w,
      right: 16.w,
      child: Column(
        crossAxisAlignment: isLocalUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Toggle button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => onToggle(!isActive),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.grey.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? Icons.closed_caption : Icons.closed_caption_off,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isActive ? l10n.translate('captions_on') : l10n.translate('captions_off'),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Language selector button (only shown when captions are on)
              if (isActive && onLanguagePress != null)
                GestureDetector(
                  onTap: onLanguagePress,
                  child: Container(
                    margin: EdgeInsets.only(left: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.language,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          // Transcript text (only shown when active and there's text)
          if (isActive && transcript.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isLocalUser 
                    ? AppColors.primary.withOpacity(0.8) 
                    : Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                transcript,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}