// lib/services/video_call/call_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:eazytalk/models/call_model.dart';
import 'package:eazytalk/services/user/user_service.dart';
import 'package:eazytalk/core/constants/agora_constants.dart';

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  
  // Caching for ongoing call
  CallModel? _currentCall;
  
  // Getters
  User? get currentUser => _auth.currentUser;
  String get currentUserId => currentUser?.uid ?? '';
  CallModel? get currentCall => _currentCall;
  
  // Stream of incoming calls for the current user
  Stream<List<CallModel>> get incomingCallsStream {
    if (currentUserId.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isActive', isEqualTo: true)
        .where('isAccepted', isEqualTo: false)
        .where('isRejected', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final calls = snapshot.docs.map((doc) {
            return CallModel.fromFirestore(doc.data(), doc.id);
          }).toList();
          
          return calls;
        });
  }
  
  // Stream for a specific call by ID
  Stream<CallModel?> callStream(String callId) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return CallModel.fromFirestore(snapshot.data()!, snapshot.id);
        });
  }
  
  // Make a call to another user
  Future<CallModel?> makeCall({
    required String receiverId,
    required String receiverName,
    String? receiverProfileImageBase64,
    bool isVideoEnabled = true,
  }) async {
    if (currentUserId.isEmpty) return null;
    
    try {
      // Get caller's information
      final callerData = await _userService.fetchUserProfile();
      final callerName = callerData['userName'] ?? 'User';
      final callerProfileImageBase64 = callerData['profileImageBase64'];
      
      // Generate a unique channel name
      final channelName = '${AgoraConstants.defaultChannel}_${const Uuid().v4()}';
      
      // Create the call document
      final callData = CallModel(
        id: '', // Will be set after Firestore document is created
        channelName: channelName,
        callerId: currentUserId,
        callerName: callerName,
        callerProfileImageBase64: callerProfileImageBase64,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverProfileImageBase64: receiverProfileImageBase64,
        startTime: DateTime.now(),
        isVideoEnabled: isVideoEnabled,
        isActive: true,
        isAccepted: false,
        isRejected: false,
      );
      
      // Add to Firestore
      final docRef = await _firestore.collection('calls').add(callData.toFirestore());
      
      // Get the complete call model with the ID
      final completeCall = callData.copyWith(id: docRef.id);
      _currentCall = completeCall;
      
      return completeCall;
    } catch (e) {
      print('Error making call: $e');
      return null;
    }
  }
  
  // Accept an incoming call
  Future<bool> acceptCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'isAccepted': true,
      });
      
      // Fetch and cache the updated call
      final callDoc = await _firestore.collection('calls').doc(callId).get();
      if (callDoc.exists) {
        _currentCall = CallModel.fromFirestore(callDoc.data()!, callDoc.id);
      }
      
      return true;
    } catch (e) {
      print('Error accepting call: $e');
      return false;
    }
  }
  
  // Reject an incoming call
  Future<bool> rejectCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'isRejected': true,
        'isActive': false,
      });
      return true;
    } catch (e) {
      print('Error rejecting call: $e');
      return false;
    }
  }
  
  // End an ongoing call
  Future<bool> endCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'isActive': false,
      });
      
      // Clear the cached call
      if (_currentCall?.id == callId) {
        _currentCall = null;
      }
      
      return true;
    } catch (e) {
      print('Error ending call: $e');
      return false;
    }
  }
  
  // Check if a call has been accepted
  Future<bool> isCallAccepted(String callId) async {
    try {
      final callDoc = await _firestore.collection('calls').doc(callId).get();
      if (!callDoc.exists) return false;
      
      return callDoc.data()?['isAccepted'] ?? false;
    } catch (e) {
      print('Error checking if call is accepted: $e');
      return false;
    }
  }
  
  // Show alert dialog for incoming call
  void showIncomingCallAlert(
    BuildContext context, 
    CallModel call, 
    Function() onAccept, 
    Function() onReject
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Incoming ${call.isVideoEnabled ? 'Video' : 'Audio'} Call'),
        content: Text('${call.callerName} is calling you...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onReject();
            },
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAccept();
            },
            child: const Text('Accept', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}