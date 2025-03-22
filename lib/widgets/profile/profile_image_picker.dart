import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'dart:io';
import 'package:eazytalk/core/theme/app_colors.dart';

class ProfileImagePicker extends StatelessWidget {
  final String? profileImageBase64;
  final File? imageFile;
  final VoidCallback onPickImage;
  
  const ProfileImagePicker({
    Key? key,
    this.profileImageBase64,
    this.imageFile,
    required this.onPickImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // Profile image container
          GestureDetector(
            onTap: onPickImage,
            child: Container(
              width: 140.w,
              height: 140.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                border: Border.all(
                  color: const Color(0xFFC7C7C7),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildProfileImage(),
            ),
          ),
          
          // Camera button overlay
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onPickImage,
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to display the appropriate image
  Widget _buildProfileImage() {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
      );
    } else if (profileImageBase64 != null) {
      return Image.memory(
        base64Decode(profileImageBase64!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.person,
          size: 60.sp,
          color: Colors.grey,
        ),
      );
    } else {
      return Icon(
        Icons.person,
        size: 60.sp,
        color: Colors.grey,
      );
    }
  }
}