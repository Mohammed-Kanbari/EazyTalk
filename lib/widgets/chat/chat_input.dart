import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSend;
  
  const ChatInput({
    Key? key,
    required this.controller,
    required this.canSend,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              controller: controller,
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
              onSubmitted: (_) => canSend ? onSend() : null,
            ),
          ),
          Container(
            height: 38.h,
            width: 38.w,
            decoration: BoxDecoration(
              color: canSend 
                  ? AppColors.primary
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.send, color: Colors.white, size: 18.sp),
              onPressed: canSend ? onSend : null,
            ),
          ),
        ],
      ),
    );
  }
}