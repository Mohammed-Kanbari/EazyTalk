import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/models/message_model.dart';
import 'package:eazytalk/services/api/gemini_service.dart';
import 'package:eazytalk/widgets/chat/message_bubble.dart';
import 'package:eazytalk/widgets/chat/typing_indicator.dart';
import 'package:eazytalk/widgets/chat/chat_input.dart';
import 'package:eazytalk/widgets/common/secondary_header.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  final GeminiService _geminiService = GeminiService();
  
  bool _isTyping = false;
  bool _canSendMessage = false;
  
  @override
  void initState() {
    super.initState();
    _initializeChat();
    _messageController.addListener(_updateSendButtonState);
  }
  
  Future<void> _initializeChat() async {
    // Initialize the Gemini model
    final initialized = await _geminiService.initializeModel();
    
    // Add welcome message
    setState(() {
      _messages.add(
        Message(
          text: "Hello! I am your AI assistant.\nFeel free to ask me anything.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      
      // If initialization failed, add error message
      if (!initialized) {
        _messages.add(
          Message(
            text: "Failed to initialize AI model. Please restart the app.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      }
    });
  }
  
  void _updateSendButtonState() {
    final text = _messageController.text.trim();
    final canSend = text.isNotEmpty;
    
    if (canSend != _canSendMessage) {
      setState(() {
        _canSendMessage = canSend;
      });
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_updateSendButtonState);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat'),
        content: Text('Are you sure you want to clear the chat history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // Keep only the initial welcome message
                _messages.clear();
                _messages.add(
                  Message(
                    text: "Hello! I am your AI assistant.\nFeel free to ask me anything.",
                    isUser: false,
                    timestamp: DateTime.now(),
                  ),
                );
              });
              Navigator.pop(context);
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final messageText = _messageController.text.trim();
    
    // Add user message to chat
    setState(() {
      _messages.add(
        Message(
          text: messageText,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
      _canSendMessage = false;
      _isTyping = true;
    });
    
    _scrollToBottom();
    
    // Get response from Gemini
    final response = await _geminiService.sendMessage(messageText);
    
    // Add AI response to chat
    setState(() {
      _messages.add(response);
      _isTyping = false;
    });
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Header
              SecondaryHeader(
                title: 'EazyChat AI',
                onBackPressed: () => Navigator.pop(context),
                actionWidget: GestureDetector(
                  onTap: _clearChat,
                  child: Image.asset(
                    'assets/icons/message 1.png',
                    width: 24.w,
                    height: 24.h,
                  ),
                ),
              ),
              
              // AI Introduction Section
              _buildIntroSection(),
              
              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
              
              // Chat Messages
              Expanded(
                child: Container(
                  color: AppColors.backgroundGrey,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(message: _messages[index]);
                    },
                  ),
                ),
              ),
              
              // Typing indicator
              if (_isTyping) const TypingIndicator(),
              
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

  Widget _buildIntroSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 30.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Your ',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'DM Sans',
                          fontSize: 16.sp,
                        ),
                      ),
                      TextSpan(
                        text: 'smart assistant',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontFamily: 'DM Sans',
                          fontSize: 16.sp,
                        ),
                      ),
                      TextSpan(
                        text: ' for effortless communication.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'DM Sans',
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'How may I help you today?',
                  style: AppTextStyles.chatHeading,
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/icons/chatbot 1.png',
            width: 85.w,
            height: 85.h,
          )
        ],
      ),
    );
  }
}