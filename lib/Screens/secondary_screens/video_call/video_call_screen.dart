// lib/Screens/secondary_screens/video_call/video_call_screen.dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:eazytalk/Services/video_call/call_service.dart';
import 'package:eazytalk/Services/video_call/video_call_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/constants/agora_constants.dart';
import 'package:eazytalk/models/call_model.dart';
import 'package:eazytalk/widgets/video_call/call_controls.dart';
import 'package:eazytalk/widgets/video_call/caller_info.dart';

class VideoCallScreen extends StatefulWidget {
  final CallModel call;
  final bool isIncoming;

  const VideoCallScreen({
    Key? key,
    required this.call,
    this.isIncoming = false,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final VideoCallService _videoCallService = VideoCallService();
  final CallService _callService = CallService();

  // State variables
  bool _isMicOn = true;
  bool _isVideoOn = true;
  bool _isLoading = false;
  bool _isConnecting = true;
  bool _isCallEnded = false;

  // Remote user ID
  int? _remoteUid;

  @override
  void initState() {
    super.initState();
    _isVideoOn = widget.call.isVideoEnabled;
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    setState(() {
      _isLoading = true;
      _isConnecting = true;
    });

    try {
      // Initialize the Agora engine
      final initialized = await _videoCallService.initialize();

      if (!initialized) {
        _showError('Failed to initialize video call');
        return;
      }

      // Join the channel
      await _videoCallService.joinChannel(
        channelName: widget.call.channelName,
        token: AgoraConstants.tempToken,
        enabledVideo: _isVideoOn,
        onUserJoined: (connection, uid, elapsed) {
          // Handle remote user joined
          setState(() {
            _remoteUid = uid;
            _isConnecting = false;
          });
        },
        onUserOffline: (connection, uid, reason) {
          // Handle remote user left
          setState(() {
            _remoteUid = null;
            if (reason == UserOfflineReasonType.userOfflineQuit) {
              _endCall();
            } else {
              _isConnecting = true;
            }
          });
        },
      );

      // Update call status if this is an incoming call that was just accepted
      if (widget.isIncoming) {
        await _callService.acceptCall(widget.call.id);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing call: $e');
      _showError('Error setting up the call');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Toggle microphone
  Future<void> _toggleMic() async {
    setState(() {
      _isMicOn = !_isMicOn;
    });

    await _videoCallService.toggleMicrophone(_isMicOn);
  }

  // Toggle video
  Future<void> _toggleVideo() async {
    setState(() {
      _isVideoOn = !_isVideoOn;
    });

    await _videoCallService.toggleVideo(_isVideoOn);
  }

  // Switch camera
  Future<void> _switchCamera() async {
    await _videoCallService.switchCamera();
  }

  // End the call
  Future<void> _endCall() async {
    if (_isCallEnded) return;

    setState(() {
      _isLoading = true;
      _isCallEnded = true;
    });

    try {
      // Update call status in Firestore
      await _callService.endCall(widget.call.id);

      // Leave the channel
      await _videoCallService.leaveChannel();

      // Close the screen
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error ending call: $e');
      _showError('Error ending call');

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    // Make sure to end the call if the screen is closed
    if (!_isCallEnded) {
      _callService.endCall(widget.call.id);
      _videoCallService.leaveChannel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [const Color(0xFF121212), const Color(0xFF000000)]
                    : [Colors.blue.shade900, Colors.black],
              ),
            ),
          ),

          // Remote video view or connecting message
          _buildMainContent(isDarkMode),

          // Local video view
          if (!_isConnecting && _isVideoOn)
            Positioned(
              top: 40.h,
              right: 20.w,
              child: Container(
                width: 120.w,
                height: 180.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                clipBehavior: Clip.hardEdge,
                child: _buildLocalVideoView(),
              ),
            ),

          // Call controls at the bottom
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: CallControls(
                isMicOn: _isMicOn,
                isVideoOn: _isVideoOn,
                onToggleMic: _toggleMic,
                onToggleVideo: _toggleVideo,
                onSwitchCamera: _switchCamera,
                onEndCall: _endCall,
                isLoading: _isLoading,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDarkMode) {
    if (_isConnecting) {
      // Show connecting UI with caller info
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CallerInfo(
              name: widget.isIncoming
                  ? widget.call.callerName
                  : widget.call.receiverName,
              profileImageBase64: widget.isIncoming
                  ? widget.call.callerProfileImageBase64
                  : widget.call.receiverProfileImageBase64,
              statusText: 'Connecting...',
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 24.h),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      );
    } else if (_remoteUid != null) {
      // Show remote video when connected
      return Center(
        child: _buildRemoteVideoView(),
      );
    } else {
      // Fallback - should not happen but just in case
      return Center(
        child: Text(
          'Waiting for other user to join...',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'DM Sans',
            fontSize: 18.sp,
          ),
        ),
      );
    }
  }

  // Build the remote user's video view
  Widget _buildRemoteVideoView() {
    if (_remoteUid == null) return Container();

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _videoCallService.engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.call.channelName),
        ),
      ),
    );
  }

  // Build the local user's video view
  Widget _buildLocalVideoView() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _videoCallService.engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }
}
