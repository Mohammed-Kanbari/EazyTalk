import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class SectionSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  
  const SectionSearchBar({
    Key? key,
    required this.onChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search words...',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w400,
            color: AppColors.iconGrey,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary,
            size: 20.sp,
          ),
          filled: true,
          fillColor: AppColors.backgroundGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 1.0,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 14.h,
            horizontal: 16.w,
          ),
        ),
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14.sp,
          color: Colors.black87,
        ),
      ),
    );
  }
}