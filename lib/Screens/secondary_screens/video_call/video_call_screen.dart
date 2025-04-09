import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:eazytalk/Services/video_call/call_service.dart';
import 'package:eazytalk/Services/video_call/video_call_service.dart';
import 'package:eazytalk/Services/video_call/video_call_speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/constants/agora_constants.dart';
import 'package:eazytalk/models/call_model.dart';
import 'package:eazytalk/widgets/video_call/call_controls.dart';
import 'package:eazytalk/widgets/video_call/caller_info.dart';
import 'package:eazytalk/widgets/video_call/transcript_overlay.dart';
import 'package:eazytalk/widgets/video_call/language_selector.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

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
  final VideoCallSpeechService _speechService = VideoCallSpeechService();

  // State variables
  bool _isMicOn = true;
  bool _isVideoOn = true;
  bool _isSpeechToTextOn = false;
  bool _isLoading = false;
  bool _isConnecting = true;
  bool _isCallEnded = false;

  // Remote user ID
  int? _remoteUid;
  
  // Speech-to-text state
  String _localTranscript = '';
  String _remoteTranscript = '';
  String _preferredLanguage = 'en-US'; // Default language

  
  // Stream subscriptions
  late StreamSubscription<CallModel?> _callStreamSubscription;
  StreamSubscription<String>? _transcriptSubscription;

  @override
  void initState() {
    super.initState();
    _isVideoOn = widget.call.isVideoEnabled;

     _isSpeechToTextOn = widget.call.speechToTextStatus?[_callService.currentUserId] ?? false;
    
    // Listen to changes in the call document
    _callStreamSubscription = _callService
        .callStream(widget.call.id)
        .listen(_handleCallUpdates);
    
    // Initialize the video call
    _initializeCall();
    
    // Initialize speech service if speech-to-text is enabled
    if (_isSpeechToTextOn) {
      _initializeSpeechToText();
    }

    // In VideoCallScreen's initState
// Listen to transcript updates and share them
_transcriptSubscription = _speechService.transcriptStream.listen((transcript) {
  //it is entering here when the other phone is clicking tospeeach text
  //the problem is here 
  //they speech text is connected
  if (mounted) {
    setState(() {
      _localTranscript = transcript;
    });
    
    // Share transcript with remote user
    if (transcript.isNotEmpty && _isMicOn) {
      _callService.updateTranscript(
        widget.call.id,
        _callService.currentUserId,
        transcript
      );
    }
  }
});

// Listen for remote transcript updates
_callStreamSubscription = _callService
  .callStream(widget.call.id)
  .listen((updatedCall) {
    if (updatedCall == null || !mounted) return;
    
    // Get remote user's transcript
    final remoteUserId = updatedCall.participants
        .firstWhere((id) => id != _callService.currentUserId, orElse: () => '');
    
    if (remoteUserId.isNotEmpty) {
      final remoteTranscript = updatedCall.transcripts?[remoteUserId] ?? '';
      
      setState(() {
        _remoteTranscript = remoteTranscript;
      });
    }
    
    // Other call updates handling...
  });
  }
  
  // Handle updates to the call document in Firestore
void _handleCallUpdates(CallModel? updatedCall) {
  if (updatedCall == null || !mounted) return;
  
  // Get current user's speech-to-text status
  final userSttEnabled = updatedCall.speechToTextStatus?[_callService.currentUserId] ?? false;
  
  // Check if the current user's speech-to-text setting has changed
  if (userSttEnabled != _isSpeechToTextOn) {
    setState(() {
      _isSpeechToTextOn = userSttEnabled;
    });
    
    // Initialize or stop speech service based on new setting
    if (_isSpeechToTextOn) {
      _initializeSpeechToText();
    } else {
      _stopSpeechToText();
    }
  }
  
  // Handle language changes as before
  if (updatedCall.preferredLanguage != _preferredLanguage) {
    setState(() {
      _preferredLanguage = updatedCall.preferredLanguage;
    });
    
    // Restart speech recognition with new language if active
    if (_isSpeechToTextOn) {
      _stopSpeechToText();
      _initializeSpeechToText();
    }
  }
  
  // Get remote user's transcript
  final remoteUserId = updatedCall.participants
      .firstWhere((id) => id != _callService.currentUserId, orElse: () => '');
  
  if (remoteUserId.isNotEmpty) {
    final remoteTranscript = updatedCall.transcripts?[remoteUserId] ?? '';
    
    setState(() {
      _remoteTranscript = remoteTranscript;
    });
  }
}

