// lib/services/video_call/call_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eazytalk/l10n/app_localizations.dart';
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

Future<bool> updateTranscript(String callId, String userId, String transcript) async {
  try {
    await _firestore.collection('calls').doc(callId).update({
      'transcripts.$userId': transcript,
    });
    return true;
  } catch (e) {
    print('Error updating transcript: $e');
    return false;
  }
}

// Add this method to your CallService class (in lib/services/video_call/call_service.dart)

Future<bool> updateCallLanguage(String callId, String language) async {
  try {
    await _firestore.collection('calls').doc(callId).update({
      'preferredLanguage': language,
    });
    return true;
  } catch (e) {
    print('Error updating call language: $e');
    return false;
  }
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
    bool isSpeechToTextEnabled = false,
    String preferredLanguage = 'en-US',
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
        isSpeechToTextEnabled: isSpeechToTextEnabled,
        preferredLanguage: preferredLanguage,
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

   // Toggle speech-to-text for a call
Future<bool> toggleSpeechToText(String callId, bool enabled, String userId) async {
  try {
    await _firestore.collection('calls').doc(callId).update({
      'speechToTextStatus.$userId': enabled,
    });
    
    // Update cached call if it exists
    if (_currentCall?.id == callId) {
      // Create updated speech-to-text status map
      Map<String, bool> updatedStatus = Map.from(_currentCall?.speechToTextStatus ?? {});
      updatedStatus[userId] = enabled;
      
      _currentCall = _currentCall!.copyWith(speechToTextStatus: updatedStatus);
    }
    
    return true;
  } catch (e) {
    print('Error toggling speech-to-text: $e');
    return false;
  }
}

  

  // Update preferred language for speech-to-text
  Future<bool> updatePreferredLanguage(String callId, String language) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'preferredLanguage': language,
      });
      
      // Update cached call if it exists
      if (_currentCall?.id == callId) {
        _currentCall = _currentCall!.copyWith(preferredLanguage: language);
      }
      
      return true;
    } catch (e) {
      print('Error updating preferred language: $e');
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
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(call.isVideoEnabled ? 
          localizations.translate('incoming_video_call') : 
          localizations.translate('incoming_audio_call')),
        content: Text('${call.callerName} ${localizations.translate('is_calling_you')}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onReject();
            },
            child: Text(
              localizations.translate('decline'),
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAccept();
            },
            child: Text(
              localizations.translate('accept'),
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
  
  // Clear cache streams
  void clearCache() {
    _currentCall = null;
  }
}