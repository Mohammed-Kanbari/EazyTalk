import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class InstructionCard extends StatefulWidget {
  final List<String> instructions;
  final Color numberBackgroundColor;
  final Color cardBackgroundColor;

  const InstructionCard({
    Key? key,
    required this.instructions,
    this.numberBackgroundColor = const Color(0xFF00D0FF),
    this.cardBackgroundColor = const Color(0xFFF1F3F5),
  }) : super(key: key);

  @override
  State<InstructionCard> createState() => _InstructionCardState();
}

class _InstructionCardState extends State<InstructionCard> {
  int currentIndex = 0;

  void nextInstruction() {
    if (currentIndex < widget.instructions.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void previousInstruction() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Row(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Container(
          width: 95.w,
          height: 154.h,
          decoration: BoxDecoration(
            color: widget.numberBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isRTL ? 0 : 10),
              bottomLeft: Radius.circular(isRTL ? 0 : 10),
              topRight: Radius.circular(isRTL ? 10 : 0),
              bottomRight: Radius.circular(isRTL ? 10 : 0),
            ),
          ),
          child: Center(
            child: Text(
              '${currentIndex + 1}',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 40.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 154.h,
            decoration: BoxDecoration(
              color: widget.cardBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isRTL ? 10 : 0),
                bottomLeft: Radius.circular(isRTL ? 10 : 0),
                topRight: Radius.circular(isRTL ? 0 : 10),
                bottomRight: Radius.circular(isRTL ? 0 : 10),
              ),
            ),
            child: Row(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              children: [
                if (currentIndex > 0)
                  IconButton(
                    icon: Image.asset(
                      isRTL ? 'assets/icons/arrow-right 1.png' : 'assets/icons/arrow-left.png',
                      width: 25.w,
                      height: 25.h,
                      color: isDarkMode ? Colors.white70 : null,
                    ),
                    onPressed: previousInstruction,
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                    child: Text(
                      widget.instructions[currentIndex],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14.sp,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                if (currentIndex < widget.instructions.length - 1)
                  IconButton(
                    icon: Image.asset(
                      isRTL ? 'assets/icons/arrow-left.png' : 'assets/icons/arrow-right 1.png',
                      width: 25.w,
                      height: 25.h,
                      color: isDarkMode ? Colors.white70 : null,
                    ),
                    onPressed: nextInstruction,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}