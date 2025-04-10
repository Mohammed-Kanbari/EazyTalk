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
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Padding(
      padding: EdgeInsets.only(top: 27.h, left: 28.w, right: 28.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,  // Center the Row
        children: [
          if (onBackPressed != null)
            GestureDetector(
              onTap: onBackPressed,
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(isRTL ? 3.14159 : 0),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/icons/back-arrow.png',
                  width: 22.w,
                  height: 22.h,
                  color: textColor,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                    color: textColor,
                    size: 20.sp,
                  ),
                ),
              ),
            )
          else
            SizedBox(width: 22.w, height: 22.h),
          
          // Spacer to push the title towards the center
          Spacer(),
          
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.secondaryHeaderTitle.copyWith(color: textColor),
          ),
          
          // Spacer after the text to center the content
          Spacer(),
          
          actionWidget ?? SizedBox(width: 22.w, height: 22.h),
        ],
      ),
    );
  }
}
