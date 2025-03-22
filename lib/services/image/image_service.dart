import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  
  // Request storage permission and pick image from gallery
  Future<Map<String, dynamic>> pickImageFromGallery(BuildContext context) async {
    // Request storage permission
    var status = await Permission.storage.request();

    if (status.isGranted) {
      try {
        // Permission granted, proceed with picking the image
        final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          // Using full quality with no dimension restrictions
        );
        
        if (pickedFile != null) {
          final imageFile = File(pickedFile.path);
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
  
  // Convert image file to base64 string
  Future<String> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
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