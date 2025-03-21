import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  
  const ErrorDisplay({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60.sp,
          ),
          SizedBox(height: 20.h),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16.sp,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.h),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 10.h,
              ),
            ),
            child: Text(
              'Try Again',
              style: AppTextStyles.buttonText,
            ),
          ),
        ],
      ),
    );
  }
}