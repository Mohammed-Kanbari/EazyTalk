import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/services/url/url_launcher_service.dart';
import 'package:eazytalk/widgets/common/modal_header.dart';
import 'package:eazytalk/widgets/stats/stat_card.dart';
import 'package:eazytalk/widgets/stats/circular_progress.dart';
import 'package:eazytalk/widgets/info/info_card.dart';
import 'package:eazytalk/widgets/education/educational_resource_card.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

class MoreOnDeaf extends StatefulWidget {
  const MoreOnDeaf({Key? key}) : super(key: key);

  @override
  State<MoreOnDeaf> createState() => _MoreOnDeafState();
}

class _MoreOnDeafState extends State<MoreOnDeaf> {
  // URL launcher service instance
  final UrlLauncherService _urlLauncherService = UrlLauncherService();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: ModalHeader(
                title: l10n.translate('more_on_deaf'),
                onClose: () => Navigator.pop(context),
              ),
            ),
            SizedBox(height: 30.h),

            // Main Content
            Expanded(
              child: _buildMainContent(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  // Build the main scrollable content
  Widget _buildMainContent(bool isDarkMode) {
    final textColor = AppColors.getTextPrimaryColor(context);
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Title
            Text(
              l10n.translate('deaf_uae'),
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 28.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: 30.h),

            // Stats Grid
            _buildStatsGrid(isDarkMode),
            SizedBox(height: 25.h),

            // Information Cards
            _buildInfoCards(isDarkMode),

            // Educational Resources Section
            _buildEducationalResourcesSection(isDarkMode),

            SizedBox(height: 20.h), // Bottom padding
          ],
        ),
      ),
    );
  }

  // Build the stats grid
  Widget _buildStatsGrid(bool isDarkMode) {
    final l10n = AppLocalizations.of(context);
    
    // Custom colors for the stat cards in dark mode
    final bgColorPrimary = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF1F8FF);
    final bgColorSecondary = isDarkMode ? const Color(0xFF2C4F7A) : const Color(0xFF4A86E8);
    final textColorSecondary = isDarkMode ? Colors.white : Colors.white;
    final subtitleColorSecondary = isDarkMode ? Colors.white70 : Colors.white;
    
    return Column(
      children: [
        // First row of stats
        Row(
          children: [
            // Population Stat
            Expanded(
              child: StatCard(
                iconData: Icons.people,
                iconColor: const Color(0xFF4A86E8),
                title: '19.4k',
                subtitle: l10n.translate('population'),
                backgroundColor: bgColorPrimary,
                titleColor: AppColors.getTextPrimaryColor(context),
                subtitleColor: isDarkMode ? Colors.grey[400]! : Colors.black87,
              ),
            ),
            SizedBox(width: 15.w),
            // Fund Stat
            Expanded(
              child: StatCard(
                iconData: Icons.attach_money,
                iconColor: Colors.white,
                title: '\$8.5M',
                subtitle: l10n.translate('annual_support'),
                backgroundColor: bgColorSecondary,
                titleColor: textColorSecondary,
                subtitleColor: subtitleColorSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        // Second row of stats
        Row(
          children: [
            // Empowerment Stat
            Expanded(
              child: StatCard(
                icon: CircularProgressWidget(percentage: 0.89),
                title: '89%',
                subtitle: l10n.translate('deaf_empowerment'),
                backgroundColor: bgColorPrimary,
                titleColor: AppColors.getTextPrimaryColor(context),
                subtitleColor: isDarkMode ? Colors.grey[400]! : Colors.black87,
              ),
            ),
            SizedBox(width: 15.w),
            // Organizations Stat
            Expanded(
              child: StatCard(
                iconData: Icons.business,
                iconColor: const Color(0xFF4A86E8),
                title: '36',
                subtitle: l10n.translate('associations'),
                backgroundColor: bgColorPrimary,
                titleColor: AppColors.getTextPrimaryColor(context),
                subtitleColor: isDarkMode ? Colors.grey[400]! : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build information cards
  Widget _buildInfoCards(bool isDarkMode) {
    final cardBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final cardBorderColor = isDarkMode ? const Color(0xFF323232) : Colors.grey[200]!;
    final textColor = AppColors.getTextPrimaryColor(context);
    final contentColor = isDarkMode ? Colors.grey[300] : Colors.black87;
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emirati Sign Language (ESL)
        Container(
          margin: EdgeInsets.only(bottom: 15.h),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: cardBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('esl_title'),
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  l10n.translate('esl_content'),
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14.sp,
                    color: contentColor,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => _launchUrl('https://zho.gov.ae/en/Sign-Language-Dictionary/UAE-Sign-Language-Categories'),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // What Are Their Needs?
        Container(
          margin: EdgeInsets.only(bottom: 15.h),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: cardBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('needs_title'),
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  l10n.translate('needs_content'),
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14.sp,
                    color: contentColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        // UAE Government Support
        Container(
          margin: EdgeInsets.only(bottom: 15.h),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: cardBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('support_title'),
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  l10n.translate('support_content'),
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14.sp,
                    color: contentColor,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => _launchUrl('https://u.ae/en/information-and-services/social-affairs/people-of-determination/protection-support-and-assistance-of-people-of-determination'),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build educational resources section
  Widget _buildEducationalResourcesSection(bool isDarkMode) {
    final textColor = AppColors.getTextPrimaryColor(context);
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        SizedBox(height: 15.h),
        Text(
          l10n.translate('educational_resources'),
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: 15.h),

        // Educational resource cards
        _buildEducationalResourceCard(
          isDarkMode,
          l10n.translate('zayed_org'),
          l10n.translate('specialized_education'),
          l10n.translate('zayed_org_desc'),
          l10n.translate('abu_dhabi'),
          "https://zho.gov.ae",
        ),

        _buildEducationalResourceCard(
          isDarkMode,
          l10n.translate('sharjah_city'),
          l10n.translate('inclusive_education'),
          l10n.translate('sharjah_city_desc'),
          l10n.translate('sharjah'),
          "https://www.schs.ae",
        ),

        _buildEducationalResourceCard(
          isDarkMode,
          l10n.translate('al_amal'),
          l10n.translate('k12_education'),
          l10n.translate('al_amal_desc'),
          l10n.translate('sharjah'),
          "https://www.schs.ae",
        ),

        _buildEducationalResourceCard(
          isDarkMode,
          l10n.translate('emirates_assoc'),
          l10n.translate('training_development'),
          l10n.translate('emirates_assoc_desc'),
          l10n.translate('multiple_branches'),
          null,
        ),
      ],
    );
  }
  
  // Helper method to build educational resource card
  Widget _buildEducationalResourceCard(
    bool isDarkMode,
    String institutionName,
    String type,
    String description,
    String location,
    String? url,
  ) {
    final cardBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final cardBorderColor = isDarkMode 
        ? AppColors.primary.withOpacity(0.3)
        : AppColors.primary.withOpacity(0.3);
    final textColor = AppColors.getTextPrimaryColor(context);
    final contentColor = isDarkMode ? Colors.grey[300] : Colors.black87;
    final locationColor = isDarkMode ? Colors.grey[500] : Colors.grey[600];
    final l10n = AppLocalizations.of(context);
    
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(15.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Institution Circle with first letter
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  institutionName.substring(0, 1),
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Institution name
                  Text(
                    institutionName,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Type
                  Text(
                    type,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14.sp,
                      color: contentColor,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  // Location with icon
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.sp,
                        color: locationColor,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        location,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12.sp,
                          color: locationColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  // Website link if provided
                  if (url != null) ...[
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () => _launchUrl(url),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.translate('visit_website'),
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Icon(
                            Icons.arrow_forward,
                            size: 12.sp,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to launch URLs using the URL launcher service
  Future<void> _launchUrl(String url) async {
    await UrlLauncherService.launchUrlWithErrorHandling(context, url,
        errorMessage: 'Could not launch website');
  }
}