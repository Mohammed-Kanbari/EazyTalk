import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class ScreenHeader extends StatelessWidget {
  final String title;

  const ScreenHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 27.0.h, right: 28.w, left: 28.w),
      child: Text(
        title,
        style: AppTextStyles.screenTitle,
      ),
    );
  }
}