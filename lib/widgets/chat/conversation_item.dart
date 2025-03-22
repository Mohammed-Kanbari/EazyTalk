import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class ConversationItem extends StatelessWidget {
  final String name;
  final String? profileImage;
  final String lastMessage;
  final DateTime time;
  final bool isUnread;
  final VoidCallback onTap;

  const ConversationItem({
    Key? key,
    required this.name,
    this.profileImage,
    required this.lastMessage,
    required this.time,
    this.isUnread = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Profile image
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.backgroundGrey,
              ),
              child: profileImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25.r),
                      child: Image.memory(
                        base64Decode(profileImage!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          size: 25.sp,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 25.sp,
                      color: Colors.grey,
                    ),
            ),
            SizedBox(width: 16.w),

            // Conversation details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 16.sp,
                          fontWeight:
                              isUnread ? FontWeight.w600 : FontWeight.w500,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Time
                      Text(
                        _formatTime(time),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Last message and unread indicator
                  Row(
                    children: [
                      // Last message
                      Expanded(
                        child: Text(
                          lastMessage.isEmpty
                              ? 'Start a conversation'
                              : lastMessage,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14.sp,
                            fontWeight:
                                isUnread ? FontWeight.w500 : FontWeight.w400,
                            color: isUnread ? Colors.black : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // lib/widgets/chat/conversation_item.dart (continued)
                      // Unread indicator
                      if (isUnread)
                        Container(
                          width: 10.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format timestamp into readable time
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
