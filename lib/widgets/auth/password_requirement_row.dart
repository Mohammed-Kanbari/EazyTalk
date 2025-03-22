import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasswordRequirementRow extends StatelessWidget {
  final bool isMet;
  final String text;
  
  const PasswordRequirementRow({
    Key? key,
    required this.isMet,
    required this.text,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          size: 16.sp,
          color: isMet ? Colors.green : Colors.red,
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: 'DM Sans',
            color: isMet ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
      ],
    );
  }
}