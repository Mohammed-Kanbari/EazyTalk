// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String userName;
  final String email;
  final String? profileImageBase64; // Keep for backward compatibility
  final String? profileImageUrl;    // New field for Supabase Storage URL
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  UserModel({
    required this.id,
    required this.userName,
    required this.email,
    this.profileImageBase64,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });
  
  // Create from Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      userName: data['username'] ?? 'User',
      email: data['email'] ?? '',
      profileImageBase64: data['profileImageBase64'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }
  
  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'username': userName,
      'email': email,
      'profileImageBase64': profileImageBase64,
      'profileImageUrl': profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? userName,
    String? email,
    String? profileImageBase64,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}