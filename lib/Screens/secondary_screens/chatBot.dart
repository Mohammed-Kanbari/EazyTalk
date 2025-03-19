import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isTyping = false;
  bool _modelInitialized = false;
  bool _canSendMessage = false;
  
  final String _apiKey = 'AIzaSyCd5WJ1RQArrz2mZ1P-voS6hIqNgglx8iI';
  late GenerativeModel _model;
  late ChatSession _chatSession;
  
  @override
  void initState() {
    super.initState();
    _initializeModel();
    
    // Add listener to text controller to update send button state
    _messageController.addListener(_updateSendButtonState);
    
    _messages.add(
      Message(
        text: "Hello! I am your AI assistant.\nFeel free to ask me anything.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
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

  void _initializeModel() {
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1000,
        ),
      );
      
      _chatSession = _model.startChat(
        history: [
          Content.text("You are EazyChat AI, a helpful and friendly assistant."),
        ],
      );
      
      _modelInitialized = true;
      print("Gemini model initialized successfully");
    } catch (e) {
      print("Error initializing Gemini model: $e");
      setState(() {
        _messages.add(
          Message(
            text: "Failed to initialize AI model: ${e.toString()}",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
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

  // Add this method to clear chat
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

  Future<void> _testAPI() async {
    try {
      final content = [Content.text("Hello!")];
      final response = await _model.generateContent(content);
      setState(() {
        _messages.add(
          Message(
            text: "API connection successful! You can now chat with the AI.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          Message(
            text: "API test failed: ${e.toString()}",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  Future<void> _sendMessageToGemini(String message) async {
    if (!_modelInitialized) {
      setState(() {
        _messages.add(
          Message(
            text: "AI model is not initialized. Please restart the app or check logs for details.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      return;
    }
    
    try {
      setState(() {
        _isTyping = true;
      });
      
      final response = await _chatSession.sendMessage(
        Content.text(message),
      );
      
      final responseText = response.text;
      
      setState(() {
        _messages.add(
          Message(
            text: responseText ?? "Sorry, I couldn't generate a response.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isTyping = false;
      });
      
      _scrollToBottom();
    } catch (e) {
      print("Gemini API error: $e");
      
      String errorMsg = e.toString();
      if (errorMsg.contains("API key")) {
        errorMsg = "Invalid API key or API key not set up correctly.";
      } else if (errorMsg.contains("network")) {
        errorMsg = "Network error. Please check your internet connection.";
      } else if (errorMsg.contains("quota")) {
        errorMsg = "API quota exceeded. Please try again later.";
      } else if (errorMsg.length > 100) {
        errorMsg = "${errorMsg.substring(0, 100)}...";
      }
      
      setState(() {
        _messages.add(
          Message(
            text: "Sorry, there was an error: $errorMsg",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final message = _messageController.text.trim();
    setState(() {
      _messages.add(
        Message(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
      _canSendMessage = false;
    });
    
    _scrollToBottom();
    _sendMessageToGemini(message);
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

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time).toLowerCase();
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
              Padding(
                padding: EdgeInsets.only(top: 27.h, left: 28.w, right: 28.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/icons/back-arrow.png',
                        width: 22.w,
                        height: 22.h,
                      ),
                    ),
                    Text(
                      'EazyChat AI',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearChat, // Changed from _testAPI to _clearChat
                      child: Image.asset(
                        'assets/icons/message 1.png',
                        width: 24.w,
                        height: 24.h,
                      ),
                    ),
                  ],
                ),
              ),
              
              // AI Introduction Section
              Padding(
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
                                    color: Colors.black,
                                    fontFamily: 'DM Sans',
                                    fontSize: 16.sp,
                                  ),
                                ),
                                TextSpan(
                                  text: 'smart assistant',
                                  style: TextStyle(
                                    color: Color(0xFF00D0FF),
                                    fontFamily: 'DM Sans',
                                    fontSize: 16.sp,
                                  ),
                                ),
                                TextSpan(
                                  text: ' for effortless communication.',
                                  style: TextStyle(
                                    color: Colors.black,
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
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Sora',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset('assets/icons/chatbot 1.png', width: 85.w, height: 85.h,)
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
              
              // Chat Messages
              Expanded(
                child: Container(
                  color: Color(0xFFF1F3F5),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
              ),
              
              // Typing indicator
              if (_isTyping)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  alignment: Alignment.centerLeft,
                  color: Colors.white,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D0FF)),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'AI is thinking...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'DM Sans',
                          fontSize: 12.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Message input
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask me anything...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'DM Sans',
                            fontSize: 14.sp,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16.sp,
                        ),
                        maxLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _canSendMessage ? _sendMessage() : null,
                      ),
                    ),
                    Container(
                      height: 38.h,
                      width: 38.w,
                      decoration: BoxDecoration(
                        color: _canSendMessage 
                            ? Color(0xFF00D0FF)
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.send, color: Colors.white, size: 18.sp),
                        onPressed: _canSendMessage ? _sendMessage : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 0.75.sw,
        ),
        margin: EdgeInsets.only(
          bottom: 12.h,
          left: message.isUser ? 50.w : 0,
          right: message.isUser ? 0 : 50.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: message.isUser ? Color(0xFF00D0FF) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontFamily: 'DM Sans',
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: message.isUser ? Colors.white.withOpacity(0.8) : Colors.grey,
                    fontFamily: 'DM Sans',
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}