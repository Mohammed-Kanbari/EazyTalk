import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final String? url;
  final VoidCallback? onUrlTap;
  
  const InfoCard({
    Key? key,
    required this.title,
    required this.content,
    this.url,
    this.onUrlTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(15.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              content,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            // Only show the arrow if URL is provided
            if (url != null && url!.isNotEmpty && onUrlTap != null) ...[
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: onUrlTap,
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColors.primary,
                      size: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}