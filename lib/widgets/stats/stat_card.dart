import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final IconData? iconData;
  final Widget? icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final Widget? customFooter;
  
  const StatCard({
    Key? key,
    this.iconData,
    this.icon,
    this.iconColor = Colors.blue,
    required this.title,
    required this.subtitle,
    this.backgroundColor = Colors.white,
    this.titleColor = Colors.black,
    this.subtitleColor = Colors.black87,
    this.customFooter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Padding(
          padding: EdgeInsets.all(15.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                icon!
              else if (iconData != null)
                Icon(iconData!, color: iconColor, size: 30.sp),
              SizedBox(height: 12.h),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 5.h),
              Flexible(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12.sp,
                    color: subtitleColor,
                  ),
                ),
              ),
              if (customFooter != null) ...[
                SizedBox(height: 8.h),
                customFooter!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}