import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class AppTextStyles {
  // Static getters for theme-aware text styles
  static TextStyle getScreenTitle(BuildContext context) {
    final textColor = AppColors.getTextPrimaryColor(context);
    return TextStyle(
      fontFamily: 'Sora',
      fontSize: 28.sp,
      fontWeight: FontWeight.w700,
      color: textColor,
    );
  }
  
  static TextStyle getBodyText(BuildContext context) {
    final textColor = AppColors.getTextPrimaryColor(context);
    return TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: textColor,
    );
  }

  static TextStyle getSecondaryHeaderTitle(BuildContext context) {
    final textColor = AppColors.getTextPrimaryColor(context);
    return TextStyle(
      fontFamily: 'Sora',
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: textColor,
    );
  }

  static TextStyle getChatHeading(BuildContext context) {
    final textColor = AppColors.getTextPrimaryColor(context);
    return TextStyle(
      fontFamily: 'Sora',
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: textColor,
    );
  }

  static TextStyle getChatBodyText(BuildContext context) {
    final textColor = AppColors.getTextPrimaryColor(context);
    return TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 16.sp,
      color: textColor,
    );
  }

  static TextStyle getSectionTitle(BuildContext context) {
    final textColor = AppColors.getTextPrimaryColor(context);
    return TextStyle(
      fontFamily: 'Sora',
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: textColor,
    );
  }

  static TextStyle getIntroText(BuildContext context) {
    final textColor = AppColors.getTextPrimaryColor(context);
    return TextStyle(
      fontFamily: 'DM Sans',
      fontSize: 16.sp,
      color: textColor,
    );
  }

  // Non-contextual styles (for compatibility with existing code)
  static TextStyle screenTitle = TextStyle(
    fontFamily: 'Sora',
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  
  static TextStyle bodyText = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle secondaryHeaderTitle = TextStyle(
    fontFamily: 'Sora',
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle chatHeading = TextStyle(
    fontFamily: 'Sora',
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle chatBodyText = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 16.sp,
    color: AppColors.textPrimary,
  );

  static TextStyle sectionTitle = TextStyle(
    fontFamily: 'Sora',
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle introText = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 16.sp,
    color: AppColors.textPrimary,
  );

  static TextStyle buttonText = TextStyle(
    fontFamily: 'Sora',
    fontSize: 14.sp,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  static TextStyle emptyStateText = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 16.sp,
    color: Colors.grey,
  );

  static TextStyle featureTitle = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle featureDescription = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 10.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle smallButtonText = TextStyle(
    fontSize: 8.sp,
    fontFamily: 'Sora',
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}