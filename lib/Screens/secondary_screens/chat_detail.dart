import 'package:eazytalk/models/conversation_model.dart';
import 'package:eazytalk/models/message_model.dart';
import 'package:eazytalk/services/chat/chat_service.dart';
import 'package:eazytalk/services/user/user_service.dart';
import 'package:eazytalk/widgets/chat/message_bubble.dart';
import 'package:eazytalk/widgets/chat/chat_input.dart';
import 'package:eazytalk/widgets/common/secondary_header.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';

class ChatDetail extends StatefulWidget {
  final ConversationModel conversation;
  
  const ChatDetail({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  
  bool _canSendMessage = false;
  String _otherUserName = 'User';
  String? _otherUserProfileImage;
  
  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateSendButtonState);
    _fetchOtherUserInfo();
    _markConversationAsRead();
  }
  
  @override
  void dispose() {
    _messageController.removeListener(_updateSendButtonState);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  // Update send button state based on message text
  void _updateSendButtonState() {
    final text = _messageController.text.trim();
    final canSend = text.isNotEmpty;
    
    if (canSend != _canSendMessage) {
      setState(() {
        _canSendMessage = canSend;
      });
    }
  }
  
  // Fetch other user's profile info
  Future<void> _fetchOtherUserInfo() async {
    if (_chatService.currentUserId == null) return;
    
    // Find the other participant's ID
    final otherUserId = widget.conversation.participants
        .firstWhere((id) => id != _chatService.currentUserId, 
                   orElse: () => '');
    
    if (otherUserId.isEmpty) return;
    
    try {
      // Fetch user data from Firestore
      final userData = await _userService.fetchUserProfileById(otherUserId);
      
      setState(() {
        _otherUserName = userData['userName'] ?? 'User';
        _otherUserProfileImage = userData['profileImageBase64'];
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }
  
  // Mark conversation as read
  Future<void> _markConversationAsRead() async {
    await _chatService.markAsRead(widget.conversation.id);
  }
  
  // Send message
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final messageText = _messageController.text.trim();
    
    // Clear text field
    _messageController.clear();
    setState(() {
      _canSendMessage = false;
    });
    
    // Send message
    await _chatService.sendMessage(widget.conversation.id, messageText);
    
    // Scroll to bottom
    _scrollToBottom();
  }
  
  // Scroll to bottom of chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // Using 0 because we're ordering messages by descending timestamp
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Header with user info
              _buildHeader(),
              
              // Chat messages
              Expanded(
                child: Container(
                  color: AppColors.backgroundGrey,
                  child: StreamBuilder<List<Message>>(
                    stream: _chatService.getMessages(widget.conversation.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading messages',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 16.sp,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }
                      
                      final messages = snapshot.data ?? [];
                      
                      if (messages.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.r),
                            child: Text(
                              'No messages yet. Say hello!',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Display newest message at the bottom
                        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(message: messages[index]);
                        },
                      );
                    },
                  ),
                ),
              ),
              
              // Message input
              ChatInput(
                controller: _messageController,
                canSend: _canSendMessage,
                onSend: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build header with user info
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.r),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20.sp,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          
          // User profile image
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.backgroundGrey,
            ),
            child: _otherUserProfileImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.memory(
                      base64Decode(_otherUserProfileImage!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 20.sp,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 20.sp,
                    color: Colors.grey,
                  ),
          ),
          SizedBox(width: 12.w),
          
          // User name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _otherUserName,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Online', // This could be dynamic based on user's online status
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12.sp,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          // Call button (could be implemented later)
          IconButton(
            icon: Icon(
              Icons.videocam,
              color: AppColors.primary,
              size: 24.sp,
            ),
            onPressed: () {
              // Implement video call functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video call feature coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }
}