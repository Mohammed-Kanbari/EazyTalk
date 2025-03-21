import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class TipItem extends StatelessWidget {
  final String text;
  
  const TipItem({
    Key? key,
    required this.text,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppColors.primary,
            size: 24.sp,
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16.sp,
                height: 1.5,
                color: Colors.black87,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}