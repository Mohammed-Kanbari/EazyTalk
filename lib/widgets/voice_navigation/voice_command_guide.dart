import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          localizations.translate('voice_commands'),
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
              localizations.translate('how_to_use'),
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              localizations.translate('voice_intro'),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16.sp,
                color: textColor,
              ),
            ),
            SizedBox(height: 30.h),
            
            // Available commands
            Text(
              localizations.translate('available_commands'),
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
              localizations.translate('main_navigation'),
              [
                CommandExample(
                  localizations.translate('go_to_home'),
                  localizations.translate('navigate_home'),
                ),
                CommandExample(
                  localizations.translate('learn_signs'),
                  localizations.translate('navigate_signs'),
                ),
                CommandExample(
                  localizations.translate('smart_tools'),
                  localizations.translate('navigate_tools'),
                ),
                CommandExample(
                  localizations.translate('open_profile'),
                  localizations.translate('navigate_profile'),
                ),
              ],
              cardColor,
              textColor,
            ),
            SizedBox(height: 20.h),
            
            // Feature navigation commands
            _buildCommandCategory(
              context,
              localizations.translate('feature_navigation'),
              [
                CommandExample(
                  localizations.translate('ai_chat'),
                  localizations.translate('navigate_chatbot'),
                ),
                CommandExample(
                  localizations.translate('speech_to_text'),
                  localizations.translate('navigate_speech'),
                ),
              ],
              cardColor,
              textColor,
            ),
            SizedBox(height: 30.h),
            
            // Tips for best results
            Text(
              localizations.translate('tips_best'),
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
              localizations.translate('speak_clear'),
              Icons.record_voice_over,
              cardColor,
              textColor,
            ),
            SizedBox(height: 12.h),
            
            _buildTipCard(
              context,
              localizations.translate('use_phrases'),
              Icons.format_quote,
              cardColor,
              textColor,
            ),
            SizedBox(height: 12.h),
            
            _buildTipCard(
              context,
              localizations.translate('reduce_bg'),
              Icons.volume_off,
              cardColor,
              textColor,
            ),
            SizedBox(height: 12.h),
            
            _buildTipCard(
              context,
              localizations.translate('voice_both'),
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