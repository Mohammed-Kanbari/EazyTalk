import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eazytalk/models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Fetch user profile data
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final user = _auth.currentUser;
    String userName = 'User';
    String userEmail = '';
    String? profileImageBase64;
    
    if (user != null) {
      // Set email from Firebase Auth
      userEmail = user.email ?? '';
      
      try {
        // Get additional data from Firestore
        final userData = await _firestore.collection('users').doc(user.uid).get();
        
        if (userData.exists) {
          userName = userData.data()?['username'] ?? 'User';
          profileImageBase64 = userData.data()?['profileImageBase64'];
        }
      } catch (e) {
        print('Error fetching user data: $e');
        // Handle error but return what we have
      }
    }
    
    return {
      'userName': userName,
      'userEmail': userEmail,
      'profileImageBase64': profileImageBase64,
    };
  }
  
  // Update user profile after edit
  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update(updatedData);
    }
  }

  // Add these methods to lib/services/user/user_service.dart

// Fetch user profile by ID
Future<Map<String, dynamic>> fetchUserProfileById(String userId) async {
  try {
    final userData = await _firestore.collection('users').doc(userId).get();
    
    if (userData.exists) {
      final data = userData.data() ?? {};
      return {
        'id': userId,
        'userName': data['username'] ?? 'User',
        'profileImageBase64': data['profileImageBase64'],
      };
    }
    return {
      'id': userId,
      'userName': 'User',
      'profileImageBase64': null,
    };
  } catch (e) {
    print('Error fetching user data: $e');
    return {
      'id': userId,
      'userName': 'User',
      'profileImageBase64': null,
    };
  }
}

// Fetch all users
Future<List<Map<String, dynamic>>> fetchAllUsers() async {
  try {
    final usersSnapshot = await _firestore.collection('users').get();
    
    return usersSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'userName': data['username'] ?? 'User',
        'profileImageBase64': data['profileImageBase64'],
      };
    }).toList();
  } catch (e) {
    print('Error fetching users: $e');
    return [];
  }
}
}