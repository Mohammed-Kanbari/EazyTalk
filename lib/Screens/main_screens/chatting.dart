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
import 'package:eazytalk/widgets/signs/section_search_bar.dart';
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

  // Stream subscription for better management
  late Stream<List<ConversationModel>> _conversationsStream;
  bool _isError = false;
  String _errorMessage = '';

  // Cache for user data to avoid repetitive Firestore queries
  final Map<String, Map<String, dynamic>> _userCache = {};

  @override
  void initState() {
    super.initState();
    // Initialize a stable stream reference
    _conversationsStream = _chatService.getConversations();
    print('Initialized conversations stream');
  }

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
                    Expanded(
                      child: SectionSearchBar(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 15.w),
                    // Add button for new conversation
                    GestureDetector(
                      onTap: _showContactsModal,
                      child: Container(
                        width: 55.w,
                        height: 55.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 30.sp,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 30.h),

              // Conversations list - using a stable stream reference
              Expanded(
                child: StreamBuilder<List<ConversationModel>>(
                  // Use the stored stream reference that doesn't change on rebuild
                  stream: _conversationsStream,
                  builder: (context, snapshot) {
                    // Debugging
                    print('StreamBuilder state: ${snapshot.connectionState}');
                    if (snapshot.hasData)
                      print('Data count: ${snapshot.data!.length}');
                    if (snapshot.hasError)
                      print('Stream error: ${snapshot.error}');

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (snapshot.hasError || _isError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48.sp,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              _errorMessage.isNotEmpty
                                  ? _errorMessage
                                  : 'Error loading conversations',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 16.sp,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton(
                              onPressed: _retry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
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
                    final filteredConversations =
                        _filterConversations(conversations);

                    if (filteredConversations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No conversations match "$_searchQuery"',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    // Build the actual conversation list
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 28.w),
                      itemCount: filteredConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = filteredConversations[index];
                        return FutureBuilder<Map<String, dynamic>>(
                          future: _getOtherUserInfo(conversation),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: Container(
                                  height: 70.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }

                            if (!userSnapshot.hasData ||
                                userSnapshot.data!.isEmpty) {
                              return SizedBox.shrink();
                            }

                            final userData = userSnapshot.data!;

                            return ConversationItem(
                              name: userData['userName'] ?? 'User',
                              profileImage: userData['profileImageBase64'],
                              lastMessage: conversation.lastMessage,
                              time: conversation.lastMessageTime,
                              isUnread: conversation.unreadStatus[
                                      _chatService.currentUserId] ??
                                  false,
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
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Chatbot()));
        },
      ),
    );
  }

  // Retry method that properly refreshes the stream
  void _retry() {
    setState(() {
      _isError = false;
      _errorMessage = '';
      // Force the ChatService to recreate its stream
      _chatService.clearCache();
      // Get a fresh stream reference
      _conversationsStream = _chatService.getConversations();
    });

    print('Retrying with fresh stream');
  }

  // Filter conversations based on search query
List<ConversationModel> _filterConversations(List<ConversationModel> conversations) {
  if (_searchQuery.isEmpty) {
    return conversations;
  }
  
  return conversations.where((conv) {
    // Search in message content
    if (conv.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase())) {
      return true;
    }
    
    // Search in user names
    final otherUserId = _getOtherParticipantId(conv);
    if (_userCache.containsKey(otherUserId)) {
      final userName = _userCache[otherUserId]!['userName'] ?? '';
      if (userName.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return true;
      }
    }
    
    return false;
  }).toList();
}

  // Get the other user's information for a conversation
  Future<Map<String, dynamic>> _getOtherUserInfo(
      ConversationModel conversation) async {
    if (_chatService.currentUserId == null) return {};

    // Find the other participant's ID
    final otherUserId = _getOtherParticipantId(conversation);

    if (otherUserId.isEmpty) return {};

    // Check cache first
    if (_userCache.containsKey(otherUserId)) {
      return _userCache[otherUserId]!;
    }

    try {
      // Fetch user data from Firestore
      final userData = await _userService.fetchUserProfileById(otherUserId);
      // Cache the result
      _userCache[otherUserId] = userData;
      return userData;
    } catch (e) {
      print('Error fetching user data: $e');
      return {'userName': 'User', 'profileImageBase64': null};
    }
  }

  // Helper method to get the other participant's ID
  String _getOtherParticipantId(ConversationModel conversation) {
    return conversation.participants.firstWhere(
      (id) => id != _chatService.currentUserId,
      orElse: () => '',
    );
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
      isScrollControlled:
          true, // Make the modal take up to 90% of screen height
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6, // Initial height is 60% of screen
        minChildSize: 0.3, // Minimum height is 30% of screen
        maxChildSize: 0.9, // Maximum height is 90% of screen
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(
                    bottom: 20.h,
                    left: MediaQuery.of(context).size.width * 0.4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Text(
                'New Conversation',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _userService.fetchAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 40.sp,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'Error loading users',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final users = snapshot.data ?? [];

                    if (users.isEmpty ||
                        (users.length == 1 &&
                            users[0]['id'] == _chatService.currentUserId)) {
                      return Center(
                        child: Text(
                          'No other users found',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14.sp,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        // Skip current user
                        if (user['id'] == _chatService.currentUserId) {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 12.w),
                          leading: CircleAvatar(
                            radius: 25.r,
                            backgroundColor: AppColors.backgroundGrey,
                            backgroundImage: user['profileImageBase64'] != null
                                ? MemoryImage(
                                    base64Decode(user['profileImageBase64']),
                                  )
                                : null,
                            child: user['profileImageBase64'] == null
                                ? Text(
                                    (user['userName'] ?? 'User')
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            user['userName'] ?? 'User',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => _createAndNavigateToConversation(user),
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
    );
  }

  // Create a conversation and navigate to chat
  Future<void> _createAndNavigateToConversation(
      Map<String, dynamic> user) async {
    Navigator.pop(context); // Close the modal

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );

      // Create new conversation
      final conversationId =
          await _chatService.createConversation([user['id']]);
      // Get conversation details
      final conversation = await _getConversation(conversationId);

      // Dismiss loading indicator
      if (mounted) Navigator.pop(context);

      // Cache user data to avoid additional Firestore queries
      _userCache[user['id']] = user;

      // Navigate to chat
      if (mounted) {
        _navigateToChat(conversation);
      }
    } catch (e) {
      // Dismiss loading indicator
      if (mounted) Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating conversation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
