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
                      _buildSectionTitle('1. Introduction'),
                      _buildParagraph(
                        'Welcome to our application. These Terms of Service ("Terms") govern your use of our mobile application (the "App") and any related services provided by us. By accessing or using our App, you agree to be bound by these Terms.'
                      ),
                      
                      // User Accounts
                      _buildSectionTitle('2. User Accounts'),
                      _buildParagraph(
                        'When you create an account with us, you must provide accurate and complete information. You are solely responsible for the activity that occurs on your account, and you must keep your account password secure. You must notify us immediately of any breach of security or unauthorized use of your account.'
                      ),
                      
                      // Privacy Policy
                      _buildSectionTitle('3. Privacy Policy'),
                      _buildParagraph(
                        'Our Privacy Policy describes how we handle the information you provide to us when you use our App. You understand that through your use of the App, you consent to the collection and use of this information as set forth in our Privacy Policy.'
                      ),
                      
                      // User Content
                      _buildSectionTitle('4. User Content'),
                      _buildParagraph(
                        'Our App may allow you to upload, submit, store, send or receive content, including profile pictures and other information. You retain ownership of any intellectual property rights that you hold in that content.'
                      ),
                      _buildParagraph(
                        'When you upload, submit, store, send or receive content to or through our App, you give us a worldwide license to use, host, store, reproduce, modify, create derivative works, communicate, publish, publicly perform, publicly display and distribute such content.'
                      ),
                      
                      // Prohibited Activities
                      _buildSectionTitle('5. Prohibited Activities'),
                      _buildParagraph(
                        'You may not engage in any of the following prohibited activities:'
                      ),
                      _buildListItem('Using the App for any illegal purpose or in violation of any local, state, national, or international law'),
                      _buildListItem('Harassing, threatening, or intimidating other users'),
                      _buildListItem('Impersonating or attempting to impersonate another user or person'),
                      _buildListItem('Posting or transmitting viruses, Trojan horses, or other disruptive code'),
                      _buildListItem('Interfering with or circumventing the security features of the App'),
                      
                      // Limitation of Liability
                      _buildSectionTitle('6. Limitation of Liability'),
                      _buildParagraph(
                        'To the maximum extent permitted by law, in no event shall the company, its affiliates, agents, directors, employees, suppliers or licensors be liable for any indirect, punitive, incidental, special, consequential or exemplary damages, including without limitation damages for loss of profits, goodwill, use, data or other intangible losses, that result from the use of, or inability to use, this App.'
                      ),
                      
                      // Termination
                      _buildSectionTitle('7. Termination'),
                      _buildParagraph(
                        'We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms. Upon termination, your right to use the App will immediately cease.'
                      ),
                      
                      // Changes to Terms
                      _buildSectionTitle('8. Changes to Terms'),
                      _buildParagraph(
                        'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days\' notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.'
                      ),
                      
                      // Contact Information
                      _buildSectionTitle('9. Contact Information'),
                      _buildParagraph(
                        'If you have any questions about these Terms, please contact us at support@yourappname.com.'
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