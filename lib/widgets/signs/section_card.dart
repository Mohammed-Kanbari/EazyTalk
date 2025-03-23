import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/models/section_model.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class SectionCard extends StatelessWidget {
  final SectionModel section;
  final VoidCallback onTap;
  final bool isDarkMode;
  
  const SectionCard({
    Key? key,
    required this.section,
    required this.onTap,
    this.isDarkMode = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextPrimaryColor(context);
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.black54;
    
    // Apply darker shadow for dark mode or lighter for light mode
    final shadow = BoxShadow(
      color: isDarkMode 
          ? Colors.black.withOpacity(0.3)
          : Colors.black.withOpacity(0.08),
      blurRadius: 8,
      spreadRadius: isDarkMode ? 2 : 1,
      offset: Offset(0, 3),
    );
    
    // Adjust section color for dark mode if needed
    final sectionColor = isDarkMode 
        ? _getDarkModeColor(section.color)
        : section.color;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: sectionColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [shadow],
        ),
        padding: EdgeInsets.all(15.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(isDarkMode ? 0.3 : 0.6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 14.sp,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                // Image with error handling
                Image.asset(
                  section.iconPath,
                  width: 32.w,
                  height: 32.h,
                  color: isDarkMode ? Colors.white : null,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.category,
                    size: 32.sp,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    section.subtitle,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10.sp,
                      color: subtitleColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to make section colors appropriate for dark mode
  Color _getDarkModeColor(Color originalColor) {
    // If color is too light, darken it for better visibility in dark mode
    final hsl = HSLColor.fromColor(originalColor);
    
    // Lower lightness for dark mode to make colors deeper
    if (hsl.lightness > 0.5) {
      return hsl.withLightness(0.3).toColor();
    } else if (hsl.lightness > 0.3) {
      return hsl.withLightness(0.25).toColor();
    }
    
    // If already dark enough, return as is
    return originalColor;
  }
}