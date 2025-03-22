import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MediaUploadService {
  final _supabase = Supabase.instance.client;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  // Upload media file and save metadata to Firestore
  Future<Map<String, dynamic>> uploadSignMedia({
    required File mediaFile,
    required bool isVideo,
    required String signName,
    required String category,
    String? description,
    required Function(double progress) onProgressUpdate,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return {
          'success': false,
          'message': 'User not authenticated'
        };
      }

      // Create a unique file name with UUID
      final uuid = Uuid();
      final fileExt = path.extension(mediaFile.path);
      final fileName = '${uuid.v4()}$fileExt';
      final fileType = isVideo ? 'videos' : 'images';

      // Determine mime type
      final mimeType = lookupMimeType(mediaFile.path) ??
          (isVideo ? 'video/mp4' : 'image/jpeg');

      // Read file bytes
      final bytes = await mediaFile.readAsBytes();

      // Path in Supabase Storage
      final storagePath = 'user_signs/$fileType/$fileName';

      // Start with 10% progress for read operation
      onProgressUpdate(0.1);

      // Upload file to Supabase Storage
      await _supabase.storage
          .from('eazytalk') // Your bucket name in Supabase
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: mimeType,
            ),
          );

      // Update progress to 70% after upload
      onProgressUpdate(0.7);

      // Get public URL for the uploaded file
      final fileUrl =
          _supabase.storage.from('eazytalk').getPublicUrl(storagePath);

      // Save metadata to Firestore
      await _firestore.collection('user_signs').add({
        'userId': user.uid,
        'userEmail': user.email,
        'signName': signName.trim(),
        'description': description?.trim() ?? '',
        'category': category,
        'fileUrl': fileUrl,
        'filePath': storagePath,
        'fileType': isVideo ? 'video' : 'image',
        'status': 'pending', // For moderation
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update progress to 100% after Firestore save
      onProgressUpdate(1.0);

      return {
        'success': true,
        'message': 'Sign uploaded successfully'
      };
    } catch (e) {
      print('Error uploading sign: $e');
      return {
        'success': false,
        'message': 'Error uploading sign: $e'
      };
    }
  }
}