import 'package:eazytalk/screens/secondary_screens/chatbot.dart';
import 'package:eazytalk/widgets/buttons/gradient_fab.dart';
import 'package:eazytalk/widgets/common/screen_header.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/widgets/inputs/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Chatting extends StatefulWidget {
  const Chatting({super.key});

  @override
  State<Chatting> createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen title
                const ScreenHeader(title: 'EazyTalk'),
                SizedBox(height: 30.h),

                // Search and add bar
                Row(
                  children: [
                    Flexible(
                      child: CustomSearchBar(
                        hintText: 'Search conversations..',
                        onChanged: (value) {
                          // Handle search
                        },
                      ),
                    ),
                    SizedBox(width: 17.w),
                    // Add button
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 35.w,
                        height: 35.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.backgroundGrey,
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppColors.textPrimary,
                          size: 16,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
      // AI Chatbot button
      floatingActionButton: GradientFloatingActionButton(
        child: Image.asset(
          'assets/icons/chatbot 1.png',
          width: 35.w,
          height: 35.h,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Chatbot()));
        },
      ),
    );
  }
}