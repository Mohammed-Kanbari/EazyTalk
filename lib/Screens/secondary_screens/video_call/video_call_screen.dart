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
  String _preferredLanguage = 'en-US';

  // Stream subscriptions
  late StreamSubscription<CallModel?> _callStreamSubscription;
  StreamSubscription<String>? _transcriptSubscription;

  // NEW: Retry counter for STT initialization
  int _sttRetryCount = 0;
  static const int maxSttRetries = 3;

  @override
  void initState() {
    super.initState();
    _isVideoOn = widget.call.isVideoEnabled;
    _isSpeechToTextOn = widget.call.speechToTextStatus?[_callService.currentUserId] ?? false;
    _preferredLanguage = widget.call.preferredLanguage;

    // Initialize Agora and join channel
    _initializeCall();

    // Set up call stream
    _callStreamSubscription = _callService
        .callStream(widget.call.id)
        .listen(_handleCallUpdates);
  }

Future<void> _initializeCall() async {
  setState(() {
    _isLoading = true;
    _isConnecting = true;
  });

  try {
    // Initialize the Agora engine first
    final initialized = await _videoCallService.initialize();

    if (!initialized || _videoCallService.engine == null) {
      _showError('Failed to initialize video call');
      return;
    }

    // NEW: Disable OpenSL ES using _videoCallService.engine
    await _videoCallService.engine!.setParameters('{"che.audio.opensl.mode": 0}');
    // NEW: Use shared audio mode
    await _videoCallService.engine!.setParameters('{"che.audio.mode": 0}');

    // Join the channel
    await _videoCallService.joinChannel(
      channelName: widget.call.channelName,
      token: AgoraConstants.tempToken,
      enabledVideo: _isVideoOn,
      onUserJoined: (connection, uid, elapsed) {
        setState(() {
          _remoteUid = uid;
          _isConnecting = false;
        });
        // Initialize STT after channel join for non-Huawei devices
        if (_isSpeechToTextOn) {
          _initializeSpeechToText();
        }
      },
      onUserOffline: (connection, uid, reason) {
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

    // Update call status for incoming call
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

Future<void> _initializeSpeechToText() async {
  print('VideoCallScreen: Starting STT initialization...');
  _sttRetryCount = 0;

  try {
    print('VideoCallScreen: Disabling Agora audio...');
    await _videoCallService.engine?.disableAudio();
    await _videoCallService.engine?.muteLocalAudioStream(true); // NEW: Extra mic release
    await Future.delayed(Duration(milliseconds: 2000));

    final initialized = await _speechService.initialize();
    print('VideoCallScreen: STT initialize result: $initialized');

    if (initialized) {
      if (_isMicOn) {
        print('VideoCallScreen: Starting STT listening...');
        await _speechService.startListening(
          language: _preferredLanguage,
          sampleRate: 16000,
        );
      }

      _transcriptSubscription?.cancel();
      _transcriptSubscription = _speechService.transcriptStream.listen(
        (transcript) {
          print('VideoCallScreen: Received transcript: $transcript');
          if (mounted) {
            setState(() {
              _localTranscript = transcript;
            });
            if (transcript.isNotEmpty && _isMicOn) {
              _callService.updateTranscript(
                widget.call.id,
                _callService.currentUserId,
                transcript,
              );
            }
          }
        },
        onError: (error) {
          print('VideoCallScreen: Transcript stream error: $error');
        },
        onDone: () {
          print('VideoCallScreen: Transcript stream closed');
        },
      );
    } else {
      if (_sttRetryCount < maxSttRetries) {
        _sttRetryCount++;
        print('VideoCallScreen: Retrying STT initialization ($_sttRetryCount/$maxSttRetries)...');
        await Future.delayed(Duration(milliseconds: 1000));
        await _initializeSpeechToText();
      } else {
        print('VideoCallScreen: STT failed after $maxSttRetries retries');
        _showError('Failed to initialize speech recognition');
        await _videoCallService.engine?.enableAudio();
        await _videoCallService.engine?.muteLocalAudioStream(false);
      }
    }
  } catch (e) {
    print('VideoCallScreen: STT initialization exception: $e');
    if (_sttRetryCount < maxSttRetries) {
      _sttRetryCount++;
      print('VideoCallScreen: Retrying STT initialization ($_sttRetryCount/$maxSttRetries)...');
      await Future.delayed(Duration(milliseconds: 1000));
      await _initializeSpeechToText();
    } else {
      print('VideoCallScreen: STT failed after $maxSttRetries retries with error: $e');
      _showError('Error setting up speech recognition');
      await _videoCallService.engine?.enableAudio();
      await _videoCallService.engine?.muteLocalAudioStream(false);
    }
  }
}

void _stopSpeechToText() {
  print('VideoCallScreen: Stopping STT...');
  _speechService.stopListening();
  _transcriptSubscription?.cancel();
  _transcriptSubscription = null;
  print('VideoCallScreen: Re-enabling Agora audio...');
  _videoCallService.engine?.enableAudio();
  _videoCallService.engine?.muteLocalAudioStream(false);
  setState(() {
    _localTranscript = '';
    _remoteTranscript = '';
  });
}

Future<void> _toggleMic() async {
  setState(() {
    _isMicOn = !_isMicOn;
  });

  print('VideoCallScreen: Toggling mic to: $_isMicOn');
  await _videoCallService.toggleMicrophone(_isMicOn);

  if (_isSpeechToTextOn) {
    if (_isMicOn) {
      print('VideoCallScreen: Resuming STT listening');
      await _speechService.startListening(
        language: _preferredLanguage,
        sampleRate: 16000,
      );
    } else {
      print('VideoCallScreen: Pausing STT listening');
      await _speechService.stopListening();
    }
  }
}

  Future<void> _toggleVideo() async {
    setState(() {
      _isVideoOn = !_isVideoOn;
    });

    await _videoCallService.toggleVideo(_isVideoOn);
  }

  Future<void> _toggleSpeechToText() async {
    final newState = !_isSpeechToTextOn;

    setState(() {
      _isSpeechToTextOn = newState;
    });

    final success = await _callService.toggleSpeechToText(
      widget.call.id,
      newState,
      _callService.currentUserId,
    );

    if (!success) {
      setState(() {
        _isSpeechToTextOn = !newState;
      });
      _showError('Failed to toggle speech-to-text');
      return;
    }

    if (newState) {
      await _initializeSpeechToText();
    } else {
      _stopSpeechToText();
    }
  }

  Future<void> _switchCamera() async {
    await _videoCallService.switchCamera();
  }

  Future<void> _endCall() async {
    if (_isCallEnded) return;

    setState(() {
      _isLoading = true;
      _isCallEnded = true;
    });

    try {
      if (_isSpeechToTextOn) {
        _stopSpeechToText();
      }

      await _callService.endCall(widget.call.id);
      await _videoCallService.leaveChannel();

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

  void _handleCallUpdates(CallModel? updatedCall) {
    if (updatedCall == null || !mounted) return;

    final userSttEnabled = updatedCall.speechToTextStatus?[_callService.currentUserId] ?? false;

    if (userSttEnabled != _isSpeechToTextOn) {
      setState(() {
        _isSpeechToTextOn = userSttEnabled;
      });

      if (_isSpeechToTextOn) {
        _initializeSpeechToText();
      } else {
        _stopSpeechToText();
      }
    }

    if (updatedCall.preferredLanguage != _preferredLanguage) {
      setState(() {
        _preferredLanguage = updatedCall.preferredLanguage;
      });

      if (_isSpeechToTextOn) {
        _stopSpeechToText();
        _initializeSpeechToText();
      }
    }

    final remoteUserId = updatedCall.participants
        .firstWhere((id) => id != _callService.currentUserId, orElse: () => '');

    if (remoteUserId.isNotEmpty) {
      final remoteTranscript = updatedCall.transcripts?[remoteUserId] ?? '';
      setState(() {
        _remoteTranscript = remoteTranscript;
      });
    }
  }

  Future<void> _changeLanguage(String language) async {
    setState(() {
      _preferredLanguage = language;
    });

    await _callService.updateCallLanguage(widget.call.id, language);

    if (_isSpeechToTextOn && _isMicOn) {
      _restartSpeechToText();
    }
  }

  Future<void> _restartSpeechToText() async {
    await _speechService.stopListening();
    await _speechService.startListening(language: _preferredLanguage);
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
    _callStreamSubscription.cancel();

    if (_isSpeechToTextOn) {
      _stopSpeechToText();
    }

    _speechService.dispose();

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
          _buildMainContent(isDarkMode, localizations),
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
          TranscriptOverlay(
            transcript: _localTranscript,
            isActive: _isSpeechToTextOn,
            onToggle: (enabled) => _toggleSpeechToText(),
            isLocalUser: true,
            onLanguagePress: () => LanguageSelector.showAsDialog(
              context,
              currentLanguage: _preferredLanguage,
              onLanguageSelected: _changeLanguage,
            ),
          ),
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
      return Center(
        child: _buildRemoteVideoView(),
      );
    } else {
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

  Widget _buildLocalVideoView() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _videoCallService.engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }
}