import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String userName;
  final String email;
  final String? profileImageBase64;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  UserModel({
    required this.id,
    required this.userName,
    required this.email,
    this.profileImageBase64,
    this.createdAt,
    this.updatedAt,
  });
  
  // Create from JSON (unchanged from your version)
  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      userName: json['username'] ?? 'User',
      email: json['email'] ?? '',
      profileImageBase64: json['profileImageBase64'],
    );
  }
  
  // Create from Firestore (added from my version)
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      userName: data['username'] ?? 'User',
      email: data['email'] ?? '',
      profileImageBase64: data['profileImageBase64'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }
  
  // Convert to JSON (unchanged from your version)
  Map<String, dynamic> toJson() {
    return {
      'username': userName,
      'email': email,
      'profileImageBase64': profileImageBase64,
    };
  }
  
  // Convert to Firestore (added from my version)
  Map<String, dynamic> toFirestore() {
    return {
      'username': userName,
      'email': email,
      'profileImageBase64': profileImageBase64,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  // Create a copy with updated fields (added from my version)
  UserModel copyWith({
    String? id,
    String? userName,
    String? email,
    String? profileImageBase64,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}