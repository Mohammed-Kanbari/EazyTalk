import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class InfoCard extends StatelessWidget {
  final String? title;
  final String content;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  
  const InfoCard({
    Key? key,
    this.title,
    required this.content,
    required this.icon,
    this.backgroundColor = const Color(0xFFF1F3F5),
    this.borderColor = const Color(0xFFE8E8E8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ... [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  title!,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ] else ... [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: Colors.black54,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
              ],
            ),
          ],
          Padding(
            padding: title == null 
                ? EdgeInsets.only(left: 28.w) 
                : EdgeInsets.zero,
            child: Text(
              content,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: title == null ? 12.sp : 14.sp,
                color: title == null ? Colors.black54 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}