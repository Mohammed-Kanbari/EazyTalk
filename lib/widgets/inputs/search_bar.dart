import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class CustomSearchBar  extends StatelessWidget {
  final String hintText;
  final Function(String)? onChanged;
  final VoidCallback? onSubmitted;

  const CustomSearchBar ({
    Key? key,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 35.h,
      child: TextField(
        style: TextStyle(
          fontFamily: 'DM Sans',
          color: Colors.black,
          fontSize: 14.sp,
        ),
        onChanged: onChanged,
        onSubmitted: (_) => onSubmitted?.call(),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
          suffixIcon: Icon(Icons.search, color: AppColors.iconGrey),
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'DM Sans',
            color: AppColors.iconGrey,
            fontSize: 14.sp,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}