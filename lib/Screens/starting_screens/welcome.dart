import 'package:eazytalk/Screens/starting_screens/login.dart';
import 'package:eazytalk/Screens/starting_screens/signup.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Welcome extends StatefulWidget {
  Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final PageController pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    
    final backgroundColor = isDarkMode 
        ? AppColors.darkBackground
        : Colors.white;
    
    final textColor = isDarkMode 
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
        
    return Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PageView(
                      controller: pageController,
                      children: [
                        Onboarding1(isDarkMode: isDarkMode),
                        Onboarding2(isDarkMode: isDarkMode),
                        Onboarding3(isDarkMode: isDarkMode)
                      ]),
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(
                          top: screenWidth < 400
                              ? screenHeight * 0.75
                              : screenHeight * 0.6),
                      child: SmoothPageIndicator(
                        controller: pageController,
                        count: 3,
                        effect: WormEffect(
                          // You can use different effects here
                          dotColor: isDarkMode ? Colors.grey[700]! : Colors.grey, // Inactive dots
                          activeDotColor: Color(0xFF00D0FF), // Active dot
                          dotHeight: screenWidth < 400 ? 10 : 12,
                          dotWidth: screenWidth < 400 ? 10 : 12,
                        ),
                      )),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: screenWidth * 0.06),
                    width: screenWidth * 0.29,
                    height: screenHeight * 0.053,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF1F3F5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      'Login',
                      style: TextStyle(
                          fontSize: screenWidth < 400 ? 10 : 14,
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w600,
                          color: textColor),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Signup()),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: screenWidth * 0.06),
                    width: screenWidth * 0.29,
                    height: screenHeight * 0.053,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF00D0FF),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      'Register',
                      style: TextStyle(
                          fontSize: screenWidth < 400 ? 10 : 14,
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
  }
}

class Onboarding1 extends StatelessWidget {
  final bool isDarkMode;
  
  Onboarding1({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    
    final backgroundColor = isDarkMode 
        ? AppColors.darkBackground
        : Colors.white;
    
    final textColor = isDarkMode 
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.21,
              ),
              Image.asset(
                'assets/images/onboarding1.png',
                width: screenWidth * 0.8,
                height: screenHeight * 0.31,
                color: isDarkMode ? Colors.white70 : null,
              ),
              SizedBox(
                height: screenHeight * 0.05,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  textAlign: TextAlign.center,
                  'Welcome to EazyTalk',
                  style: TextStyle(
                      fontSize: screenWidth < 400
                          ? 18
                          : screenWidth < 600
                              ? 24
                              : screenWidth < 1024
                                  ? 26
                                  : 28,
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w600,
                      color: textColor),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.035,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 400
                        ? screenWidth * 0.06
                        : screenWidth * 0.08),
                child: Text(
                  'Communicate easily with real-time speech-to-text and sign language translation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: screenWidth < 400 ? 14 : 16,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w400,
                      color: textColor),
                ),
              ),
            ],
          ),
        ));
  }
}

class Onboarding2 extends StatelessWidget {
  final bool isDarkMode;
  
  Onboarding2({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final backgroundColor = isDarkMode 
        ? AppColors.darkBackground
        : Colors.white;
    
    final textColor = isDarkMode 
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.23,
              ),
              Image.asset(
                'assets/images/onboarding2.png',
                width: screenWidth * 0.95,
                height: screenHeight * 0.29,
                color: isDarkMode ? Colors.white70 : null,
              ),
              SizedBox(
                height: screenHeight * 0.047,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  textAlign: TextAlign.center,
                  'Seamless Communication',
                  style: TextStyle(
                      fontSize: screenWidth < 400
                          ? 18
                          : screenWidth < 600
                              ? 24
                              : screenWidth < 1024
                                  ? 26
                                  : 28,
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w600,
                      color: textColor),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.036,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 400
                        ? screenWidth * 0.06
                        : screenWidth * 0.08),
                child: Text(
                  'Enjoy fast, accurate voice and video calls with instant translation. Stay connected without barriers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: screenWidth < 400 ? 14 : 16,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w400,
                      color: textColor),
                ),
              ),
            ],
          ),
        ));
  }
}

class Onboarding3 extends StatelessWidget {
  final bool isDarkMode;
  
  Onboarding3({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final backgroundColor = isDarkMode 
        ? AppColors.darkBackground
        : Colors.white;
    
    final textColor = isDarkMode 
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.27,
              ),
              Image.asset(
                'assets/images/onboarding3.png',
                width: screenWidth * 0.95,
                height: screenHeight * 0.26,
                color: isDarkMode ? Colors.white70 : null,
              ),
              SizedBox(
                height: screenHeight * 0.036,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  textAlign: TextAlign.center,
                  'Bridging Conversations',
                  style: TextStyle(
                      fontSize: screenWidth < 400
                          ? 18
                          : screenWidth < 600
                              ? 24
                              : screenWidth < 1024
                                  ? 26
                                  : 28,
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w600,
                      color: textColor),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.037,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 400
                        ? screenWidth * 0.06
                        : screenWidth * 0.08),
                child: Text(
                  'Use powerful tools for effortless and seamless face-to-face communication.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: screenWidth < 400 ? 14 : 16,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w400,
                      color: textColor),
                ),
              ),
            ],
          ),
        ));
  }
}