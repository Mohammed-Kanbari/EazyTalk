import 'package:eazytalk/widgets/speech_to_text/instruction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/widgets/common/secondary_header.dart';
import 'package:eazytalk/l10n/app_localizations.dart';
import 'package:camera/camera.dart';
import 'package:eazytalk/services/sign_language/sign_language_recognition_service.dart';

class SignLanguageTranslatorScreen extends StatefulWidget {
  const SignLanguageTranslatorScreen({Key? key}) : super(key: key);

  @override
  State<SignLanguageTranslatorScreen> createState() => _SignLanguageTranslatorScreenState();
}

class _SignLanguageTranslatorScreenState extends State<SignLanguageTranslatorScreen> with WidgetsBindingObserver {
  final SignLanguageRecognitionService _recognitionService = SignLanguageRecognitionService();
  
  bool _isRecording = false;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionDenied = false;
  
  // Current recognition result
  String _recognitionResult = '';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    
    // Listen for recognition results
    _recognitionService.recognitionResult.addListener(_onRecognitionResult);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
// Handle app lifecycle changes to manage camera resources properly
    // Handle app lifecycle changes to manage camera resources properly
    final CameraController? cameraController = _recognitionService.cameraController;
    
    // App state changed before we initialized the camera
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    
    if (state == AppLifecycleState.inactive) {
      // App inactive: free up camera resources
      if (_isRecording) {
        _stopRecognition();
      }
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // App resumed: re-initialize camera
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final initialized = await _recognitionService.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = initialized;
          _isCameraPermissionDenied = !initialized;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isCameraPermissionDenied = true;
        });
      }
    }
  }
  
  // Handle recognition results
  void _onRecognitionResult() {
    if (mounted && _isRecording) {
      final result = _recognitionService.recognitionResult.value;
      if (result.isNotEmpty) {
        setState(() {
          _recognitionResult = result;
        });
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (!_isCameraInitialized) {
      _showMessage('Camera not initialized');
      return;
    }
    
    if (_isRecording) {
      await _stopRecognition();
    } else {
      await _startRecognition();
    }
  }
  
  Future<void> _startRecognition() async {
    final success = await _recognitionService.startRecognition();
    
    if (success) {
      setState(() {
        _isRecording = true;
        _recognitionResult = '';
      });
    } else {
      _showMessage('Failed to start recognition');
    }
  }
  
  Future<void> _stopRecognition() async {
    await _recognitionService.stopRecognition();
    
    if (mounted) {
      setState(() {
        _isRecording = false;
      });
    }
  }
  
Future<void> _switchCamera() async {
  if (!_isCameraInitialized) return;
  
  if (mounted) {
  setState(() {
    _isCameraInitialized = false;
  });
}
  
  final success = await _recognitionService.switchCamera();
  
  // Add a mounted check here
  if (mounted) {
    setState(() {
      _isCameraInitialized = true;
    });
    
    if (!success) {
      _showCameraFlipError();
    }
  }
}
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recognitionService.recognitionResult.removeListener(_onRecognitionResult);
    _stopRecognition();
    _recognitionService.dispose();
    super.dispose();
  }

  // New method to show instructions dialog
void _showInstructionsDialog() {
  final localizations = AppLocalizations.of(context);
  
  // Create the steps with their instructions and tips
  final List<InstructionStep> steps = [
    InstructionStep(
      title: localizations.translate('setup_camera'),
      instructions: [
        localizations.translate('camera_eye_level'),
        localizations.translate('upper_body_in_view'),
      ],
      tips: [
        localizations.translate('tip_hand_only'),
        localizations.translate('tip_well_lit'),
        localizations.translate('tip_one_person'),
      ],
    ),
    InstructionStep(
      title: localizations.translate('performing_signs'),
      instructions: [
        localizations.translate('ready_to_sign'),
        localizations.translate('perform_slowly'),
        localizations.translate('you_will_see'),
        localizations.translate('sign_time'),
      ],
      tips: [
        localizations.translate('tip_clear_gestures'),
        localizations.translate('tip_face_camera'),
        localizations.translate('when_done'),
      ],
    ),
    InstructionStep(
      title: localizations.translate('reading_results'),
      instructions: [
        localizations.translate('Ai_think'),
        localizations.translate('results_appear_bottom'),
        localizations.translate('similar_signs'),
        localizations.translate('choose_sign'),
        localizations.translate('word_not_recognized'),
      ],
    ),

    InstructionStep(
      title: localizations.translate('need_help'),
      instructions: [
        localizations.translate('check_learn'),
        localizations.translate('dictionary_has_signs'),
      ],
    ),
  ];
  
  // Create the remember points
  final List<String> rememberPoints = [
    localizations.translate('sign_with_upper_body'),
    localizations.translate('ai_recognizes_many_words'),
    localizations.translate('try_again_if_not_right'),
  ];
  
  // Show the dialog
  InstructionsDialog.show(
    context: context,
    title: localizations.translate('instructions'),
    steps: steps,
    rememberPoints: rememberPoints,
    thankYouTitle: localizations.translate('thank_you_title'),
    thankYouMessage: localizations.translate('thank_you_message'),
  );
}

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            SecondaryHeader(
              title: localizations.translate('sign_language'),
              onBackPressed: () => Navigator.pop(context),
              actionWidget: _isCameraInitialized ? GestureDetector(
                  onTap: _showInstructionsDialog,
                  child: Icon(
                    Icons.help_outline,
                    color: AppColors.getTextPrimaryColor(context),
                    size: 28.sp,
                  ),
                ) : null,
            ),

            //flip_camera_ios , _switchCamera, isCameraInitilaled
            
            SizedBox(height: 20.h),
            
            // Camera preview and results
            Expanded(
              child: _buildMainContent(isDarkMode, localizations),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCameraFlipError() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Flip'),
        content: Text('Unable to flip camera. Make sure your device has multiple cameras.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDarkMode, AppLocalizations localizations) {
    if (_isCameraPermissionDenied) {
      return _buildPermissionDeniedView(localizations);
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        children: [
          // Camera preview container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Camera preview
                  if (_isCameraInitialized &&
                      _recognitionService.cameraController != null &&
                      _recognitionService.cameraController!.value.isInitialized)
                    AspectRatio(
                      aspectRatio: _recognitionService.cameraController!.value.aspectRatio,
                      child: CameraPreview(_recognitionService.cameraController!),
                    )
                  else
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  
                  // Recording indicator
                  if (_isRecording)
                    Positioned(
                      top: 16.h,
                      right: 16.w,
                      child: Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_isCameraInitialized)
                    Positioned(
                      top: 16.h,
                      left: 16.w,
                      child: GestureDetector(
                        onTap: _switchCamera,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: Icon(
                            Icons.flip_camera_ios,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                  
                  // Results overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      child: Text(
                        _recognitionResult.isEmpty 
                            ? localizations.translate('your_results_will_appear_here')
                            : _recognitionResult,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 30.h),
          
          // Instructions text
          Text(
            localizations.translate('hold_sign_instructions'),
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
              color: AppColors.getTextPrimaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 30.h),
          
          // Record button
          GestureDetector(
            onTap: _toggleRecording,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _isRecording 
                    ? Colors.red
                    : const Color(0xFF00D0FF),
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : const Color(0xFF00D0FF)).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: _isRecording
                        ? Icon(
                            Icons.stop,
                            color: Colors.red,
                            size: 14.sp,
                          )
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    _isRecording
                        ? localizations.translate('stop_recording')
                        : localizations.translate('start_recording'),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  // Build view when camera permission is denied
  Widget _buildPermissionDeniedView(AppLocalizations localizations) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.no_photography,
            size: 80.sp,
            color: Colors.red,
          ),
          SizedBox(height: 24.h),
          Text(
            localizations.translate('camera_permission_required'),
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            localizations.translate('enable_camera_instructions') ,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16.sp,
              color: AppColors.getTextPrimaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40.h),
          ElevatedButton(
            onPressed: _initializeCamera,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              localizations.translate('try_again'),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}