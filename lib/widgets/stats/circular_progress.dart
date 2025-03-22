import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CircularProgressWidget extends StatelessWidget {
  final double percentage;
  final Color progressColor;
  final Color backgroundColor;
  final double width;
  final double height;
  final double strokeWidth;
  
  const CircularProgressWidget({
    Key? key,
    required this.percentage,
    this.progressColor = const Color(0xFF4A86E8),
    this.backgroundColor = Colors.white,
    this.width = 30,
    this.height = 30,
    this.strokeWidth = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.w,
      height: height.h,
      child: CircularProgressIndicator(
        value: percentage,
        strokeWidth: strokeWidth.w,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
      ),
    );
  }
}