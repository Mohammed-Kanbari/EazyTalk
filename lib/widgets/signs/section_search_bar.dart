import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class SectionSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  
  const SectionSearchBar({
    Key? key,
    required this.onChanged,
    this.hintText = ''
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: TextField(
        autofocus: false,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w400,
            color: AppColors.getIconGreyColor(context),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary,
            size: 20.sp,
          ),
          filled: true,
          fillColor: isDarkMode ? const Color(0xFF2A2A2A) : AppColors.backgroundGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 14.h,
            horizontal: 16.w,
          ),
        ),
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14.sp,
          color: AppColors.getTextPrimaryColor(context),
        ),
      ),
    );
  }
}