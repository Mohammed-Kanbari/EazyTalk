// lib/core/constants/agora_constants.dart
class AgoraConstants {
  // Your Agora App ID - replace with your actual App ID from Agora Console
  static const String appId = '8b9958b702cd4613b4bc86cc15e8536e';
  
  // Default channel name when starting a new call
  static const String defaultChannel = 'eazytalk_channel';
  
  // Default token - for development/testing only
  // In production, you should use a token server to generate secure tokens
  static const String? tempToken = null; // Set to null for testing without token
  
  // Video call configuration
  static const int defaultUID = 0; // 0 means random UID will be assigned by Agora
  static const bool enabledAudio = true; // Enable audio by default
  static const bool enabledVideo = true; // Enable video by default
}