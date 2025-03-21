import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eazytalk/Screens/secondary_screens/speech-to-text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OfflineTools extends StatefulWidget {
  const OfflineTools({super.key});

  @override
  State<OfflineTools> createState() => _OfflineToolsState();
}

class _OfflineToolsState extends State<OfflineTools> {
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isOffline = (result == ConnectivityResult.none);
      });
    });
  }

  Future<void> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = (connectivityResult == ConnectivityResult.none);
    });
  }

  void showConnectivityMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'No Internet Connection',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 0, 0, 0)
            ),
          ),
          content: Text(
            'Please check your internet connection to use all features.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF00D0FF),
                  fontFamily: 'Sora',
                  fontSize: 14.sp,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
  final List<String> instructions = [
    "Ensure you're online",
    'Select a tool',
    'Tap the action button',
    'Follow instructions',
    'View or copy text'
  ];
  
  int currentIndex = 0;

  void nextInstruction() {
    if (currentIndex < instructions.length - 1) {
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:  EdgeInsets.only(top: 27.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Smart Tools',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isOffline)
                      GestureDetector(
                        onTap: showConnectivityMessage,
                        child: Image.asset(
                          'assets/icons/exclamation 1.png',
                          width: 28.w,
                          height: 28.h,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 16.sp,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      children: [
                        const TextSpan(text: 'Enhance communication with '),
                        TextSpan(
                          text: 'smart',
                          style: TextStyle(
                            color: const Color(0xFF00D0FF),
                          ),
                        ),
                        const TextSpan(text: ', '),
                        TextSpan(
                          text: 'real-time',
                          style: TextStyle(
                            color: const Color(0xFF00D0FF),
                          ),
                        ),
                        const TextSpan(text: ' translation tools.'),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  _buildFeatureCard(
                      'Sign Language Translator',
                      'record a video to translate sign language instantly.',
                      'assets/images/sign.png',
                      'Start translation',
                      onPressed: () {
                        // Add your navigation logic here
                        // Example:
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => SignLanguagePage()));
                      },
                  ),
                  SizedBox(height: 40.h),
                  _buildFeatureCard(
                      'Speech to Text',
                      'Convert spoken words into text effortlessly.',
                      'assets/images/speech.png',
                      'Start translation',
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => Speech()));
                      },
                  ),
                  SizedBox(height: 60.h),
                  Text(
                    'How to use smart tools :',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildInstructionCard('1', 'Download required language packs'),
                            
                  SizedBox(height: 20.h,)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, String description, String iconPath, String buttonText, {
      VoidCallback? onPressed,  // Added callback parameter
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 27.h),
            child: Row(
              children: [
                Image.asset(
                  iconPath,
                  width: 110.w,
                  height: 110.h,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        description,
                        maxLines: 3,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 17.w, bottom: 10.h),
            height: 27.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF00D0FF),
            ),
            child: MaterialButton(
              onPressed: onPressed,  // Use the provided callback
              splashColor: const Color(0x52FFFFFF),
              minWidth: 0,
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildInstructionCard(String number, String text) {
  return Row(
    children: [
      Container(
        width: 95.w,
        height: 154.h,
        decoration: BoxDecoration(
          color: Color(0xFF00D0FF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
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
            color: Color(0xFFF1F3F5),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              if (currentIndex > 0)
                IconButton(
                  icon: Image.asset(
                    'assets/icons/arrow-left.png',
                    width: 18.w,
                    height: 18.h,
                  ),
                  onPressed: previousInstruction,
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                  child: Text(
                    instructions[currentIndex],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),
              if (currentIndex < instructions.length - 1) // Conditionally render the right arrow
                IconButton(
                  icon: Image.asset(
                    'assets/icons/arrow-right 1.png',
                    width: 18.w,
                    height: 18.h,
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
