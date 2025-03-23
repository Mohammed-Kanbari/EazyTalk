// lib/widgets/profile/profile_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? profileImageUrl;
  final String? profileImageBase64;
  final VoidCallback onEditPressed;
  
  const ProfileHeader({
    Key? key,
    required this.userName,
    required this.userEmail,
    this.profileImageUrl,
    this.profileImageBase64,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        // Profile Image
        Container(
          width: 120.w,
          height: 120.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildProfileImage(isDarkMode),
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
                  color: AppColors.getTextPrimaryColor(context),
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
                  color: isDarkMode ? const Color(0xFFACACAC) : const Color(0xFF706E71),
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
                          color: Colors.white,
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
  
  // Helper method to build profile image
  Widget _buildProfileImage(bool isDarkMode) {
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      // Use cached network image for URL
      return CachedNetworkImage(
        imageUrl: profileImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        errorWidget: (context, error, stackTrace) => _fallbackImage(isDarkMode),
      );
    } else if (profileImageBase64 != null && profileImageBase64!.isNotEmpty) {
      // Fallback to base64
      try {
        return Image.memory(
          base64Decode(profileImageBase64!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallbackImage(isDarkMode),
        );
      } catch (e) {
        return _fallbackImage(isDarkMode);
      }
    } else {
      return _fallbackImage(isDarkMode);
    }
  }
  
  // Fallback image when URL or Base64 fails
  Widget _fallbackImage(bool isDarkMode) {
    return Icon(
      Icons.person,
      size: 60.sp,
      color: isDarkMode ? Colors.grey[600] : Colors.grey,
    );
  }
}