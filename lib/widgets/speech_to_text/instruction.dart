import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

class InstructionsDialog extends StatelessWidget {
  final String title;
  final List<InstructionStep> steps;
  final List<String> rememberPoints;
  final String thankYouTitle;
  final String thankYouMessage;
  
  const InstructionsDialog({
    Key? key,
    required this.title,
    required this.steps,
    required this.rememberPoints,
    required this.thankYouTitle,
    required this.thankYouMessage,
  }) : super(key: key);

  // Static method to show the dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<InstructionStep> steps,
    required List<String> rememberPoints,
    required String thankYouTitle,
    required String thankYouMessage,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => InstructionsDialog(
        title: title,
        steps: steps,
        rememberPoints: rememberPoints,
        thankYouTitle: thankYouTitle,
        thankYouMessage: thankYouMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final localizations = AppLocalizations.of(context);
    
    return Dialog(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and close button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close, 
                        color: textColor,
                        size: 24.sp,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Steps sections
              for (int i = 0; i < steps.length; i++) _buildStepSection(context, i + 1, steps[i]),
              
              SizedBox(height: 20.h),
              
              // Remember section
              _buildRememberSection(context, rememberPoints),
              
              SizedBox(height: 20.h),
              
              // Thank you section
              _buildThankYouSection(context, thankYouTitle, thankYouMessage),
              
              SizedBox(height: 20.h),
              
              // Close button at bottom
              Center(
                child: SizedBox(
                  width: 150.w,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Color(0xFF3A3A3A) : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      localizations.translate('close'),
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build a step section with heading and content
  Widget _buildStepSection(BuildContext context, int stepNumber, InstructionStep step) {
    final textColor = AppColors.getTextPrimaryColor(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step heading
        Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          child: Text(
            "Step $stepNumber: ${step.title}",
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        
        // Step content
        Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...step.instructions.map((instruction) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Text(
                  instruction,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16.sp,
                    color: textColor,
                  ),
                ),
              )),
              
              // Tips section if there are any
              if (step.tips.isNotEmpty) ...[
                SizedBox(height: 15.h),
                Text(
                  AppLocalizations.of(context).translate('just_tips'),
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 10.h),
                ...step.tips.map((tip) => _buildTipItem(context, tip)),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  // Build a tip item with bullet point
  Widget _buildTipItem(BuildContext context, String tip) {
    final textColor = AppColors.getTextPrimaryColor(context);
    
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
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
  
  // Build the remember section
  Widget _buildRememberSection(BuildContext context, List<String> points) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode 
        ? Color(0xFF0A3A42) 
        : Color(0xFF004D40).withOpacity(0.1);
    final textColor = Colors.white;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDarkMode 
              ? Color(0xFF085F6B) 
              : Color(0xFF004D40).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Remember:",
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.lightGreenAccent : Colors.green[800],
            ),
          ),
          SizedBox(height: 12.h),
          ...points.map((point) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "• ",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: isDarkMode ? Colors.lightGreenAccent : Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16.sp,
                      color: isDarkMode ? Colors.lightGreenAccent[100] : Colors.green[900],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  // Build the thank you section
  Widget _buildThankYouSection(BuildContext context, String title, String message) {
    final textColor = AppColors.getTextPrimaryColor(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16.sp,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Class to represent a step with its instructions and tips
class InstructionStep {
  final String title;
  final List<String> instructions;
  final List<String> tips;
  
  InstructionStep({
    required this.title,
    required this.instructions,
    this.tips = const [],
  });
}