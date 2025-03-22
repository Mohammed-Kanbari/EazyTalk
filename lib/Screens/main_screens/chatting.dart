import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eazytalk/Screens/secondary_screens/chat_detail.dart';
import 'package:eazytalk/models/conversation_model.dart';
import 'package:eazytalk/screens/secondary_screens/chatbot.dart';
import 'package:eazytalk/services/chat/chat_service.dart';
import 'package:eazytalk/services/user/user_service.dart';
import 'package:eazytalk/widgets/buttons/gradient_fab.dart';
import 'package:eazytalk/widgets/chat/conversation_item.dart';
import 'package:eazytalk/widgets/common/screen_header.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/widgets/inputs/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Chatting extends StatefulWidget {
  const Chatting({super.key});

  @override
  State<Chatting> createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen title
              const ScreenHeader(title: 'EazyTalk'),
              SizedBox(height: 30.h),
          
              // Search and add bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Row(
                  children: [
                    Flexible(
                      child: CustomSearchBar(
                        hintText: 'Search conversations..',
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 17.w),
                    // Add button for new conversation
                    GestureDetector(
                      onTap: _showContactsModal,
                      child: Container(
                        width: 35.w,
                        height: 35.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.backgroundGrey,
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppColors.textPrimary,
                          size: 16,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              
              // Conversations list
              Expanded(
                child: StreamBuilder<List<ConversationModel>>(
                  stream: _chatService.getConversations(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading conversations',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16.sp,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }
                    
                    final conversations = snapshot.data ?? [];
                    
                    if (conversations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 60.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No conversations yet',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Tap + to start chatting',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 14.sp,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // Filter conversations by search query
                    final filteredConversations = _searchQuery.isEmpty
                        ? conversations
                        : conversations.where((conv) {
                            // This would be improved with actual contact names
                            return conv.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
                          }).toList();
                    
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 28.w),
                      itemCount: filteredConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = filteredConversations[index];
                        return FutureBuilder<Map<String, dynamic>>(
                          future: _getOtherUserInfo(conversation),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            
                            return ConversationItem(
                              name: userSnapshot.data!['userName'] ?? 'User',
                              profileImage: userSnapshot.data!['profileImageBase64'],
                              lastMessage: conversation.lastMessage,
                              time: conversation.lastMessageTime,
                              isUnread: conversation.unreadStatus[_chatService.currentUserId] ?? false,
                              onTap: () => _navigateToChat(conversation),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // AI Chatbot button
      floatingActionButton: GradientFloatingActionButton(
        child: Image.asset(
          'assets/icons/chatbot 1.png',
          width: 35.w,
          height: 35.h,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Chatbot()));
        },
      ),
    );
  }
  
  // Get the other user's information for a conversation
  Future<Map<String, dynamic>> _getOtherUserInfo(ConversationModel conversation) async {
    if (_chatService.currentUserId == null) return {};
    
    // Find the other participant's ID
    final otherUserId = conversation.participants
        .firstWhere((id) => id != _chatService.currentUserId, 
                   orElse: () => '');
    
    if (otherUserId.isEmpty) return {};
    
    try {
      // Fetch user data from Firestore
      final userData = await _userService.fetchUserProfileById(otherUserId);
      return userData;
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }
  
  // Navigate to chat detail screen
  void _navigateToChat(ConversationModel conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetail(conversation: conversation),
      ),
    );
  }
  
  // Show modal to select contact for new conversation
  void _showContactsModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Conversation',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),
            
            // This would be expanded with an actual contacts list
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _userService.fetchAllUsers(), // You'll need to implement this
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final users = snapshot.data ?? [];
                
                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }
                
                return Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      // Skip current user
                      if (user['id'] == _chatService.currentUserId) {
                        return const SizedBox.shrink();
                      }
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['profileImageBase64'] != null
                              ? MemoryImage(
                                  base64Decode(user['profileImageBase64']),
                                )
                              : null,
                          child: user['profileImageBase64'] == null
                              ? Text(user['userName'][0].toUpperCase())
                              : null,
                        ),
                        title: Text(
                          user['userName'] ?? 'User',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16.sp,
                          ),
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          // Create new conversation
                          final conversationId = await _chatService.createConversation([user['id']]);
                          // Navigate to chat
                          if (mounted) {
                            final conversation = await _getConversation(conversationId);
                            _navigateToChat(conversation);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Get conversation by ID
  Future<ConversationModel> _getConversation(String conversationId) async {
    final doc = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .get();
    
    return ConversationModel.fromFirestore(
      doc.data() ?? {}, 
      doc.id,
    );
  }
}