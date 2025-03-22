import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/widgets/media/media_picker_option.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class MediaPickerService {
  final ImagePicker _picker = ImagePicker();
  
  // Show media picker options in a modal bottom sheet
  Future<void> showMediaPickerOptions(
    BuildContext context, {
    required Function(File file, bool isVideo, VideoPlayerController? controller) onMediaSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add a Sign',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20.h),

              // Camera options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MediaPickerOption(
                    icon: Icons.camera_alt,
                    title: 'Take Photo',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(
                        ImageSource.camera, 
                        onMediaSelected: onMediaSelected,
                      );
                    },
                  ),
                  MediaPickerOption(
                    icon: Icons.videocam,
                    title: 'Record Video',
                    onTap: () {
                      Navigator.pop(context);
                      _pickVideo(
                        ImageSource.camera, 
                        onMediaSelected: onMediaSelected,
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Gallery options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MediaPickerOption(
                    icon: Icons.photo_library,
                    title: 'Gallery Photo',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(
                        ImageSource.gallery, 
                        onMediaSelected: onMediaSelected,
                      );
                    },
                  ),
                  MediaPickerOption(
                    icon: Icons.video_library,
                    title: 'Gallery Video',
                    onTap: () {
                      Navigator.pop(context);
                      _pickVideo(
                        ImageSource.gallery, 
                        onMediaSelected: onMediaSelected,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Pick image from gallery or camera
  Future<void> _pickImage(
    ImageSource source, {
    required Function(File file, bool isVideo, VideoPlayerController? controller) onMediaSelected,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        onMediaSelected(File(pickedFile.path), false, null);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Pick video from gallery or camera
  Future<void> _pickVideo(
    ImageSource source, {
    required Function(File file, bool isVideo, VideoPlayerController? controller) onMediaSelected,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 10), // Limit video length
      );

      if (pickedFile != null) {
        final videoFile = File(pickedFile.path);

        // Initialize video controller
        final videoController = VideoPlayerController.file(videoFile);
        await videoController.initialize();
        
        onMediaSelected(videoFile, true, videoController);
      }
    } catch (e) {
      print('Error picking video: $e');
    }
  }
}