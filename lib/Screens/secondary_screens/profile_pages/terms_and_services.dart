import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsAndServicesPage extends StatelessWidget {
  const TermsAndServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 28.sp),
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
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      
                      // Introduction
                      _buildSectionTitle('1. Acceptance of Terms'),
                      _buildParagraph(
                        'By using the Eazy Talk application, you agree to comply with and be bound by these terms and conditions. If you do not agree with any part of these terms, you are advised to discontinue using the application.'
                      ),
                      
                      // User Accounts
                      _buildSectionTitle('2. Service Overview'),
                      _buildParagraph(
                        'Eazy Talk is a platform designed to assist users in translating Arabic sign language to text and vice versa. It also offers features to contribute data and provide feedback to enhance the platform. All functionalities are intended for personal, non-commercial use only.'
                      ),
                      
                      // Privacy Policy
                      _buildSectionTitle('3. User Responsibilities'),
                      _buildListItem('Use the application solely for its intended purpose.'),
                      _buildListItem('Avoid uploading inappropriate, offensive, or harmful content.'),
                      _buildListItem('Provide accurate information when contributing data or providing feedback.'),
                      
                      // User Content
                      _buildSectionTitle('4. Data Contribution'),
                      _buildParagraph(
                        'Users contributing data (e.g., videos, photos, or textual labels) grant AI Signs a non-exclusive, royalty-free license to use the content for improving the application’s performance and expanding its database. AI Signs will not use this data for any purpose outside its scope.'
                      ),
                     
                      
                      // Prohibited Activities
                      _buildSectionTitle('5. Privacy Policy'),
                      _buildParagraph(
                        'Eazy Talk respects your privacy and handles your data responsibly. Collected data will only be used to enhance application functionality and will not be shared with third parties without your consent. For more details, refer to our Privacy Policy.'
 ),
                      
                      // Limitation of Liability
                      _buildSectionTitle('6. Limitation of Liability'),
                      _buildParagraph(
                        'Eazy Talk is provided on an “as-is” basis. While we strive to ensure accurate translations and smooth functionality, we do not guarantee the application’s performance at all times. AI Signs will not be liable for any damages or losses resulting from the use or inability to use the application.'
                      ),
                      
                      // Termination
                      _buildSectionTitle('7. Updates and Changes'),
                      _buildParagraph(
                        'Eazy Talk reserves the right to modify these terms and the application’s features at any time. Users will be notified of significant changes through the application or other communication channels.'
                      ),
                      
                      
                      // Contact Information
                      _buildSectionTitle('8. Contact Information'),
                      _buildParagraph(
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
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
  
  Widget _buildParagraph(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }
  
  Widget _buildListItem(String text) {
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
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}