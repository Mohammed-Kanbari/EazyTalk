import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSend;
  
  const ChatInput({
    Key? key,
    required this.controller,
    required this.canSend,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
              decoration: InputDecoration(
                hintText: localizations.translate('type_message'),
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[600] : Colors.grey,
                  fontFamily: 'DM Sans',
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 8.h,
                ),
              ),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16.sp,
                color: AppColors.getTextPrimaryColor(context),
              ),
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => canSend ? onSend() : null,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            height: 38.h,
            width: 38.w,
            decoration: BoxDecoration(
              color: canSend 
                  ? AppColors.primary
                  : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.send, color: Colors.white, size: 18.sp),
              onPressed: canSend ? onSend : null,
            ),
          ),
        ],
      ),
    );
  }
}