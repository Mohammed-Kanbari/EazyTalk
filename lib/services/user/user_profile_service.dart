// lib/services/user/user_profile_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eazytalk/models/user_model.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:eazytalk/services/profile/profile_image_service.dart';

class UserProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfileImageService _profileImageService = ProfileImageService();
  
  // Fetch user data from Firestore
  Future<UserModel?> fetchUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userData = await _firestore.collection('users').doc(user.uid).get();
        
        if (userData.exists) {
          return UserModel.fromFirestore(userData.data()!, user.uid);
        } else {
          // Create basic user model if no Firestore data exists
          return UserModel(
            id: user.uid,
            userName: 'User',
            email: user.email ?? '',
          );
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow;
    }
  }
  
  // Update user profile in Firestore
  Future<bool> updateUserProfile({
    required String name,
    File? profileImageFile,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Update data to Firestore
      Map<String, dynamic> updateData = {
        'username': name.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Upload image if provided
      if (profileImageFile != null) {
        final uploadResult = await _profileImageService.uploadProfileImage(profileImageFile);
        if (uploadResult['success']) {
          // No need to update Firestore again as the upload method already does it
          return true;
        } else {
          print('Error uploading profile image: ${uploadResult['message']}');
          // Still update the name even if image upload fails
          await _firestore.collection('users').doc(user.uid).update(updateData);
          return true;
        }
      } else {
        // Just update the name
        await _firestore.collection('users').doc(user.uid).update(updateData);
        return true;
      }
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
  
  // Show result snackbar
  static void showResultSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}