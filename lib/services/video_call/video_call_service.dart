// lib/services/video_call/video_call_service.dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eazytalk/core/constants/agora_constants.dart';

class VideoCallService {
  // Singleton pattern
  static final VideoCallService _instance = VideoCallService._internal();

  factory VideoCallService() {
    return _instance;
  }

  VideoCallService._internal();

  // RTC Engine instance
  RtcEngine? _engine;

  // Status variables
  bool _isInitialized = false;
  bool _isJoined = false;

  // Getters for status
  bool get isInitialized => _isInitialized;
  bool get isJoined => _isJoined;
  RtcEngine? get engine => _engine;

  // Initialize the Agora RTC Engine
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Check and request permissions
      if (!await _checkPermissions()) {
        return false;
      }

      // Create and initialize the RTC engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: AgoraConstants.appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      // Set video encoding configuration
      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 360),
          frameRate: 15,
          bitrate: 0, // Let Agora decide the optimal bitrate
          orientationMode: OrientationMode.orientationModeAdaptive,
        ),
      );

      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing Agora RTC Engine: $e');
      return false;
    }
  }

  // Check and request necessary permissions
  Future<bool> _checkPermissions() async {
    // Request camera and microphone permissions
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    return cameraStatus.isGranted && microphoneStatus.isGranted;
  }

  // Join a channel
  Future<bool> joinChannel({
    required String channelName,
    String? token,
    int uid = AgoraConstants.defaultUID,
    bool enabledAudio = AgoraConstants.enabledAudio,
    bool enabledVideo = AgoraConstants.enabledVideo,
    required void Function(RtcConnection connection, int remoteUid, int elapsed)
        onUserJoined,
    required void Function(RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason)
        onUserOffline,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      // Set event handlers
      _engine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          _isJoined = true;
          print('Local user joined channel: ${connection.channelId}');
        },
        onLeaveChannel: (connection, stats) {
          _isJoined = false;
          print('Local user left channel: ${connection.channelId}');
        },
        onUserJoined: onUserJoined,
        onUserOffline: onUserOffline,
        onError: (err, msg) {
          print('Agora error: $err, $msg');
        },
      ));

      // Enable video
      if (enabledVideo) {
        await _engine!.enableVideo();
      } else {
        await _engine!.disableVideo();
      }

      // Enable/disable audio
      if (enabledAudio) {
        await _engine!.enableAudio();
      } else {
        await _engine!.disableAudio();
      }

      // Set channel profile and client role
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      // Join the channel
      await _engine!.joinChannel(
        token: token ?? '',
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
      );

      return true;
    } catch (e) {
      print('Error joining channel: $e');
      return false;
    }
  }

  // Leave the current channel
  Future<void> leaveChannel() async {
    if (!_isInitialized || !_isJoined) return;

    try {
      await _engine?.leaveChannel();
      _isJoined = false;
    } catch (e) {
      print('Error leaving channel: $e');
    }
  }

  // Toggle the camera (front/back)
  Future<void> switchCamera() async {
    if (!_isInitialized) return;

    try {
      await _engine?.switchCamera();
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  // Toggle microphone
  Future<void> toggleMicrophone(bool enabled) async {
    if (!_isInitialized) return;

    try {
      if (enabled) {
        await _engine?.enableAudio();
      } else {
        await _engine?.disableAudio();
      }
    } catch (e) {
      print('Error toggling microphone: $e');
    }
  }

  // Toggle video
  Future<void> toggleVideo(bool enabled) async {
    if (!_isInitialized) return;

    try {
      if (enabled) {
        await _engine?.enableVideo();
      } else {
        await _engine?.disableVideo();
      }
    } catch (e) {
      print('Error toggling video: $e');
    }
  }

  // Dispose the RTC Engine
  Future<void> dispose() async {
    if (_isJoined) {
      await leaveChannel();
    }

    await _engine?.release();
    _engine = null;
    _isInitialized = false;
  }
}
