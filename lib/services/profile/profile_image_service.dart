// lib/services/profile/profile_image_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileImageService {
  final _supabase = Supabase.instance.client;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  
  // Pick image from gallery
  Future<Map<String, dynamic>> pickImageFromGallery(BuildContext context) async {
    // Request storage permission
    var status = await Permission.storage.request();

    if (status.isGranted) {
      try {
        // Permission granted, proceed with picking the image
        final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,  // Reasonable size for profile pictures
          maxHeight: 800,
          imageQuality: 85, // Slightly compress to reduce size
        );
        
        if (pickedFile != null) {
          final imageFile = File(pickedFile.path);
          // Get base64 for preview purposes
          final base64Image = await _convertImageToBase64(imageFile);
          
          return {
            'success': true,
            'file': imageFile,
            'base64': base64Image,
            'message': 'Image selected successfully'
          };
        } else {
          return {
            'success': false,
            'message': 'No image selected',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Error picking image: $e',
        };
      }
    } else if (status.isDenied) {
      return {
        'success': false,
        'message': 'Storage permission is required to pick an image',
      };
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      return {
        'success': false,
        'message': 'Permission permanently denied. Please enable in settings.',
      };
    }
    
    return {
      'success': false,
      'message': 'Unknown permission error',
    };
  }
  
  // Convert image file to base64 string (for preview)
  Future<String> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }
  
  // Upload profile image to Supabase and store URL in Firestore
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        return {
          'success': false,
          'message': 'User not authenticated'
        };
      }

      // Create a unique file name
      final fileExt = path.extension(imageFile.path);
      final fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
      
      // Determine mime type
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

      // Read file bytes
      final bytes = await imageFile.readAsBytes();

      // Path in Supabase Storage
      final storagePath = 'profile_images/$fileName';

      // Upload file to Supabase Storage
      await _supabase.storage
          .from('eazytalk') // Your bucket name
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: mimeType,
            ),
          );

      // Get public URL for the uploaded file
      final imageUrl = _supabase.storage
          .from('eazytalk')
          .getPublicUrl(storagePath);
      
      // Get base64 for immediate display
      final base64Image = await _convertImageToBase64(imageFile);

      // Update user profile with both URL and base64 (transitional approach)
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': imageUrl,
        'profileImageBase64': base64Image, // Keep this for backward compatibility
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'imageUrl': imageUrl,
        'base64': base64Image,
        'message': 'Profile image updated successfully'
      };
    } catch (e) {
      print('Error uploading profile image: $e');
      return {
        'success': false,
        'message': 'Error uploading profile image: $e'
      };
    }
  }
  
  // Show a snackbar with the result message
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