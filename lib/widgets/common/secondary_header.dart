import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class SecondaryHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Widget? actionWidget;
  
  const SecondaryHeader({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.actionWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextPrimaryColor(context);
    
    return Padding(
      padding: EdgeInsets.only(top: 27.h, left: 28.w, right: 28.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          onBackPressed != null
              ? GestureDetector(
                  onTap: onBackPressed,
                  child: Image.asset(
                    'assets/icons/back-arrow.png',
                    width: 22.w,
                    height: 22.h,
                    color: textColor,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.arrow_back_ios,
                      color: textColor,
                      size: 20.sp,
                    ),
                  ),
                )
              : SizedBox(width: 22.w, height: 22.h),
          Text(
            title,
            style: AppTextStyles.secondaryHeaderTitle.copyWith(color: textColor),
          ),
          actionWidget ?? SizedBox(width: 22.w, height: 22.h),
        ],
      ),
    );
  }
}