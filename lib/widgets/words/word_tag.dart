import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class WordTag extends StatelessWidget {
  final String text;
  final Color color;
  final bool isDarkMode;
  
  const WordTag({
    Key? key,
    required this.text,
    required this.color,
    this.isDarkMode = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Get theme-appropriate text color
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    
    // Adjust shadow for dark mode
    final shadowColor = color.withOpacity(isDarkMode ? 0.3 : 0.5);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}