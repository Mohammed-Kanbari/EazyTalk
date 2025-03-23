import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/models/word_model.dart';
import 'package:eazytalk/widgets/words/word_tag.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class WordInfoCard extends StatelessWidget {
  final String word;
  final String? translation;
  final String difficultyLevel;
  final Color difficultyColor;
  final bool isCommonPhrase;
  final bool isDarkMode;
  
  const WordInfoCard({
    Key? key,
    required this.word,
    this.translation,
    required this.difficultyLevel,
    required this.difficultyColor,
    required this.isCommonPhrase,
    this.isDarkMode = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Get theme-appropriate colors
    final backgroundColor = isDarkMode ? AppColors.getSurfaceColor(context) : Colors.white;
    final textColor = AppColors.getTextPrimaryColor(context);
    final borderColor = isDarkMode ? Color(0xFF323232) : Color(0xFFE8E8E8);
    final translationColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    
    
    // Adjust shadow for dark mode
    final shadow = BoxShadow(
      color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
      blurRadius: 12,
      spreadRadius: isDarkMode ? 1 : 2,
      offset: Offset(0, 5),
    );
    
    // Prepare tag colors
    final commonPhraseColor = isDarkMode 
        ? AppColors.darkDefaultSectionColor 
        : Color(0xFFE6DAFF);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [shadow],
      ),
      child: Column(
        children: [
          // Arabic word title
          Text(
            word,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),

          // Translation text (if available)
          if (translation != null && translation!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 6.h, bottom: 12.h),
              child: Text(
                translation!,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: translationColor,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Spacing
          SizedBox(
            height: translation != null && translation!.isNotEmpty ? 8.h : 20.h,
          ),

          // Tags row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Difficulty level tag
              WordTag(
                text: difficultyLevel,
                color: difficultyColor,
                isDarkMode: isDarkMode,
              ),
              SizedBox(width: 16.w), // Spacing between tags
              
              // Common phrase tag (if applicable)
              if (isCommonPhrase)
                WordTag(
                  text: 'عبارة شائعة',
                  color: commonPhraseColor,
                  isDarkMode: isDarkMode,
                ),
            ],
          ),
        ],
      ),
    );
  }
}