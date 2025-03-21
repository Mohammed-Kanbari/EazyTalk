import 'package:device_preview/device_preview.dart';
import 'package:eazytalk/Screens/main_screens/learning_signs.dart';
import 'package:eazytalk/Screens/main_screens/profile.dart';
import 'package:eazytalk/Screens/secondary_screens/chatBot.dart';
import 'package:eazytalk/Screens/secondary_screens/navigation.dart';
import 'package:eazytalk/Screens/secondary_screens/profile_pages/deaf_excursions.dart';
import 'package:eazytalk/Screens/starting_screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://glztvuchyyikhkgbdnuw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdsenR2dWNoeXlpa2hrZ2JkbnV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI0MTg2NjYsImV4cCI6MjA1Nzk5NDY2Nn0.kII5OweVs3W2vuLpfYe17sZ7u-QlubmcOeF0E7cbhUM',
  );
  
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
   } );
  }
}

