import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SignLanguageRecognitionService {
  // Singleton pattern
  static final SignLanguageRecognitionService _instance = SignLanguageRecognitionService._internal();

  factory SignLanguageRecognitionService() {
    return _instance;
  }

  SignLanguageRecognitionService._internal();

  // Camera controller
  CameraController? _cameraController;
  
  // Status variables
  bool _isInitialized = false;
  bool _isRecognizing = false;
  
  // Recognition results
  final ValueNotifier<String> recognitionResult = ValueNotifier<String>('');
  
  // Frame processing rate control
  DateTime _lastProcessedTimestamp = DateTime.now();
  final Duration _processingInterval = Duration(milliseconds: 300); // Process frames every 300ms
  
  // Stream controller for camera images
  StreamSubscription<CameraImage>? _imageStreamSubscription;
  
  // Getters for status
  bool get isInitialized => _isInitialized;
  bool get isRecognizing => _isRecognizing;
  CameraController? get cameraController => _cameraController;

  // Initialize the camera
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) return false;
      
      // Initialize with front camera if available, otherwise use back camera
      final frontCameras = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.front
      ).toList();
      
      final selectedCamera = frontCameras.isNotEmpty ? frontCameras.first : cameras.first;
      
      // Create and initialize camera controller
      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await _cameraController!.initialize();
      
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing camera: $e');
      return false;
    }
  }
  
  // Start sign language recognition
  Future<bool> startRecognition() async {
    if (!_isInitialized || _isRecognizing) return false;
    
    try {
      // Start image stream
      _imageStreamSubscription = _cameraController!.startImageStream(_processImage) as StreamSubscription<CameraImage>;
      
      _isRecognizing = true;
      return true;
    } catch (e) {
      print('Error starting recognition: $e');
      return false;
    }
  }
  
  // Stop sign language recognition
  Future<void> stopRecognition() async {
    if (!_isRecognizing) return;
    
    try {
      // Stop image stream
      await _imageStreamSubscription?.cancel();
      _imageStreamSubscription = null;
      
      // Clear recognition result
      recognitionResult.value = '';
      
      _isRecognizing = false;
    } catch (e) {
      print('Error stopping recognition: $e');
    }
  }
  
  // Process camera image
  void _processImage(CameraImage image) {
    // Rate limiting to avoid excessive processing
    final now = DateTime.now();
    if (now.difference(_lastProcessedTimestamp) < _processingInterval) {
      return;
    }
    _lastProcessedTimestamp = now;
    
    // In a real implementation, we would:
    // 1. Convert the image to a format suitable for ML processing
    // 2. Run the image through a sign language recognition model
    // 3. Interpret the results
    
    // For this prototype, we'll simulate random recognition results
    _simulateRecognition();
  }
  
  // Simulated recognition results for demo purposes
  void _simulateRecognition() {
    // In a real implementation, this would be replaced with actual ML inference
    // This is just for demonstration
    
    final phrases = [
      'Hello',
      'Thank you',
      'How are you?',
      'Nice to meet you',
      'Good morning',
      'Please',
      'Yes',
      'No',
      'Help me',
      'I understand'
    ];
    
    // Randomly select phrases with some probability
    // Most of the time, return no result to simulate processing
    if (DateTime.now().millisecond % 10 == 0) {
      final randomIndex = DateTime.now().millisecond % phrases.length;
      recognitionResult.value = phrases[randomIndex];
    }
  }
  
  // Switch camera (front/back)
  Future<bool> switchCamera() async {
    if (!_isInitialized) return false;
    
    final wasRecognizing = _isRecognizing;
    
    // Stop recognition if active
    if (wasRecognizing) {
      await stopRecognition();
    }
    
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.length < 2) return false;
      
      // Determine current camera direction
      final currentDirection = _cameraController!.description.lensDirection;
      
      // Select opposite direction
      final newDirection = currentDirection == CameraLensDirection.front
          ? CameraLensDirection.back
          : CameraLensDirection.front;
          
      // Find camera with the opposite direction
      final newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == newDirection,
        orElse: () => cameras.first, // Fallback to first camera if not found
      );
      
      // Dispose current controller
      await _cameraController?.dispose();
      _cameraController = null;
      
      // Create new controller with the selected camera
      _cameraController = CameraController(
        newCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await _cameraController!.initialize();
      
      // Restart recognition if it was active
      if (wasRecognizing) {
        await startRecognition();
      }
      
      return true;
    } catch (e) {
      print('Error switching camera: $e');
      return false;
    }
  }
  
  // Dispose resources
  Future<void> dispose() async {
    await stopRecognition();
    await _cameraController?.dispose();
    _cameraController = null;
    _isInitialized = false;
  }
}