import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';
import 'package:eazytalk/models/excursion_model.dart';

class DestinationCard extends StatelessWidget {
  final ExcursionModel destination;
  final VoidCallback onExplorePressed;
  
  const DestinationCard({
    Key? key,
    required this.destination,
    required this.onExplorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: Image.asset(
              destination.image,
              width: double.infinity,
              height: 200.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 200.h,
                color: Colors.grey[300],
                child: Icon(
                  Icons.image_not_supported,
                  size: 50.sp,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
          
          // Destination Details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.title,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  destination.description,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Explore More Button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onExplorePressed,
                    child: Text(
                      'Explore more',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}