import 'package:device_preview/device_preview.dart';
import 'package:eazytalk/Screens/main_screens/offline_tools.dart';
import 'package:eazytalk/Screens/secondary_screens/speech-to-text.dart';
import 'package:eazytalk/Screens/starting_screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(EazyTalkApp());
}

class EazyTalkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DevicePreview(
      enabled: true,
      builder: (context) {
      return ScreenUtilInit(
        designSize: const Size(428, 926),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        );
        });
  });
  }
}

