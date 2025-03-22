import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:eazytalk/core/theme/app_colors.dart';

class MediaPreview extends StatelessWidget {
  final File? mediaFile;
  final bool isVideo;
  final VideoPlayerController? videoController;
  final bool isVideoInitialized;
  final VoidCallback onTap;
  
  const MediaPreview({
    Key? key,
    this.mediaFile,
    this.isVideo = false,
    this.videoController,
    this.isVideoInitialized = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200.h,
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
          ),
        ),
        child: _buildPreviewContent(),
      ),
    );
  }
  
  Widget _buildPreviewContent() {
    if (mediaFile == null) {
      return _buildPlaceholder();
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: isVideo
            ? _buildVideoPreview()
            : Image.file(
                mediaFile!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
      );
    }
  }
  
  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          color: AppColors.primary,
          size: 40.sp,
        ),
        SizedBox(height: 12.h),
        Text(
          'Tap to add a photo or video',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14.sp,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Show the sign clearly in good lighting',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12.sp,
            color: Colors.black38,
          ),
        ),
      ],
    );
  }
  
  Widget _buildVideoPreview() {
    if (!isVideoInitialized || videoController == null) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }
    
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: videoController!.value.aspectRatio,
          child: VideoPlayer(videoController!),
        ),
        IconButton(
          icon: Icon(
            videoController!.value.isPlaying
                ? Icons.pause
                : Icons.play_arrow,
            color: Colors.white,
            size: 40.sp,
          ),
          onPressed: () {
            if (videoController!.value.isPlaying) {
              videoController!.pause();
            } else {
              videoController!.play();
            }
          },
        ),
      ],
    );
  }
}