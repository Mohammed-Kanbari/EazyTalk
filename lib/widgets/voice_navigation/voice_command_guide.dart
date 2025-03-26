import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class CommandExample {
  final String command;
  final String description;
  
  CommandExample(this.command, this.description);
}

class VoiceCommandGuide extends StatelessWidget {
  const VoiceCommandGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Voice Commands',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        backgroundColor: AppColors.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            Text(
              'How to use voice commands',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Tap the microphone button at the bottom right of the screen to start voice command mode. Speak clearly and try one of the following commands:',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16.sp,
                color: textColor,
              ),
            ),
            SizedBox(height: 30.h),
            
            // Available commands
            Text(
              'Available commands',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Main navigation commands
            _buildCommandCategory(
              context,
              'Main Navigation',
              [
                CommandExample('Go to home', 'Navigate to the home screen'),
                CommandExample('sign language', 'Navigate to the learn signs screen'),
                CommandExample('Smart tools', 'Navigate to the smart tools screen'),
                CommandExample('Open profile', 'Navigate to the profile screen'),
              ],
              cardColor,
              textColor,
            ),
            SizedBox(height: 20.h),
            
            // Feature navigation commands
            _buildCommandCategory(
              context,
              'Feature Navigation',
              [
                CommandExample('ai chat', 'Navigate to the AI chatbot'),
                CommandExample('Speech to text', 'Open the speech to text tool'),
              ],
              cardColor,
              textColor,
            ),
            SizedBox(height: 30.h),
            
            // Tips for best results
            Text(
              'Tips for best results',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: 16.h),
            
            _buildTipCard(
              context,
              'Speak clearly and at a normal pace',
              Icons.record_voice_over,
              cardColor,
              textColor,
            ),
            SizedBox(height: 12.h),
            
            _buildTipCard(
              context,
              'Use the exact phrases shown above for best results',
              Icons.format_quote,
              cardColor,
              textColor,
            ),
            SizedBox(height: 12.h),
            
            _buildTipCard(
              context,
              'Reduce background noise when using voice commands',
              Icons.volume_off,
              cardColor,
              textColor,
            ),
            SizedBox(height: 12.h),
            
            _buildTipCard(
              context,
              'Voice commands work in both English and Arabic',
              Icons.language,
              cardColor,
              textColor,
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCommandCategory(
    BuildContext context, 
    String title, 
    List<CommandExample> commands,
    Color cardColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: commands.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16.w,
              endIndent: 16.w,
              color: Colors.grey.withOpacity(0.2),
            ),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.mic,
                      color: AppColors.primary,
                      size: 18.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            commands[index].command,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            commands[index].description,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13.sp,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildTipCard(
    BuildContext context,
    String tip,
    IconData icon,
    Color cardColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}