import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final Color? textColor;

  const ScreenHeader({
    Key? key,
    required this.title,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use textColor param if provided, otherwise use theme-aware color
    final color = textColor ?? AppColors.getTextPrimaryColor(context);
    
    return Padding(
      padding: EdgeInsets.only(top: 27.0.h, right: 28.w, left: 28.w),
      child: Text(
        title,
        style: AppTextStyles.screenTitle.copyWith(color: color),
      ),
    );
  }
}