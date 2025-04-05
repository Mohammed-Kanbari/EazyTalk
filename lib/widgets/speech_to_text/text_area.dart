import 'package:eazytalk/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class TranscriptionTextArea extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onCopy;
  final VoidCallback onClear;
  final bool isDarkMode;
  final String hintText; // Dynamic hint text parameter
  final double height; // Added dynamic height parameter
  
  const TranscriptionTextArea({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onCopy,
    required this.onClear,
    required this.isDarkMode,
    required this.hintText, // Marked as required
    required this.height, // Marked as required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final localizations = AppLocalizations.of(context);
    
    final backgroundColor = isDarkMode 
        ? AppColors.primary.withOpacity(0.15)
        : AppColors.primary.withOpacity(0.11);
    
    final textColor = AppColors.getTextPrimaryColor(context);
    final hintColor = isDarkMode 
        ? Colors.grey[600]
        : const Color(0xFF9E9E9E);
    
    final iconColor = isDarkMode
        ? Colors.grey[400]
        : const Color(0xFF9E9E9E);
    
    return Container(
      width: double.infinity,
      height: height, // Use dynamic height
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: TextField(
                controller: controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14.sp,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  fillColor: const Color.fromARGB(0, 255, 255, 255),
                  border: InputBorder.none,
                  hintText: hintText, // Use dynamic hint text
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'DM Sans',
                    color: hintColor,
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: Icon(
                  Icons.copy,
                  size: 24.sp,
                  color: iconColor,
                ),
                onTap: onCopy,
              ),
              GestureDetector(
                child: Icon(
                  Icons.delete_outline,
                  size: 24.sp,
                  color: iconColor,
                ),
                onTap: onClear,
              ),
            ],
          ),
        ],
      ),
    );
  }
}