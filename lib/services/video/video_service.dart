import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoService {
  // Initialize a video controller for an asset path
  static Future<VideoPlayerController?> initializeAssetVideo(String? videoPath) async {
    if (videoPath == null || videoPath.isEmpty) {
      return null;
    }
    
    try {
      final controller = VideoPlayerController.asset(videoPath);
      await controller.initialize();
      return controller;
    } catch (e) {
      print("Error initializing video: $e");
      return null;
    }
  }
  
  // Dispose a video controller safely
  static void disposeController(VideoPlayerController? controller) {
    controller?.dispose();
  }
}