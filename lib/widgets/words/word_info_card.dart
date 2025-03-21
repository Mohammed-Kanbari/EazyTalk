import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/models/word_model.dart';
import 'package:eazytalk/widgets/words/word_tag.dart';

class WordInfoCard extends StatelessWidget {
  final String word;
  final String? translation;
  final String difficultyLevel;
  final Color difficultyColor;
  final bool isCommonPhrase;
  
  const WordInfoCard({
    Key? key,
    required this.word,
    this.translation,
    required this.difficultyLevel,
    required this.difficultyColor,
    required this.isCommonPhrase,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Color(0xFFE8E8E8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
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
              color: Colors.black,
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
                  color: Colors.grey[600],
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
              WordTag(
                text: difficultyLevel,
                color: difficultyColor,
              ),
              SizedBox(width: 16.w), // Spacing between tags
              if (isCommonPhrase)
                WordTag(
                  text: 'عبارة شائعة',
                  color: Color(0xFFE6DAFF),
                ),
            ],
          ),
        ],
      ),
    );
  }
}