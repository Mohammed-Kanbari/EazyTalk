import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class TranscriptionTextArea extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onCopy;
  final VoidCallback onClear;
  final bool isDarkMode;
  
  const TranscriptionTextArea({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onCopy,
    required this.onClear,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode 
        ? AppColors.primary.withOpacity(0.15)
        : AppColors.primary.withOpacity(0.11);
    
    final textColor = AppColors.getTextPrimaryColor(context);
    final hintColor = isDarkMode 
        ? Colors.grey[600]
        : const Color(0xFF9E9E9E);
    
    final iconColor = isDarkMode
        ? Colors.grey[400]
        : const Color(0xFF9E9E9E);
    
    return Container(
      width: double.infinity,
      height: 275.h,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: TextField(
                controller: controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14.sp,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  fillColor: const Color.fromARGB(0, 255, 255, 255),
                  border: InputBorder.none,
                  hintText: 'Your transcribed text will appear here.',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'DM Sans',
                    color: hintColor,
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: Icon(
                  Icons.copy,
                  size: 24.sp,
                  color: iconColor,
                ),
                onTap: onCopy,
              ),
              GestureDetector(
                child: Icon(
                  Icons.delete_outline,
                  size: 24.sp,
                  color: iconColor,
                ),
                onTap: onClear,
              ),
            ],
          ),
        ],
      ),
    );
  }
}