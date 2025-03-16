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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 27),
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
                                  EdgeInsets.symmetric(horizontal: 14),
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
                      onTap: () {

                      },
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
              ],
            ),
          ),
        ),
        //AI Chatbot button
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFF00D0FF),
          child: Image.asset('assets/icons/chatbot 1.png', width: 32, height: 32,),
          onPressed: () {

          },
        ));
  }
}
