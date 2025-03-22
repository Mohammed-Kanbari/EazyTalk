// lib/services/user/presence_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PresenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Update user status to online
  Future<void> setOnline() async {
    if (currentUserId == null) return;
    
    await _firestore.collection('users').doc(currentUserId).update({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
  
  // Update user status to offline
  Future<void> setOffline() async {
    if (currentUserId == null) return;
    
    await _firestore.collection('users').doc(currentUserId).update({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
  
  // Get user online status
  Stream<bool> getUserOnlineStatus(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.data()?['isOnline'] ?? false;
        });
  }
  
  // Get user last seen
  Stream<DateTime?> getUserLastSeen(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          final lastSeen = snapshot.data()?['lastSeen'];
          return lastSeen != null ? (lastSeen as Timestamp).toDate() : null;
        });
  }
}