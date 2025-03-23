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
    // Check if we're in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Get theme-appropriate colors
    final backgroundColor = isDarkMode 
        ? AppColors.getSurfaceColor(context)
        : Colors.white;
    final textColor = AppColors.getTextPrimaryColor(context);
    final descriptionColor = isDarkMode 
        ? Colors.grey[400] 
        : Colors.black54;
    final borderColor = isDarkMode 
        ? Colors.grey[800] 
        : Colors.grey[200];
        
    // Custom shadow for dark vs light mode
    final shadow = BoxShadow(
      color: isDarkMode 
          ? Colors.black.withOpacity(0.2)
          : Colors.black.withOpacity(0.08),
      blurRadius: 8,
      spreadRadius: isDarkMode ? 1 : 1,
      offset: Offset(0, 3),
    );
    
    // Arrow container background color
    final arrowBgColor = isDarkMode 
        ? AppColors.primary.withOpacity(0.8)
        : AppColors.primary;
    
    // Arrow shadow color
    final arrowShadowColor = isDarkMode 
        ? AppColors.primary.withOpacity(0.5)
        : AppColors.primary.withOpacity(0.3);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor!),
          boxShadow: [shadow],
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
                    color: isDarkMode ? Color(0xFF2A2A2A) : Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.sign_language,
                      size: 30.sp,
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
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
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    word.description,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.sp,
                      color: descriptionColor,
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
                color: arrowBgColor,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: arrowShadowColor,
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