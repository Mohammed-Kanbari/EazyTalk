import 'package:eazytalk/Screens/secondary_screens/speech-to-text.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';
import 'package:eazytalk/services/connectivity/connectivity_service.dart';
import 'package:eazytalk/widgets/common/screen_header.dart';
import 'package:eazytalk/widgets/tools/feature_card.dart';
import 'package:eazytalk/widgets/tools/instruction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SmartToolsScreen extends StatefulWidget {
  const SmartToolsScreen({super.key});

  @override
  State<SmartToolsScreen> createState() => _SmartToolsScreenState();
}

class _SmartToolsScreenState extends State<SmartToolsScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOffline = false;
  
  // Instructions for using tools
  final List<String> _instructions = [
    "Ensure you're online",
    'Select a tool',
    'Tap the action button',
    'Follow instructions',
    'View or copy text'
  ];

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _listenToConnectivityChanges();
  }

  Future<void> _checkInitialConnectivity() async {
    final isOffline = await _connectivityService.checkConnectivity();
    setState(() {
      _isOffline = isOffline;
    });
  }

  void _listenToConnectivityChanges() {
    _connectivityService.connectivityStream.listen((isOffline) {
      setState(() {
        _isOffline = isOffline;
      });
    });
  }

  void _showConnectivityMessage() {
    ConnectivityService.showConnectivityDialog(
      context,
      TextStyle(
        fontFamily: 'Sora',
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextPrimaryColor(context),
      ),
      TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14.sp,
        color: AppColors.getTextPrimaryColor(context),
      ),
      TextStyle(
        color: AppColors.primary,
        fontFamily: 'Sora',
        fontSize: 14.sp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ScreenHeader(
                  title: 'Smart Tools',
                  textColor: AppColors.getTextPrimaryColor(context),
                ),
                if (_isOffline)
                  GestureDetector(
                    onTap: _showConnectivityMessage,
                    child: Padding(
                      padding:  EdgeInsets.only(right: 28.w, top: 27.h),
                      child: Image.asset(
                        'assets/icons/exclamation 1.png',
                        color: isDarkMode ? Colors.yellowAccent : null,
                        width: 28.w,
                        height: 28.h,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 30.h),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntroText(),
                      SizedBox(height: 30.h),
                      
                      // Sign Language Translator Card
                      FeatureCard(
                        title: 'Sign Language Translator',
                        description: 'record a video to translate sign language instantly.',
                        iconPath: 'assets/images/sign.png',
                        buttonText: 'Start translation',
                        onPressed: () {
                          // Navigate to Sign Language Page
                        },
                      ),
                      SizedBox(height: 40.h),
                      
                      // Speech to Text Card
                      FeatureCard(
                        title: 'Speech to Text',
                        description: 'Convert spoken words into text effortlessly.',
                        iconPath: 'assets/images/speech.png',
                        buttonText: 'Start translation',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const Speech()));
                        },
                      ),
                      SizedBox(height: 60.h),
                      
                      Text(
                        'How to use smart tools :',
                        style: AppTextStyles.getSectionTitle(context),
                      ),
                      SizedBox(height: 20.h),
                      
                      // Instructions Card
                      InstructionCard(
                        instructions: _instructions,
                        numberBackgroundColor: AppColors.primary,
                        cardBackgroundColor: isDarkMode 
                            ? const Color(0xFF2A2A2A) 
                            : AppColors.backgroundGrey,
                      ),
                      
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIntroText() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 16.sp,
          color: textColor,
        ),
        children: [
          const TextSpan(text: 'Enhance communication with '),
          TextSpan(
            text: 'smart',
            style: TextStyle(
              color: AppColors.primary,
            ),
          ),
          const TextSpan(text: ', '),
          TextSpan(
            text: 'real-time',
            style: TextStyle(
              color: AppColors.primary,
            ),
          ),
          const TextSpan(text: ' translation tools.'),
        ],
      ),
    );
  }
}