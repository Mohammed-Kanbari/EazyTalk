// lib/services/video_call/call_history_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eazytalk/models/call_model.dart';

class CallHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';
  
  // Get call history for the current user
  Stream<List<CallModel>> getCallHistory() {
    if (currentUserId.isEmpty) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('calls')
        .where('participants', arrayContains: currentUserId)
        .orderBy('startTime', descending: true)
        .limit(30) // Limit to avoid loading too many records
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CallModel.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }
  
  // Get incoming missed calls
  Stream<List<CallModel>> getMissedCalls() {
    if (currentUserId.isEmpty) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRejected', isEqualTo: false)
        .where('isAccepted', isEqualTo: false)
        .where('isActive', isEqualTo: false)
        .orderBy('startTime', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CallModel.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }
  
  // Calculate call duration from a completed call
  Future<Duration> getCallDuration(String callId) async {
    try {
      final callDoc = await _firestore.collection('calls').doc(callId).get();
      
      if (!callDoc.exists) {
        return Duration.zero;
      }
      
      final call = CallModel.fromFirestore(callDoc.data()!, callId);
      
      // If the call has an end time, use it to calculate duration
      final endTimeField = callDoc.data()?['endTime'];
      if (endTimeField != null) {
        final endTime = (endTimeField as Timestamp).toDate();
        return endTime.difference(call.startTime);
      }
      
      // If no end time is recorded but the call is not active,
      // estimate using current time (this is a fallback)
      if (!call.isActive) {
        final now = DateTime.now();
        return now.difference(call.startTime);
      }
      
      return Duration.zero;
    } catch (e) {
      print('Error getting call duration: $e');
      return Duration.zero;
    }
  }
  
  // Format duration into a readable string (e.g., "5m 30s")
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${twoDigits(minutes)}m ${twoDigits(seconds)}s';
    } else if (minutes > 0) {
      return '${minutes}m ${twoDigits(seconds)}s';
    } else {
      return '${seconds}s';
    }
  }
  
  // Get call type (missed, incoming, outgoing)
  String getCallType(CallModel call) {
    if (call.callerId == currentUserId) {
      return 'Outgoing';
    } else if (call.isAccepted) {
      return 'Incoming';
    } else {
      return 'Missed';
    }
  }
  
  // Delete a call history record
  Future<bool> deleteCallRecord(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).delete();
      return true;
    } catch (e) {
      print('Error deleting call record: $e');
      return false;
    }
  }
  
  // Clear all call history for the current user
  Future<bool> clearCallHistory() async {
    try {
      // Get all calls involving the current user
      final querySnapshot = await _firestore
          .collection('calls')
          .where('participants', arrayContains: currentUserId)
          .get();
      
      // Delete each call document
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      
      return true;
    } catch (e) {
      print('Error clearing call history: $e');
      return false;
    }
  }
}