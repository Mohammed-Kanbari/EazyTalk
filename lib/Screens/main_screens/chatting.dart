import 'package:eazytalk/Screens/secondary_screens/chatBot.dart';
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                  Padding(
                    padding: EdgeInsets.only(top: 27.h),
                    child: Text(
                      'EazyTalk',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),

                  //search and add bar
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          height: 35.h,
                          child: TextField(
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              color: Colors.black,
                              fontSize: 14.sp,
                            ),
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 14.w),
                                suffixIcon: Icon(Icons.search,
                                    color: const Color(0xFFC7C7C7)),
                                hintText: 'Search conversations..',
                                hintStyle: TextStyle(
                                  fontFamily: 'DM Sans',
                                  color: const Color(0xFFC7C7C7),
                                  fontSize: 14.sp,
                                ),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(12))),
                          ),
                        ),
                      ),
                      SizedBox(width: 17.w),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 35.w,
                          height: 35.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFF1F3F5),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30.h,)
                ],
              ),
            ),
          ),
        ),
        //AI Chatbot button
        floatingActionButton: Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF00D0FF),
        Color(0xFF0088FF),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF00D0FF).withOpacity(0.4),
        spreadRadius: 2,
        blurRadius: 15,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: FloatingActionButton(
    elevation: 0, // Remove default elevation since we have custom shadow
    backgroundColor: Colors.transparent, // Transparent to show gradient
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: Image.asset(
      'assets/icons/chatbot 1.png',
      width: 35.w,
      height: 35.h,
    ),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Chatbot()));
    },
  ),
),);
  }
}
