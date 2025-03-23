import 'package:eazytalk/Screens/secondary_screens/navigation.dart';
import 'package:eazytalk/Screens/starting_screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Navigate to the WelcomePage after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  Welcome()),
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00D0FF), 
              Color(0xFF043477),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                'assets/images/DesignerIn.png', 
                width: screenWidth * 0.47,
                height: screenHeight * 0.22,
                color: Colors.white,
              ),

              SizedBox(height: 15),

              // App Name
              Text(
                'EazyTalk',
                style: TextStyle(
                  fontFamily: 'Sora', 
                  fontSize: screenWidth * 0.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 10),

              // Slogan
              Text(
                'Speak Your Way, Sign Your Way!',
                style: TextStyle(
                  fontFamily: 'DM Sans', 
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}