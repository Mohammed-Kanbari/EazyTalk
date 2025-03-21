import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/models/section_model.dart';

class SectionCard extends StatelessWidget {
  final SectionModel section;
  final VoidCallback onTap;
  
  const SectionCard({
    Key? key,
    required this.section,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: section.color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(15.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 14.sp,
                    color: Colors.black54,
                  ),
                ),
                // Image with error handling
                Image.asset(
                  section.iconPath,
                  width: 32.w,
                  height: 32.h,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.category,
                    size: 32.sp,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    section.subtitle,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10.sp,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}