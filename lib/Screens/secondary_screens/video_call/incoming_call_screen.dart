// lib/Screens/secondary_screens/video_call/incoming_call_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/models/call_model.dart';
import 'package:eazytalk/services/video_call/call_service.dart';
import 'package:eazytalk/Screens/secondary_screens/video_call/video_call_screen.dart';
import 'package:eazytalk/widgets/video_call/caller_info.dart';

class IncomingCallScreen extends StatefulWidget {
  final CallModel call;
  
  const IncomingCallScreen({
    Key? key,
    required this.call,
  }) : super(key: key);

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> with SingleTickerProviderStateMixin {
  final CallService _callService = CallService();
  
  // Animation controller for the accept/decline buttons
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  bool _isAccepting = false;
  bool _isDeclining = false;
  
  @override
  void initState() {
    super.initState();
    
    // Set up the animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 1.0, end: 1.1)
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
    
    // Start the animation
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Accept the call
  Future<void> _acceptCall() async {
    if (_isAccepting || _isDeclining) return;
    
    setState(() {
      _isAccepting = true;
    });
    
    try {
      final accepted = await _callService.acceptCall(widget.call.id);
      
      if (accepted && mounted) {
        // Navigate to the video call screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCallScreen(
              call: widget.call,
              isIncoming: true,
            ),
          ),
        );
      } else {
        _showError('Failed to accept call');
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error accepting call: $e');
      _showError('Error accepting call');
      
      setState(() {
        _isAccepting = false;
      });
    }
  }
  
  // Decline the call
  Future<void> _declineCall() async {
    if (_isAccepting || _isDeclining) return;
    
    setState(() {
      _isDeclining = true;
    });
    
    try {
      await _callService.rejectCall(widget.call.id);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error declining call: $e');
      _showError('Error declining call');
      
      setState(() {
        _isDeclining = false;
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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xFF121212), const Color(0xFF000000)]
                : [Colors.blue.shade900, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Call type indicator
              Padding(
                padding: EdgeInsets.only(top: 50.h),
                child: Text(
                  widget.call.isVideoEnabled ? 'Video Call' : 'Voice Call',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 20.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Caller info
              CallerInfo(
                name: widget.call.callerName,
                profileImageBase64: widget.call.callerProfileImageBase64,
                statusText: 'is calling you...',
                isDarkMode: isDarkMode,
              ),
              
              // Accept/Decline buttons
              Padding(
                padding: EdgeInsets.only(bottom: 60.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Decline button
                    _buildActionButton(
                      icon: Icons.call_end,
                      color: Colors.red,
                      onPressed: _declineCall,
                      isLoading: _isDeclining,
                      text: 'Decline',
                    ),
                    
                    // Accept button
                    _buildActionButton(
                      icon: Icons.call,
                      color: Colors.green,
                      onPressed: _acceptCall,
                      isLoading: _isAccepting,
                      text: 'Accept',
                      animate: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String text,
    bool isLoading = false,
    bool animate = false,
  }) {
    final buttonWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70.h,
          height: 70.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : IconButton(
                  icon: Icon(
                    icon,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                  onPressed: onPressed,
                ),
        ),
        SizedBox(height: 12.h),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16.sp,
            color: Colors.white,
          ),
        ),
      ],
    );
    
    if (animate) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: buttonWidget,
          );
        },
      );
    }
    
    return buttonWidget;
  }
}