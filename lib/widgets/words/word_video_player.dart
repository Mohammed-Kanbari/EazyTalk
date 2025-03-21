import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class WordVideoPlayer extends StatefulWidget {
  final VideoPlayerController? controller;
  final bool isInitialized;
  
  const WordVideoPlayer({
    Key? key,
    required this.controller,
    required this.isInitialized,
  }) : super(key: key);
  
  @override
  State<WordVideoPlayer> createState() => _WordVideoPlayerState();
}

class _WordVideoPlayerState extends State<WordVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Show video player if initialized, otherwise show placeholder
            widget.isInitialized && widget.controller != null
                ? VideoPlayer(widget.controller!)
                : _buildVideoPlaceholder(),
                
            // Play/Pause button overlay
            if (widget.controller != null && widget.isInitialized)
              _buildPlayPauseButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVideoPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam,
            size: 60.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 12.h),
          Text(
            'Video coming soon',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16.sp,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlayPauseButton() {
    return Center(
      child: widget.controller!.value.isPlaying
          ? SizedBox.shrink() // No visible button when playing
          : GestureDetector(
              onTap: () {
                setState(() {
                  widget.controller!.play();
                });
              },
              child: Container(
                width: 60.h,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: AppColors.primary,
                  size: 40.sp,
                ),
              ),
            ),
    );
  }
}