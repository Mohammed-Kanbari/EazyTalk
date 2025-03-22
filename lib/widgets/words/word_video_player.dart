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
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      // Add listener to video controller to update UI when video state changes
      widget.controller!.addListener(_videoListener);
    }
  }

  @override
  void didUpdateWidget(WordVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_videoListener);
      widget.controller?.addListener(_videoListener);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_videoListener);
    super.dispose();
  }

  void _videoListener() {
    if (mounted) {
      // Update UI when video playback state changes
      setState(() {});
    }
  }

  // Toggle show/hide controls
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

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
        child: GestureDetector(
          onTap: _toggleControls, // Show/hide controls on tap
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Show video player if initialized, otherwise show placeholder
              widget.isInitialized && widget.controller != null
                  ? AspectRatio(
                      aspectRatio: widget.controller!.value.aspectRatio,
                      child: VideoPlayer(widget.controller!),
                    )
                  : _buildVideoPlaceholder(),
                  
              // Play/Pause button overlay - show based on control visibility state
              if (widget.controller != null && widget.isInitialized && _showControls)
                _buildPlayPauseButton(),
                
              // Progress indicator at bottom of video
              if (widget.controller != null && widget.isInitialized)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 5.h,
                    child: VideoProgressIndicator(
                      widget.controller!,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: AppColors.primary.withOpacity(0.3),
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
            ],
          ),
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
      child: Container(
        width: 60.h,
        height: 60.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            widget.controller!.value.isPlaying
                ? Icons.pause
                : Icons.play_arrow,
            color: AppColors.primary,
            size: 40.sp,
          ),
          onPressed: () {
            setState(() {
              if (widget.controller!.value.isPlaying) {
                widget.controller!.pause();
              } else {
                widget.controller!.play();
                
                // Hide controls after short delay when playing starts
                Future.delayed(Duration(seconds: 2), () {
                  if (mounted && widget.controller!.value.isPlaying) {
                    setState(() {
                      _showControls = false;
                    });
                  }
                });
              }
            });
          },
        ),
      ),
    );
  }
}