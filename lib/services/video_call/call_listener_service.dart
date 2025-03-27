// lib/services/video_call/call_listener_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eazytalk/models/call_model.dart';
import 'package:eazytalk/services/video_call/call_service.dart';
import 'package:eazytalk/Screens/secondary_screens/video_call/incoming_call_screen.dart';

// Callback function to handle an incoming call
typedef IncomingCallHandler = void Function(CallModel call);

class CallListenerService {
  final CallService _callService = CallService();
  
  StreamSubscription<List<CallModel>>? _callSubscription;
  bool _isListening = false;
  CallModel? _currentlyShowingCall;
  
  // Start listening for incoming calls
  void startListening(BuildContext context) {
    if (_isListening) return;
    
    _isListening = true;
    
    // Subscribe to incoming calls stream
    _callSubscription = _callService.incomingCallsStream.listen((calls) {
      if (calls.isEmpty) return;
      
      // Get the newest call
      final latestCall = calls.first;
      
      // Check if we're already showing this call
      if (_currentlyShowingCall?.id == latestCall.id) return;
      
      // Set as currently showing call
      _currentlyShowingCall = latestCall;
      
      // Handle the incoming call
      _handleIncomingCall(context, latestCall);
    });
  }
  
  // Stop listening for incoming calls
  void stopListening() {
    _callSubscription?.cancel();
    _callSubscription = null;
    _isListening = false;
    _currentlyShowingCall = null;
  }
  
  // Handle an incoming call
  void _handleIncomingCall(BuildContext context, CallModel call) {
    // Navigate to incoming call screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomingCallScreen(call: call),
      ),
    ).then((_) {
      // Reset currently showing call when screen is dismissed
      _currentlyShowingCall = null;
    });
  }
}