import 'package:eazytalk/models/conversation_model.dart';
import 'package:eazytalk/models/message_model.dart';
import 'package:eazytalk/services/chat/chat_service.dart';
import 'package:eazytalk/services/user/user_service.dart';
import 'package:eazytalk/widgets/chat/message_bubble.dart';
import 'package:eazytalk/widgets/chat/chat_input.dart';
import 'package:eazytalk/widgets/common/secondary_header.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:eazytalk/services/video_call/call_service.dart';
import 'package:eazytalk/Screens/secondary_screens/video_call/video_call_screen.dart';

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
  final CallService _callService = CallService();


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
        .firstWhere((id) => id != _chatService.currentUserId, orElse: () => '');

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


  // Helper method to get the other participant's ID
  String _getOtherParticipantId(ConversationModel conversation) {
    return conversation.participants
        .firstWhere((id) => id != _chatService.currentUserId, orElse: () => '');
  }

  // Now add this new method to handle video call initiation
Future<void> _initiateVideoCall() async {
  final localizations = AppLocalizations.of(context);
  
  try {
    // Get the other user's ID
    final otherUserId = _getOtherParticipantId(widget.conversation);
    
    if (otherUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.translate('cannot_find_recipient'))),
      );
      return;
    }
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              localizations.translate('connecting_call'),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
                color: AppColors.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
    
    // Fetch user data for the other participant
    final userData = await _userService.fetchUserProfileById(otherUserId);

    // Make a call
    final call = await _callService.makeCall(
      receiverId: otherUserId,
      receiverName: userData['userName'] ?? 'User',
      receiverProfileImageBase64: userData['profileImageBase64'],
      isVideoEnabled: true,
    );
    
    // Hide loading indicator
    Navigator.pop(context);
    
    if (call != null && mounted) {
      // Navigate to video call screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(call: call),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.translate('call_failed'))),
      );
    }
  } catch (e) {
    // Hide loading indicator if showing
    if (mounted) {
      Navigator.pop(context);
    }
    
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${localizations.translate('call_failed')}: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
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
                  color: isDarkMode ? const Color(0xFF121212) : AppColors.backgroundGrey,
                  child: StreamBuilder<List<Message>>(
                    stream: _chatService.getMessages(widget.conversation.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              SizedBox(height: 16.h),
                              Text(
                                localizations.translate('loading'),
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14.sp,
                                  color: AppColors.getTextPrimaryColor(context),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            localizations.translate('error_loading'),
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
                              localizations.translate('no_messages'),
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 16.sp,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Display newest message at the bottom
                        padding: EdgeInsets.symmetric(
                            horizontal: 28.w, vertical: 16.h),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Container(
      padding:
          EdgeInsets.only(top: 27.h, bottom: 10.h, right: 28.w, left: 28.w),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(isRTL ? 3.14159 : 0),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/icons/back-arrow.png',
                width: 22.w,
                height: 22.h,
                color: textColor,
                errorBuilder: (context, error, stackTrace) => Icon(
                  isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  size: 20.sp,
                  color: textColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),

          // User profile image
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode ? const Color(0xFF2A2A2A) : AppColors.backgroundGrey,
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
                        color: isDarkMode ? Colors.grey[600] : Colors.grey,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 20.sp,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey,
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
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: isRTL ? TextAlign.right : TextAlign.left,
                ),
              ],
            ),
          ),

          // Call button (could be implemented later)
          GestureDetector(
            onTap: _initiateVideoCall,
              child: Image.asset(
            'assets/icons/camera.png',
            width: 28.w,
            height: 28.h,
            color: isDarkMode ? Colors.white : null,
          )),
         
        ],
      ),
    );
  }
}