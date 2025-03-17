import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart'; // For clipboard functionality

class Speech extends StatefulWidget {
  const Speech({super.key});

  @override
  State<Speech> createState() => _SpeechState();
}

class _SpeechState extends State<Speech> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcribedText = '';
  late TextEditingController _textController; // Controller for TextField

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _textController = TextEditingController(text: _transcribedText); // Initialize controller
  }

  @override
  void dispose() {
    _textController.dispose(); // Dispose controller to avoid memory leaks
    super.dispose();
  }

  // Toggle speech-to-text listening
  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _transcribedText = result.recognizedWords;
              _textController.text = _transcribedText; // Update TextField
            });
          },
          listenFor: const Duration(seconds: 30), // Limit listening duration
          pauseFor: const Duration(seconds: 3), // Pause detection
          cancelOnError: true,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // Copy text to clipboard
  void _copyText() {
    Clipboard.setData(ClipboardData(text: _textController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard!')),
    );
  }

  // Clear the transcribed text
  void _clearText() {
    setState(() {
      _transcribedText = '';
      _textController.clear(); // Clear TextField
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Allow resizing to avoid bottom overflow
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // Hide the keyboard when tapping outside
          },
          child: Column(
            children: [
              // Fixed title row (not scrollable)
              Padding(
                padding: EdgeInsets.only(top: 27.h, left: 28.w, right: 28.w),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
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
                    // Add invisible spacing to balance the back button
                    SizedBox(
                      width: 20.w,
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 79.h),
                        // Text Area (Now a TextField)
                        Container(
                          width: double.infinity,
                          height: 275.h, // Fixed height
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
                                    maxLines: null, // Allow multiline input
                                    keyboardType: TextInputType.multiline,
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 16.sp,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none, // No border
                                      hintText: 'Your transcribed text will appear here.',
                                      hintStyle: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'DM Sans',
                                        color: const Color(0xFF9E9E9E),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      _transcribedText = value; // Sync with _transcribedText
                                    },
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
                        ),
                        SizedBox(height: 36.h),
                        // Divider
                        Divider(
                          color: const Color(0xFFE8E8E8),
                          thickness: 1,
                          height: 1,
                        ),
                        // Column below the divider
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height * 0.45, // Adjust the max height as needed
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Tap the mic and start talking — we’ll do the typing!',
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
                                  // Keep the SizedBox(width: 80.w) for styling
                                  SizedBox(width: 80.w),
                                  // Mic button
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
                                  SizedBox(width: 25.w),
                                  // Stop button
                                  IconButton(
                                    icon: Icon(
                                      Icons.stop,
                                      size: 28.w,
                                      color: _isListening ? Colors.grey[600] : Colors.grey[300],
                                    ),
                                    onPressed: _isListening ? _toggleListening : null,
                                  ),
                                  // Spacer to balance the right side
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