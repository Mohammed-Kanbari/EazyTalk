import 'package:eazytalk/l10n/app_localizations.dart';
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
    final localizations = AppLocalizations.of(context);
    
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
                    localizations.translate('terms_services'),
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
                        localizations.translate('last_updated'),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: subtitleColor,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      
                      // Acceptance of Terms
                      _buildSectionTitle(context, localizations.translate('acceptance_terms')),
                      _buildParagraph(
                        context,
                        localizations.translate('acceptance_desc')
                      ),
                      
                      // Service Overview
                      _buildSectionTitle(context, localizations.translate('service_overview')),
                      _buildParagraph(
                        context,
                        localizations.translate('service_desc')
                      ),
                      
                      // User Responsibilities
                      _buildSectionTitle(context, localizations.translate('user_responsibilities')),
                      _buildListItem(context, localizations.translate('use_only')),
                      _buildListItem(context, localizations.translate('avoid_upload')),
                      _buildListItem(context, localizations.translate('provide_accurate')),
                      
                      // Data Contribution
                      _buildSectionTitle(context, localizations.translate('data_contribution')),
                      _buildParagraph(
                        context,
                        localizations.translate('data_desc')
                      ),
                     
                      
                      // Privacy Policy
                      _buildSectionTitle(context, localizations.translate('privacy_policy')),
                      _buildParagraph(
                        context,
                       localizations.translate('privacy_desc')
                      ),
                      
                      // Limitation of Liability
                      _buildSectionTitle(context, localizations.translate('limitation_liability')),
                      _buildParagraph(
                        context,
                        localizations.translate('liability_desc')
                      ),
                      
                      // Updates and Changes
                      _buildSectionTitle(context, localizations.translate('updates_changes')),
                      _buildParagraph(
                        context,
                        localizations.translate('updates_desc')
                      ),
                      
                      
                      // Contact Information
                      _buildSectionTitle(context, localizations.translate('contact_info')),
                      _buildParagraph(
                        context,
                        localizations.translate('contact_desc')
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