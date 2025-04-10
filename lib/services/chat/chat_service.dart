// lib/services/chat/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eazytalk/models/conversation_model.dart';
import 'package:eazytalk/models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Stream caching to prevent recreation
  Stream<List<ConversationModel>>? _conversationsStream;
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Clear cached streams (useful when logging out)
  void clearCache() {
    _conversationsStream = null;
  }

  // Get all conversations for current user with caching
  Stream<List<ConversationModel>> getConversations() {
    // Only recreate the stream if necessary
    if (_conversationsStream == null) {
      if (currentUserId == null) {
        // Return empty stream if not logged in
        return Stream.value([]);
      }
      
      print('Creating new conversations stream for user: $currentUserId');
      
      // Create and cache the stream
      _conversationsStream = _firestore
          .collection('conversations')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
            try {
              print('Received ${snapshot.docs.length} conversations from Firestore');
              return snapshot.docs.map((doc) {
                try {
                  return ConversationModel.fromFirestore(doc.data(), doc.id);
                } catch (e) {
                  print('Error parsing conversation ${doc.id}: $e');
                  // Skip this conversation rather than failing the whole list
                  return null;
                }
              }).where((element) => element != null)
                  .cast<ConversationModel>()
                  .toList();
            } catch (e) {
              print('Error mapping conversations: $e');
              return <ConversationModel>[];
            }
          });
    }
    
    return _conversationsStream!;
  }
  
  // Get messages for a specific conversation
  Stream<List<Message>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Message(
              text: data['text'] ?? '',
              isUser: data['senderId'] == currentUserId,
              timestamp: (data['timestamp'] as Timestamp).toDate(),
            );
          }).toList();
        });
  }
  
  // Send a message
  Future<void> sendMessage(String conversationId, String text) async {
    if (currentUserId == null) return;
    
    final timestamp = DateTime.now();
    
    // Get conversation document
    final conversationDoc = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .get();
    
    if (!conversationDoc.exists) {
      print('Error: Conversation does not exist');
      return;
    }
    
    // Extract participants
    final participants = List<String>.from(
        conversationDoc.data()?['participants'] ?? []
    );
    
    // Create unread status map (true for all participants except sender)
    Map<String, bool> unreadStatus = {};
    for (String uid in participants) {
      unreadStatus[uid] = uid != currentUserId;
    }
    
    // Start a batch write for consistency
    final batch = _firestore.batch();
    
    // Add message to conversation
    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(); // Let Firestore generate ID
        
    batch.set(messageRef, {
      'text': text,
      'senderId': currentUserId,
      'timestamp': Timestamp.fromDate(timestamp),
    });
    
    // Update conversation with last message info
    batch.update(_firestore
        .collection('conversations')
        .doc(conversationId), {
          'lastMessage': text,
          'lastMessageTime': Timestamp.fromDate(timestamp),
          'unreadStatus': unreadStatus,
        });
        
    // Commit the batch
    await batch.commit();
  }
  
  // Create a new conversation or get existing one
  Future<String> createConversation(List<String> participantIds) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    // Ensure current user is included in participants
    if (!participantIds.contains(currentUserId)) {
      participantIds.add(currentUserId!);
    }
    
    // Check if a conversation exists where all participants are present
    final query = await _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .get();
    
    // Check each conversation if it contains all the required participants
    for (var doc in query.docs) {
      final conversationParticipants = List<String>.from(doc.data()['participants'] ?? []);
      
      // Check if the conversation has exactly the same participants
      if (conversationParticipants.length == participantIds.length &&
          conversationParticipants.toSet().containsAll(participantIds)) {
        return doc.id;
      }
    }
    
    // Create unread status map (false for all participants initially)
    Map<String, bool> unreadStatus = {};
    for (String uid in participantIds) {
      unreadStatus[uid] = false;
    }
    
    // Create new conversation
    final doc = await _firestore.collection('conversations').add({
      'participants': participantIds,
      'lastMessage': '',
      'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      'unreadStatus': unreadStatus,
      'createdAt': Timestamp.fromDate(DateTime.now()), 
    });
    
    // Clear the cache to ensure the new conversation appears
    clearCache();
    
    return doc.id;
  }
  
  // Mark conversation as read for current user
  Future<void> markAsRead(String conversationId) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .update({
          'unreadStatus.$currentUserId': false,
        });
  }
  
  // Get other user's ID in a 1:1 conversation
  String getOtherUserId(List<String> participants) {
    if (currentUserId == null) return '';
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }
}