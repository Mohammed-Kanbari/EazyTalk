// lib/services/profile/profile_image_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
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
  
  // Pick image from gallery
  Future<Map<String, dynamic>> pickImageFromGallery(BuildContext context) async {
  final ImagePicker _picker = ImagePicker();
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  
  try {
    // Check platform-specific permissions
    if (Platform.isAndroid) {
      // Check Android version to determine which permission to request
      final androidInfo = await deviceInfo.androidInfo;
      final int sdkVersion = androidInfo.version.sdkInt;
      
      if (sdkVersion >= 33) {
        // Android 13+ (API 33+): Use photos permission
        print("Android 13+ detected, requesting photos permission");
        
        final status = await Permission.photos.status;
        print("Current photos permission status: $status");
        
        if (!status.isGranted) {
          final result = await Permission.photos.request();
          print("Photos permission request result: $result");
          
          if (!result.isGranted) {
            if (result.isPermanentlyDenied) {
              // Show dialog to open app settings
              if (context.mounted) {
                final shouldOpenSettings = await _showPermissionSettingsDialog(context);
                if (shouldOpenSettings) {
                  await openAppSettings();
                }
              }
            }
            
            return {
              'success': false,
              'message': 'Permission to access photos is required',
            };
          }
        }
      } else {
        // Android 12 and below: Use storage permission
        print("Android 12 or below detected, requesting storage permission");
        
        final status = await Permission.storage.status;
        print("Current storage permission status: $status");
        
        if (!status.isGranted) {
          final result = await Permission.storage.request();
          print("Storage permission request result: $result");
          
          if (!result.isGranted) {
            if (result.isPermanentlyDenied) {
              // Show dialog to open app settings
              if (context.mounted) {
                final shouldOpenSettings = await _showPermissionSettingsDialog(context);
                if (shouldOpenSettings) {
                  await openAppSettings();
                }
              }
            }
            
            return {
              'success': false,
              'message': 'Storage permission is required to pick an image',
            };
          }
        }
      }
    }
    
    // Permissions handled, now pick the image
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      
      // Convert image to base64 for preview
      final base64Image = await _convertImageToBase64(imageFile);
      
      return {
        'success': true,
        'file': imageFile,
        'base64': base64Image,
        'message': 'Image selected successfully'
      };
    } else {
      // User canceled the picker
      return {
        'success': false,
        'message': 'No image selected',
      };
    }
  } catch (e) {
    print('Error picking image: $e');
    return {
      'success': false,
      'message': 'Error picking image: $e',
    };
  }
}
  
  // Convert image file to base64 string (for preview)
  Future<String> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }


  Future<bool> _showPermissionSettingsDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Permission Required'),
      content: Text(
        'This app needs permission to access your photos. Please open settings and enable the permission.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Open Settings'),
        ),
      ],
    ),
  ) ?? false;
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