import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart'; // For clipboard functionality
import 'dart:math' as math;

// Custom painter for sound wave visualization
class SoundWavePainter extends CustomPainter {
  final double soundLevel;
  final Color color;
  
  SoundWavePainter({
    required this.soundLevel, 
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Draw multiple perfect circles with varying sizes based on sound level
    for (int i = 0; i < 3; i++) {
      // Vary the opacity based on the wave number
      final opacity = math.max(0.05, 0.3 - (i * 0.05));
      
      // Calculate wave radius based on sound level
      final waveRadius = radius * (0.7 + (i * 0.15)) * (0.8 + (soundLevel * 0.3));
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      // Draw perfect circle
      canvas.drawCircle(center, waveRadius, paint);
    }
  }
  
  @override
  bool shouldRepaint(SoundWavePainter oldDelegate) => 
      oldDelegate.soundLevel != soundLevel;
}

class Speech extends StatefulWidget {
  const Speech({super.key});

  @override
  State<Speech> createState() => _SpeechState();
}

class _SpeechState extends State<Speech> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcribedText = '';
  late TextEditingController _textController;
  // Sound level for wave animation
  double _soundLevel = 0.0;
  double _maxSoundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _textController = TextEditingController(text: _transcribedText);
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.stop(); // Stop speech recognition when exiting
    super.dispose();
  }

  // Toggle speech-to-text listening
  Future<void> _toggleListening() async {
    try {
      if (!_isListening) {
        bool available = await _speech.initialize();
        if (available) {
          setState(() {
            _isListening = true;
            // Reset accumulated text only when starting a completely new session
            _accumulatedText = _textController.text;
          });
          _startListening();
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

  // Store the accumulated text when starting a new listening session
  String _accumulatedText = '';
  
  // Separate method to start listening with continuous recognition
  void _startListening() {
    // Before starting a new listening session, save the current text
    if (_speech.isNotListening && _isListening) {
      _accumulatedText = _textController.text;
    }
    
    _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            // Append the new recognized words to the accumulated text
            if (result.recognizedWords.isNotEmpty) {
              // Only update if we have new words to avoid flickering
              _transcribedText = _accumulatedText + ' ' + result.recognizedWords;
              _textController.text = _transcribedText;
            }
          });
        }
      },
      listenFor: const Duration(minutes: 30), // Extend listening time significantly
      pauseFor: const Duration(minutes: 5), // Allow longer pauses
      partialResults: true,
      onSoundLevelChange: (level) {
        // Update sound level for the wave animation
        if (mounted) {
          setState(() {
            _soundLevel = level;
            // Keep track of the maximum sound level for scaling purposes
            if (level > _maxSoundLevel) _maxSoundLevel = level;
          });
        }
      },
      cancelOnError: false,
      listenMode: stt.ListenMode.confirmation, // Use confirmation mode for better continuity
    );
    
    // Set up a listener for when speech service is stopped
    _speech.statusListener = (status) {
      if (status == 'done' && _isListening) {
        // Save the current text before restarting
        _accumulatedText = _textController.text;
        
        // If speech service stopped but we're still in listening mode, restart it
        Future.delayed(const Duration(milliseconds: 200), () {
          if (_isListening && mounted) {
            _startListening();
          }
        });
      }
    };
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
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
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 79.h),
                        _buildTextArea(),
                        SizedBox(height: 36.h),
                        Divider(
                          color: const Color(0xFFE8E8E8),
                          thickness: 1,
                          height: 1,
                        ),
                        _buildMicSection(),
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(top: 27.h, left: 28.w, right: 28.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset(
              'assets/icons/back-arrow.png',
              width: 20.w,
              height: 20.h,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Speech to Text',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 20.w), // Invisible spacing for UI balance
        ],
      ),
    );
  }

  Widget _buildTextArea() {
    return Container(
      width: double.infinity,
      height: 275.h,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: const Color(0xFF00D0FF).withOpacity(0.11),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: TextField(
                controller: _textController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Your transcribed text will appear here.',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'DM Sans',
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                onChanged: (value) => _transcribedText = value,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: Image.asset(
                  'assets/icons/copy 1.png',
                  width: 24.w,
                  height: 24.h,
                ),
                onTap: _copyText,
              ),
              GestureDetector(
                child: Image.asset(
                  'assets/icons/bin 1.png',
                  width: 24.w,
                  height: 24.h,
                ),
                onTap: _clearText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMicSection() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.45,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Tap the mic and start talking — we'll do the typing!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
              color: const Color(0xFF787579),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 80.w),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Sound wave animations - only visible when listening
                  if (_isListening) ...[
                    // Static background ripples
                    for (int i = 1; i <= 2; i++)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: (1000 + (i * 300)).toInt()),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: (1 - value).clamp(0.0, 0.5),
                            child: Transform.scale(
                              scale: 1 + (value * 0.5),
                              child: Container(
                                width: 120.w,
                                height: 120.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF00D0FF).withOpacity(0.3),
                                ),
                              ),
                            ),
                          );
                        },
                        key: ValueKey('static_ripple_$i'),
                      ),
                    
                    // Dynamic sound level-based ripples
                    _buildSoundWaves(),
                  ],
                  
                  // Main mic button
                  GestureDetector(
                    onTap: _toggleListening,
                    child: Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00D0FF),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D0FF).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 25.w),
              IconButton(
                icon: Icon(
                  Icons.stop,
                  size: 28.w,
                  color: _isListening ? Colors.red : Colors.grey[300],
                ),
                onPressed: _isListening ? _stopListening : null,
              ),
            ],
          ),
          Text(
            _isListening ? 'Listening' : '',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 20.sp,
              color: const Color(0xFF787579),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build sound wave visualization based on current sound level
  Widget _buildSoundWaves() {
    // Normalize sound level for visualization
    // If max level is too small, use a default value
    double normalizedLevel = _maxSoundLevel > 0.1 
        ? (_soundLevel / _maxSoundLevel).clamp(0.3, 1.0)
        : 0.5;
    
    // Use a StatefulBuilder instead of AnimatedBuilder with a separate controller
    return StatefulBuilder(
      builder: (context, setState) {
        return CustomPaint(
          size: Size(200.w, 200.h),
          painter: SoundWavePainter(
            soundLevel: normalizedLevel,
            color: const Color(0xFF00D0FF),
          ),
        );
      },
    );
  }
}