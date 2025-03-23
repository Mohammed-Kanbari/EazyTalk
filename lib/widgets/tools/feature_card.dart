import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;
  final String buttonText;
  final VoidCallback? onPressed;

  const FeatureCard({
    Key? key,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.buttonText,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 27.h),
            child: Row(
              children: [
                Image.asset(
                  iconPath,
                  width: 110.w,
                  height: 110.h,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.featureTitle,
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        description,
                        maxLines: 3,
                        style: AppTextStyles.featureDescription,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 17.w, bottom: 10.h),
            height: 40.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primary,
            ),
            child: MaterialButton(
              onPressed: onPressed,
              splashColor: const Color(0x52FFFFFF),
              minWidth: 0,
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: AppTextStyles.smallButtonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}