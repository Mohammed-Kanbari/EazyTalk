import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/models/message_model.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // User message bubble is always primary color
    // Other user's message bubble is white in light mode, darker gray in dark mode
    final backgroundColor = message.isUser 
        ? AppColors.primary 
        : (isDarkMode ? const Color(0xFF2A2A2A) : Colors.white);
    
    // Text color is white for user messages, theme-aware for other messages
    final textColor = message.isUser 
        ? Colors.white 
        : AppColors.getTextPrimaryColor(context);
    
    // Time color is semi-transparent based on bubble color
    final timeColor = message.isUser 
        ? Colors.white.withOpacity(0.8) 
        : (isDarkMode ? Colors.grey[400] : Colors.grey);

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
          color: backgroundColor,
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
                  color: textColor,
                  fontFamily: 'DM Sans',
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  message.formattedTime,
                  style: TextStyle(
                    color: timeColor,
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