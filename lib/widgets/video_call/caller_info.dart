// lib/widgets/video_call/caller_info.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class CallerInfo extends StatelessWidget {
  final String name;
  final String? profileImageBase64;
  final String statusText;
  final bool isDarkMode;
  
  const CallerInfo({
    Key? key,
    required this.name,
    this.profileImageBase64,
    required this.statusText,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 32.w),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black54 : Colors.white54,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile image
          _buildProfileImage(),
          SizedBox(height: 16.h),
          
          // Name
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          
          // Status text
          Text(
            statusText,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16.sp,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileImage() {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
      ),
      child: profileImageBase64 != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(50.r),
              child: Image.memory(
                base64Decode(profileImageBase64!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
              ),
            )
          : _buildDefaultIcon(),
    );
  }
  
  Widget _buildDefaultIcon() {
    return Center(
      child: Icon(
        Icons.person,
        size: 50.sp,
        color: isDarkMode ? Colors.grey[600] : Colors.grey,
      ),
    );
  }
}