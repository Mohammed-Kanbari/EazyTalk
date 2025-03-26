import 'package:eazytalk/Services/speech/speech_recognition_service.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  
  // Language selection
  String _selectedLanguage = 'en-US'; // Default to English
  
  // List of available languages
  final Map<String, String> _languages = {
    'en-US': 'English',
    'ar-SA': 'العربية', // Arabic
  };

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
                    language: _selectedLanguage, // Use selected language
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
            language: _selectedLanguage, // Use selected language
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
  
  // Change language
  void _changeLanguage(String languageCode) {
    if (_isListening) {
      _stopListening();
    }
    
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Header with language selector
              _buildHeaderWithLanguageSelector(isDarkMode),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 30.h),
                        TranscriptionTextArea(
                          controller: _textController,
                          onChanged: (value) => _transcribedText = value,
                          onCopy: _copyText,
                          onClear: _clearText,
                          isDarkMode: isDarkMode,
                        ),
                        SizedBox(height: 36.h),
                        Divider(
                          color: isDarkMode 
                              ? const Color(0xFF323232) 
                              : AppColors.dividerColor,
                          thickness: 1,
                          height: 1,
                        ),
                        MicrophoneSection(
                          isListening: _isListening,
                          soundLevel: _soundLevel,
                          maxSoundLevel: _maxSoundLevel,
                          onToggleListening: _toggleListening,
                          onStopListening: _stopListening,
                          isDarkMode: isDarkMode,
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
  
  // New method to build header with language selector
  Widget _buildHeaderWithLanguageSelector(bool isDarkMode) {
    final textColor = AppColors.getTextPrimaryColor(context);
    final borderColor = isDarkMode ? const Color(0xFF323232) : AppColors.dividerColor;
    
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 27.h),
                  child: Image.asset(
                    'assets/icons/back-arrow.png',
                    width: 22.w,
                    height: 22.h,
                    color: textColor,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.arrow_back_ios,
                      color: textColor,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
              
              // Title
              Text(
                'Speech to Text',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              
              // Empty container for symmetry
              SizedBox(width: 22.w, height: 22.h),
            ],
          ),
        ),
        
        // Language selector
        Container(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Language:',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14.sp,
                  color: textColor,
                ),
              ),
              SizedBox(width: 10.w),
              
              // Language toggle buttons
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    // English button
                    _buildLanguageButton(
                      'en-US',
                      _languages['en-US']!,
                      isDarkMode,
                    ),
                    
                    // Arabic button
                    _buildLanguageButton(
                      'ar-SA',
                      _languages['ar-SA']!,
                      isDarkMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Helper method to build a language button
  Widget _buildLanguageButton(String languageCode, String languageName, bool isDarkMode) {
    final isSelected = _selectedLanguage == languageCode;
    final backgroundColor = isSelected
        ? AppColors.primary
        : (isDarkMode ? const Color(0xFF2A2A2A) : Colors.transparent);
    final textColor = isSelected
        ? Colors.white
        : (isDarkMode ? Colors.grey[400] : Colors.grey[700]);
    
    return GestureDetector(
      onTap: () => _changeLanguage(languageCode),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          languageName,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: textColor,
          ),
        ),
      ),
    );
  }
}