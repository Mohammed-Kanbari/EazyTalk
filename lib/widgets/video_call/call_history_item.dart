// lib/widgets/video_call/call_history_item.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/models/call_model.dart';
import 'package:eazytalk/services/video_call/call_history_service.dart';

class CallHistoryItem extends StatelessWidget {
  final CallModel call;
  final String callType; // "Incoming", "Outgoing", "Missed"
  final String duration;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isCurrentUser;
  
  const CallHistoryItem({
    Key? key,
    required this.call,
    required this.callType,
    required this.duration,
    required this.onTap,
    required this.onDelete,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Get the appropriate background color
    final backgroundColor = isDarkMode 
        ? AppColors.getSurfaceColor(context)
        : Colors.white;
        
    // Get text color based on theme
    final textColor = AppColors.getTextPrimaryColor(context);
    
    // Get appropriate name and profile image
    final name = isCurrentUser ? call.receiverName : call.callerName;
    final profileImage = isCurrentUser 
        ? call.receiverProfileImageBase64
        : call.callerProfileImageBase64;
    
    // Get icon and status color based on call type
    final (icon, statusColor) = _getCallTypeInfo(callType, isDarkMode);
    
    return Dismissible(
      key: Key(call.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDelete();
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Profile image
              _buildProfileImage(profileImage, isDarkMode),
              
              SizedBox(width: 12.w),
              
              // Call details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Call type and time
                    Row(
                      children: [
                        Icon(
                          icon,
                          size: 14.sp,
                          color: statusColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          callType,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12.sp,
                            color: statusColor,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _formatDate(call.startTime),
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12.sp,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    // Duration
                    if (callType != 'Missed' && duration.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          'Duration: $duration',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12.sp,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Call button
              IconButton(
                icon: Icon(
                  call.isVideoEnabled ? Icons.videocam : Icons.phone,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build profile image widget
  Widget _buildProfileImage(String? profileImageBase64, bool isDarkMode) {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDarkMode ? const Color(0xFF2A2A2A) : AppColors.backgroundGrey,
      ),
      child: profileImageBase64 != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(25.r),
              child: Image.memory(
                base64Decode(profileImageBase64),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(isDarkMode),
              ),
            )
          : _buildDefaultIcon(isDarkMode),
    );
  }
  
  // Default icon when profile image is missing
  Widget _buildDefaultIcon(bool isDarkMode) {
    return Icon(
      Icons.person,
      size: 25.sp,
      color: isDarkMode ? Colors.grey[600] : Colors.grey,
    );
  }
  
  // Format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    
    if (now.difference(date).inDays == 0) {
      // Today, show time
      return DateFormat('h:mm a').format(date);
    } else if (now.difference(date).inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Older dates
      return DateFormat('MMM d').format(date);
    }
  }
  
  // Get call type icon and color
  (IconData, Color) _getCallTypeInfo(String type, bool isDarkMode) {
    switch (type) {
      case 'Incoming':
        return (
          Icons.call_received,
          isDarkMode ? Colors.green[300]! : Colors.green,
        );
      case 'Outgoing':
        return (
          Icons.call_made,
          isDarkMode ? Colors.blue[300]! : Colors.blue,
        );
      case 'Missed':
        return (
          Icons.call_missed,
          Colors.red,
        );
      default:
        return (
          Icons.call,
          isDarkMode ? Colors.grey[300]! : Colors.grey,
        );
    }
  }
}