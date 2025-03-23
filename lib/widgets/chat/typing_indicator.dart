import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      alignment: Alignment.centerLeft,
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'AI is thinking...',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
              fontFamily: 'DM Sans',
              fontSize: 12.sp,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}