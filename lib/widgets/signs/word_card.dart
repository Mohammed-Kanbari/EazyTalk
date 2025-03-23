import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/models/word_model.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class WordCard extends StatelessWidget {
  final WordModel word;
  final Color? backgroundColor;
  final VoidCallback onTap;
  
  const WordCard({
    Key? key,
    required this.word,
    this.backgroundColor = const Color(0xFFB1EEFF),
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardBgColor = backgroundColor ?? AppColors.getWordCardBackgroundColor(context);
    
    // Apply darker shadow for dark mode
    final shadowColor = isDarkMode 
        ? Colors.black.withOpacity(0.2)
        : Colors.black.withOpacity(0.08);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160.w,
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              spreadRadius: isDarkMode ? 2 : 1,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            word.word,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}