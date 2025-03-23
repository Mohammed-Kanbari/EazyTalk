import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class TermsAndServicesPage extends StatelessWidget {
  const TermsAndServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey;
    final contentColor = isDarkMode ? Colors.grey[300] : Colors.black87;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: EdgeInsets.only(top: 27.h, left: 28.w, right: 28.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 28.w, height: 28.h), // Placeholder for alignment
                  Text(
                    'Terms and Services',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 28.sp, color: textColor),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            
            // Terms and Services Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Last Updated Date
                      Text(
                        'Last Updated: March 19, 2025',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: subtitleColor,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      
                      // Introduction
                      _buildSectionTitle(context, '1. Acceptance of Terms'),
                      _buildParagraph(
                        context,
                        'By using the Eazy Talk application, you agree to comply with and be bound by these terms and conditions. If you do not agree with any part of these terms, you are advised to discontinue using the application.'
                      ),
                      
                      // User Accounts
                      _buildSectionTitle(context, '2. Service Overview'),
                      _buildParagraph(
                        context,
                        'Eazy Talk is a platform designed to assist users in translating Arabic sign language to text and vice versa. It also offers features to contribute data and provide feedback to enhance the platform. All functionalities are intended for personal, non-commercial use only.'
                      ),
                      
                      // Privacy Policy
                      _buildSectionTitle(context, '3. User Responsibilities'),
                      _buildListItem(context, 'Use the application solely for its intended purpose.'),
                      _buildListItem(context, 'Avoid uploading inappropriate, offensive, or harmful content.'),
                      _buildListItem(context, 'Provide accurate information when contributing data or providing feedback.'),
                      
                      // User Content
                      _buildSectionTitle(context, '4. Data Contribution'),
                      _buildParagraph(
                        context,
                        "Users contributing data (e.g., videos, photos, or textual labels) grant AI Signs a non-exclusive, royalty-free license to use the content for improving the application's performance and expanding its database. AI Signs will not use this data for any purpose outside its scope."
                      ),
                     
                      
                      // Prohibited Activities
                      _buildSectionTitle(context, '5. Privacy Policy'),
                      _buildParagraph(
                        context,
                        'Eazy Talk respects your privacy and handles your data responsibly. Collected data will only be used to enhance application functionality and will not be shared with third parties without your consent. For more details, refer to our Privacy Policy.'
                      ),
                      
                      // Limitation of Liability
                      _buildSectionTitle(context, '6. Limitation of Liability'),
                      _buildParagraph(
                        context,
                        "Eazy Talk is provided on an 'as-is' basis. While we strive to ensure accurate translations and smooth functionality, we do not guarantee the application's performance at all times. AI Signs will not be liable for any damages or losses resulting from the use or inability to use the application."
                      ),
                      
                      // Termination
                      _buildSectionTitle(context, '7. Updates and Changes'),
                      _buildParagraph(
                        context,
                        "Eazy Talk reserves the right to modify these terms and the application's features at any time. Users will be notified of significant changes through the application or other communication channels."
                      ),
                      
                      
                      // Contact Information
                      _buildSectionTitle(context, '8. Contact Information'),
                      _buildParagraph(
                        context,
                        'If you have any questions, concerns, or feedback regarding these terms or the application, please reach out to us at: \nEmail: Ammaralhawamdeh@gmail.com \nPhone: 0567132854'
                      ),
                      
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper widgets for consistent styling
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    final textColor = AppColors.getTextPrimaryColor(context);
    
    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
  
  Widget _buildParagraph(BuildContext context, String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.grey[300] : Colors.black87;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: contentColor,
          height: 1.5,
        ),
      ),
    );
  }
  
  Widget _buildListItem(BuildContext context, String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? Colors.grey[300] : Colors.black87;
    
    return Padding(
      padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00D0FF),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: contentColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}