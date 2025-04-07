// lib/models/call_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  final String id;
  final String channelName;
  final String callerId;
  final String callerName;
  final String? callerProfileImageBase64;
  final String receiverId;
  final String receiverName;
  final String? receiverProfileImageBase64;
  final DateTime startTime;
  final bool isVideoEnabled;
  final bool isActive;
  final bool isAccepted;
  final bool isRejected;
  final List<String> participants;  // Added participants array
  final bool isSpeechToTextEnabled; // New field for speech-to-text
  final String preferredLanguage; // Preferred language for speech-to-text
  final Map<String, String>? transcripts; // Maps user IDs to their transcripts

  
  CallModel({
    required this.id,
    required this.channelName,
    required this.callerId,
    required this.callerName,
    this.callerProfileImageBase64,
    required this.receiverId,
    required this.receiverName,
    this.receiverProfileImageBase64,
    required this.startTime,
    this.isVideoEnabled = true,
    this.isActive = true,
    this.isAccepted = false,
    this.isRejected = false,
    List<String>? participants,
    this.isSpeechToTextEnabled = false,
    this.preferredLanguage = 'en-US',
    this.transcripts
  }) : participants = participants ?? [callerId, receiverId];
  
  // Factory constructor to create from Firestore document
  factory CallModel.fromFirestore(Map<String, dynamic> data, String id) {
    // Handle participants array
    List<String> participants = [];
    if (data['participants'] != null) {
      participants = List<String>.from(data['participants']);
    } else {
      // Fallback to create participants from caller and receiver IDs
      final callerId = data['callerId'] ?? '';
      final receiverId = data['receiverId'] ?? '';
      if (callerId.isNotEmpty) participants.add(callerId);
      if (receiverId.isNotEmpty) participants.add(receiverId);
      
    }
    
    return CallModel(
      id: id,
      channelName: data['channelName'] ?? '',
      callerId: data['callerId'] ?? '',
      callerName: data['callerName'] ?? 'Unknown',
      callerProfileImageBase64: data['callerProfileImageBase64'],
      receiverId: data['receiverId'] ?? '',
      receiverName: data['receiverName'] ?? 'Unknown',
      receiverProfileImageBase64: data['receiverProfileImageBase64'],
      startTime: data['startTime'] != null 
          ? (data['startTime'] as Timestamp).toDate() 
          : DateTime.now(),
      isVideoEnabled: data['isVideoEnabled'] ?? true,
      isActive: data['isActive'] ?? true,
      isAccepted: data['isAccepted'] ?? false,
      isRejected: data['isRejected'] ?? false,
      isSpeechToTextEnabled: data['isSpeechToTextEnabled'] ?? false,
      preferredLanguage: data['preferredLanguage'] ?? 'en-US',
      participants: participants,
      transcripts: data['transcripts'] != null 
        ? Map<String, String>.from(data['transcripts'])
        : null,
    );
  }
  
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'channelName': channelName,
      'callerId': callerId,
      'callerName': callerName,
      'callerProfileImageBase64': callerProfileImageBase64,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverProfileImageBase64': receiverProfileImageBase64,
      'startTime': Timestamp.fromDate(startTime),
      'isVideoEnabled': isVideoEnabled,
      'isActive': isActive,
      'isAccepted': isAccepted,
      'isRejected': isRejected,
      'participants': participants,
      'isSpeechToTextEnabled': isSpeechToTextEnabled,
      'preferredLanguage': preferredLanguage,
      'transcripts': transcripts,
    };
  }
  
  // Create a copy with updated fields
  CallModel copyWith({
    String? id,
    String? channelName,
    String? callerId,
    String? callerName,
    String? callerProfileImageBase64,
    String? receiverId,
    String? receiverName,
    String? receiverProfileImageBase64,
    DateTime? startTime,
    bool? isVideoEnabled,
    bool? isActive,
    bool? isAccepted,
    bool? isRejected,
    List<String>? participants,
    bool? isSpeechToTextEnabled,
    String? preferredLanguage,
    Map<String, String>? transcripts, 
  }) {
    return CallModel(
      id: id ?? this.id,
      channelName: channelName ?? this.channelName,
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      callerProfileImageBase64: callerProfileImageBase64 ?? this.callerProfileImageBase64,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverProfileImageBase64: receiverProfileImageBase64 ?? this.receiverProfileImageBase64,
      startTime: startTime ?? this.startTime,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isActive: isActive ?? this.isActive,
      isAccepted: isAccepted ?? this.isAccepted,
      isRejected: isRejected ?? this.isRejected,
      participants: participants ?? this.participants,
      isSpeechToTextEnabled: isSpeechToTextEnabled ?? this.isSpeechToTextEnabled,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      transcripts: transcripts ?? this.transcripts,
    );
  }
}