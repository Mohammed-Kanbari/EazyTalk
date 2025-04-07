// lib/widgets/video_call/language_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageSelected;
  
  const LanguageSelector({
    Key? key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final l10n = AppLocalizations.of(context);
    
    // List of supported languages with their locale codes
    final languages = [
      {'code': 'en-US', 'name': l10n.translate('language_en')},
      {'code': 'ar-SA', 'name': l10n.translate('language_ar')},
    ];
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black87 : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('select_language'),
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 12.h),
          Column(
            children: languages.map((language) {
              final isSelected = language['code'] == currentLanguage;
              return _buildLanguageOption(
                context,
                language['code']!,
                language['name']!,
                isSelected,
                isDarkMode,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLanguageOption(
    BuildContext context,
    String code,
    String name,
    bool isSelected,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: () {
        onLanguageSelected(code);
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(isDarkMode ? 0.2 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : (isDarkMode ? Colors.white : Colors.black87),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
  
  // Show as a dialog
  static Future<void> showAsDialog(
    BuildContext context, {
    required String currentLanguage,
    required Function(String) onLanguageSelected,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: LanguageSelector(
          currentLanguage: currentLanguage,
          onLanguageSelected: onLanguageSelected,
        ),
      ),
    );
  }
}