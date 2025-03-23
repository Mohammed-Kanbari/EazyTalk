import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class ModalHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  
  const ModalHeader({
    Key? key,
    required this.title,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 27.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Placeholder to maintain centering
          Container(width: 28.w, height: 28.h),
          
          // Title in the center
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          // Close button (X icon)
          GestureDetector(
            onTap: onClose,
            child: Icon(Icons.close, size: 28.sp),
          ),
        ],
      ),
    );
  }
}