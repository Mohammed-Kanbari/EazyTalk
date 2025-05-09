import 'package:eazytalk/Screens/starting_screens/splash_screen.dart';
import 'package:eazytalk/core/theme/app_theme.dart';
import 'package:eazytalk/l10n/app_localizations.dart';
import 'package:eazytalk/services/language/language_service.dart';
import 'package:eazytalk/services/theme/theme_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://glztvuchyyikhkgbdnuw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdsenR2dWNoeXlpa2hrZ2JkbnV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI0MTg2NjYsImV4cCI6MjA1Nzk5NDY2Nn0.kII5OweVs3W2vuLpfYe17sZ7u-QlubmcOeF0E7cbhUM',
  );
  
  // Initialize theme service
  await ThemeService.init();
  
  // Initialize language service
  await LanguageService.init();
  
  runApp(EazyTalkApp());
}

class EazyTalkApp extends StatefulWidget {
  @override
  State<EazyTalkApp> createState() => _EazyTalkAppState();
}

class _EazyTalkAppState extends State<EazyTalkApp> {
  @override
  void initState() {
    super.initState();
    // Listen for theme changes
    ThemeService.themeNotifier.addListener(() {
      setState(() {});
    });
    
    // Listen for language changes
    LanguageService.localeNotifier.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeService.getThemeMode(),
          
          // Localization setup
          locale: LanguageService.localeNotifier.value,
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('ar', ''), // Arabic
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          
          home: SplashScreen(),
          
          // Use a builder to set RTL based on language
          builder: (context, child) {
            return Directionality(
              textDirection: LanguageService.isRtl() 
                  ? TextDirection.rtl 
                  : TextDirection.ltr,
              child: child!,
            );
          },
        );
      }
    );
  }
}