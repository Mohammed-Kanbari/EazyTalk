import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class EducationalResourceCard extends StatelessWidget {
  final String institutionName;
  final String type;
  final String description;
  final String location;
  final String? url;
  final VoidCallback? onUrlTap;
  
  const EducationalResourceCard({
    Key? key,
    required this.institutionName,
    required this.type,
    required this.description,
    required this.location,
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
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Institution Circle with first letter
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  institutionName.substring(0, 1),
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Institution name
                  Text(
                    institutionName,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Type
                  Text(
                    type,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14.sp,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  // Location with icon
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        location,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  // Website link if provided
                  if (url != null && url!.isNotEmpty && onUrlTap != null) ...[
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: onUrlTap,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Visit Website",
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Icon(
                            Icons.arrow_forward,
                            size: 12.sp,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}