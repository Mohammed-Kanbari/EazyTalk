import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/models/word_model.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class SectionWordCard extends StatelessWidget {
  final WordModel word;
  final VoidCallback onTap;
  
  const SectionWordCard({
    Key? key,
    required this.word,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Sign image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                word.imagePath,
                width: 60.w,
                height: 60.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.sign_language,
                      size: 30.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Word and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    word.description,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.sp,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow icon
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}