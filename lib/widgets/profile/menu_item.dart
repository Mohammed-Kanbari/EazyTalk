import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isLogout;
  
  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.onTap,
    this.isLogout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.getSurfaceColor(context),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          title: Text(
            text,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: isLogout 
                  ? Colors.red 
                  : (isDarkMode ? Colors.white : const Color(0xFF333333)),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}