import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? profileImageBase64;
  final VoidCallback onEditPressed;
  
  const ProfileHeader({
    Key? key,
    required this.userName,
    required this.userEmail,
    this.profileImageBase64,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile Image
        Container(
          width: 120.w,
          height: 120.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: const Color(0xFFF5F5F5),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: profileImageBase64 != null 
            ? Image.memory(
                base64Decode(profileImageBase64!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Image.asset(
                    'assets/images/Rectangle 24.png',
                    width: 120.w,
                    height: 120.h,
                    fit: BoxFit.cover,
                  ),
              )
            : Image.asset(
                'assets/images/Rectangle 24.png',
                width: 120.w,
                height: 120.h,
                fit: BoxFit.cover,
              ),
        ),
        SizedBox(width: 22.w),
        
        // User info section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                userEmail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF706E71),
                ),
              ),
              SizedBox(height: 10.h),
              
              // Edit Profile Button
              Container(
                height: 32.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.primary,
                ),
                child: IntrinsicWidth(
                  child: MaterialButton(
                    onPressed: onEditPressed,
                    splashColor: const Color(0x52FFFFFF),
                    minWidth: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icons/editing 1.png',
                          width: 20.w,
                          height: 20.h,
                        ),
                        SizedBox(width: 8.h),
                        Text(
                          'Edit Profile',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}