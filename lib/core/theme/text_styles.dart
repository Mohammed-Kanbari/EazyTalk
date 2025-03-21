import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class AppTextStyles {
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

  // In lib/core/theme/text_styles.dart, add:

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
  fontSize: 16.sp,
  color: Colors.white,
);

static TextStyle emptyStateText = TextStyle(
  fontFamily: 'DM Sans',
  fontSize: 16.sp,
  color: Colors.grey,
);

}