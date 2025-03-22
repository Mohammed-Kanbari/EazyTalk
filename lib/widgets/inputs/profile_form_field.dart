import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class ProfileFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final String hintText;
  
  const ProfileFormField({
    Key? key,
    required this.label,
    required this.controller,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    required this.prefixIcon,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 9.h),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'DM Sans',
            color: enabled ? Colors.black : Colors.black54,
          ),
          decoration: InputDecoration(
            filled: !enabled,
            fillColor: !enabled ? const Color(0xFFF5F5F5) : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 15.h,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w400,
              color: AppColors.iconGrey,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: AppColors.iconGrey,
              size: 20.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.iconGrey,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ],
    );
  }
}