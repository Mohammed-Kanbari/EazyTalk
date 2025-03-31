import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/services/voice_navigation/voice_navigation_service.dart';

class VoiceCommandButton extends StatefulWidget {
  final VoiceNavigationService navigationService;
  final VoidCallback? onLongPress;
  
  const VoiceCommandButton({
    Key? key, 
    required this.navigationService,
     this.onLongPress,
  }) : super(key: key);

  @override
  State<VoiceCommandButton> createState() => _VoiceCommandButtonState();
}

class _VoiceCommandButtonState extends State<VoiceCommandButton> with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    // Set up animations for the listening state
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 1.0, end: 1.2)
      .animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggleListening() async {
    if (_isListening) {
      await widget.navigationService.stopListening();
      _animationController.stop();
    } else {
      await widget.navigationService.startListening();
      _animationController.forward();
      
      // Automatically stop listening after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _isListening) {
          widget.navigationService.stopListening();
          setState(() {
            _isListening = false;
          });
          _animationController.stop();
          _showListeningStoppedSnackBar();
        }
      });
    }
    
    setState(() {
      _isListening = !_isListening;
    });
    
    if (_isListening) {
      _showListeningStartedSnackBar();
    }
  }
  
  void _showListeningStartedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Listening for voice commands...',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14.sp,
          ),
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _showListeningStoppedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Voice command listening stopped',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14.sp,
          ),
        ),
        backgroundColor: Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isListening ? _animation.value : 1.0,
          child: GestureDetector(
            onLongPress: widget.onLongPress,
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: _isListening ? Colors.red : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 24.sp,
                ),
                onPressed: _toggleListening,
              ),
            ),
          ),
        );
      },
    );
  }
}