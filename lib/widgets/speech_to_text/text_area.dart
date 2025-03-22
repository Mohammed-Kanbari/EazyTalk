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
  
  const TranscriptionTextArea({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onCopy,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 275.h,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.11),
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
                style: AppTextStyles.bodyText,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Your transcribed text will appear here.',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'DM Sans',
                    color: const Color(0xFF9E9E9E),
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
                child: Image.asset(
                  'assets/icons/copy 1.png',
                  width: 24.w,
                  height: 24.h,
                ),
                onTap: onCopy,
              ),
              GestureDetector(
                child: Image.asset(
                  'assets/icons/bin 1.png',
                  width: 24.w,
                  height: 24.h,
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