// In VideoCallScreen
Future<void> _changeLanguage(String language) async {
  // Update state immediately for UI responsiveness
  setState(() {
    _preferredLanguage = language;
  });
  
  // Update in Firestore
  await _callService.updateCallLanguage(widget.call.id, language);
  
  // Restart speech recognition with new language
  if (_isSpeechToTextOn && _isMicOn) {
    await _speechService.stopListening();
    await _speechService.startListening(language: language);
  }
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
  
  // Initialize the speech-to-text service
  Future<void> _initializeSpeechToText() async {
    try {
      final initialized = await _speechService.initialize();
      
      if (initialized) {
        // Start listening only if mic is on
        if (_isMicOn) {
          await _speechService.startListening(
            language: _preferredLanguage,
          );
        }
        
        // Listen to transcript updates
        _transcriptSubscription = _speechService.transcriptStream.listen((transcript) {
          if (mounted) {
            setState(() {
              _localTranscript = transcript;
            });
            
            // Share transcript with remote user
            if (transcript.isNotEmpty) {
              _callService.updateTranscript(
                widget.call.id,
                _callService.currentUserId,
                transcript
              );
            }
          }
        });
      } else {
        _showError('Failed to initialize speech recognition');
      }
    } catch (e) {
      print('Error initializing speech-to-text: $e');
    }
  }
  
  // Stop the speech-to-text service
  void _stopSpeechToText() {
    _speechService.stopListening();
    _transcriptSubscription?.cancel();
    _transcriptSubscription = null;
    
    setState(() {
      _localTranscript = '';
      _remoteTranscript = '';
    });
  }

 // In VideoCallScreen
Future<void> _toggleMic() async {
  setState(() {
    _isMicOn = !_isMicOn;
  });

  await _videoCallService.toggleMicrophone(_isMicOn);
  
  // Link with speech service
  if (_isSpeechToTextOn) {
    if (_isMicOn) {
      // Resume speech recognition if mic is turned on
      await _speechService.startListening(language: _preferredLanguage);
    } else {
      // Pause speech recognition if mic is turned off
      await _speechService.stopListening();
    }
  }
}

  // Toggle video
  Future<void> _toggleVideo() async {
    setState(() {
      _isVideoOn = !_isVideoOn;
    });

    await _videoCallService.toggleVideo(_isVideoOn);
  }
  
  // Toggle speech-to-text
Future<void> _toggleSpeechToText() async {
  final newState = !_isSpeechToTextOn;
  
  // Update state optimistically for better UX
  setState(() {
    _isSpeechToTextOn = newState;
  });
  
  // Update in Firestore - pass the current user's ID
  final success = await _callService.toggleSpeechToText(
    widget.call.id,
    newState,
    _callService.currentUserId// Pass the current user's ID
  );
  
  if (!success) {
    // Revert if failed
    setState(() {
      _isSpeechToTextOn = !newState;
    });
    _showError('Failed to toggle speech-to-text');
    return;
  }
  
  if (newState) {
    // Start speech-to-text
    await _initializeSpeechToText();
  } else {
    // Stop speech-to-text
    _stopSpeechToText();
  }
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
      // Stop speech-to-text if active
      if (_isSpeechToTextOn) {
        _stopSpeechToText();
      }
      
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
    // Clean up all resources
    _callStreamSubscription.cancel();
    
    if (_isSpeechToTextOn) {
      _stopSpeechToText();
    }
    
    _speechService.dispose();
    
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
    final localizations = AppLocalizations.of(context);

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
          _buildMainContent(isDarkMode, localizations),

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
          
          // Speech-to-text transcript for remote user
          if (_isSpeechToTextOn && _remoteTranscript.isNotEmpty)
            Positioned(
              top: 230.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _remoteTranscript,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            
          // Speech-to-text toggle and transcript for local user
          TranscriptOverlay(
            transcript: _localTranscript,
            isActive: _isSpeechToTextOn,
            onToggle: (enabled) => _toggleSpeechToText(),
            isLocalUser: true,
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
                isSpeechToTextOn: _isSpeechToTextOn,
                onToggleMic: _toggleMic,
                onToggleVideo: _toggleVideo,
                onToggleSpeechToText: _toggleSpeechToText,
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

  Widget _buildMainContent(bool isDarkMode, AppLocalizations localizations) {
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
              statusText: localizations.translate('connecting'),
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
          localizations.translate('waiting_user_join'),
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