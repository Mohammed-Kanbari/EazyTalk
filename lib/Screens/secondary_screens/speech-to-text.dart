import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/services/speech/speech_recognition_service.dart';
import 'package:eazytalk/widgets/common/secondary_header.dart';
import 'package:eazytalk/widgets/speech_to_text/text_area.dart';
import 'package:eazytalk/widgets/speech_to_text/microphone_section.dart';

class Speech extends StatefulWidget {
  const Speech({super.key});

  @override
  State<Speech> createState() => _SpeechState();
}

class _SpeechState extends State<Speech> {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  bool _isListening = false;
  String _transcribedText = '';
  String _accumulatedText = '';
  late TextEditingController _textController;
  
  // Sound level for wave animation
  double _soundLevel = 0.0;
  double _maxSoundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _transcribedText);
    _initializeSpeechService();
  }

  Future<void> _initializeSpeechService() async {
    await _speechService.initialize();
  }

  @override
  void dispose() {
    _textController.dispose();
    _speechService.stopListening();
    super.dispose();
  }

// Toggle speech-to-text listening
  Future<void> _toggleListening() async {
    try {
      if (!_isListening) {
        bool available = await _speechService.initialize();
        if (available) {
          setState(() {
            _isListening = true;
            _accumulatedText = _textController.text;
          });
          
          // Define the status handler function that can be reused
          void handleStatus(String status) {
            if (status == 'done' && _isListening && mounted) {
              // Save the current text
              _accumulatedText = _textController.text;
              
              // Restart listening after a delay to prevent immediate stopping
              Future.delayed(const Duration(milliseconds: 1), () {
                if (_isListening && mounted) {
                  _speechService.startListening(
                    onResult: (text) {
                      if (mounted) {
                        setState(() {
                          _transcribedText = text;
                          _textController.text = text;
                        });
                      }
                    },
                    onSoundLevelChange: (level) {
                      if (mounted) {
                        setState(() {
                          _soundLevel = level;
                          if (level > _maxSoundLevel) _maxSoundLevel = level;
                        });
                      }
                    },
                    onStatus: handleStatus, // Use the same handler for recursive calls
                    accumulatedText: _accumulatedText,
                    pauseTimeout: const Duration(seconds: 15),
                  );
                }
              });
            }
          }
          
          await _speechService.startListening(
            onResult: (text) {
              if (mounted) {
                setState(() {
                  _transcribedText = text;
                  _textController.text = text;
                });
              }
            },
            onSoundLevelChange: (level) {
              if (mounted) {
                setState(() {
                  _soundLevel = level;
                  if (level > _maxSoundLevel) _maxSoundLevel = level;
                });
              }
            },
            onStatus: handleStatus, // Use the defined handler
            accumulatedText: _accumulatedText,
            pauseTimeout: const Duration(seconds: 15), // Increased pause timeout to 15 seconds
          );
        } else {
          _showSnackBar('Speech recognition not available');
        }
      } else {
        _stopListening();
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _stopListening() {
    _speechService.stopListening();
    setState(() => _isListening = false);
  }

  void _copyText() {
    if (_textController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _textController.text));
      _showSnackBar('Text copied to clipboard!');
    }
  }

  void _clearText() {
    setState(() {
      _transcribedText = '';
      _accumulatedText = '';
      _textController.clear();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              SecondaryHeader(
                title: 'Speech to Text',
                onBackPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 79.h),
                        TranscriptionTextArea(
                          controller: _textController,
                          onChanged: (value) => _transcribedText = value,
                          onCopy: _copyText,
                          onClear: _clearText,
                        ),
                        SizedBox(height: 36.h),
                        Divider(
                          color: AppColors.dividerColor,
                          thickness: 1,
                          height: 1,
                        ),
                        MicrophoneSection(
                          isListening: _isListening,
                          soundLevel: _soundLevel,
                          maxSoundLevel: _maxSoundLevel,
                          onToggleListening: _toggleListening,
                          onStopListening: _stopListening,
                        ),
                      ],
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
}