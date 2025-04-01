import 'package:eazytalk/Screens/secondary_screens/words_sections/word_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/models/section_model.dart';
import 'package:eazytalk/models/word_model.dart';
import 'package:eazytalk/services/sign_language/sign_language_service.dart';
import 'package:eazytalk/widgets/common/error_display.dart';
import 'package:eazytalk/widgets/common/screen_header.dart';
import 'package:eazytalk/widgets/signs/word_card.dart';
import 'package:eazytalk/widgets/signs/section_card.dart';
import 'package:eazytalk/screens/secondary_screens/words_sections/section_detail.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

class LearnSignsPage extends StatefulWidget {
  const LearnSignsPage({super.key});

  @override
  State<LearnSignsPage> createState() => _LearnSignsPageState();
}

class _LearnSignsPageState extends State<LearnSignsPage> {
  final SignLanguageService _signService = SignLanguageService();
  
  bool _isLoading = true;
  List<WordModel> _mostUsedWords = [];
  List<SectionModel> _sections = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data from service
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch data using the service
      final sections = await _signService.fetchSections();
      final mostUsedWords = await _signService.fetchMostUsedWords();

      setState(() {
        _sections = sections;
        _mostUsedWords = mostUsedWords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detect dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen header with theme-aware text color
            ScreenHeader(
              title: AppLocalizations.of(context).translate('learn_signs'),
              textColor: textColor,
            ),
            SizedBox(height: 30.h),
            
            // Content area with loading/error states
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    
    if (_isLoading) {
      return Expanded(
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    } else if (_errorMessage.isNotEmpty) {
      return Expanded(
        child: ErrorDisplay(
          message: _errorMessage,
          onRetry: _loadData,
        ),
      );
    } else {
      return Expanded(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Introduction text
                  _buildIntroText(),
                  SizedBox(height: 30.h),

                  // Most Used Words section
                  if (_mostUsedWords.isNotEmpty) _buildMostUsedWordsSection(),
                  SizedBox(height: 60.h),

                  // Sections
                  _buildSectionsGrid(),
                  
                  SizedBox(height: 20.h), // Bottom spacing
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildIntroText() {
    final textColor = AppColors.getTextPrimaryColor(context);
    
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 16.sp,
          color: textColor,
        ),
        children: [
          TextSpan(text: AppLocalizations.of(context).translate('master_signs').split(' ')[0] + ' '),
          TextSpan(
            text: AppLocalizations.of(context).translate('master_signs').split(' ')[1],
            style: TextStyle(
              color: AppColors.primary,
            ),
          ),
          TextSpan(text: ' ' + AppLocalizations.of(context).translate('master_signs').split(' ').sublist(2).join(' ')),
        ],
      ),
    );
  }

  Widget _buildMostUsedWordsSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final backgroundColor = AppColors.getWordCardBackgroundColor(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('most_used_words'),
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          height: 80.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _mostUsedWords.length,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              return WordCard(
                word: _mostUsedWords[index],
                backgroundColor: backgroundColor,
                onTap: () => _navigateToWordDetail(_mostUsedWords[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionsGrid() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final noSectionsColor = isDarkMode ? Colors.grey[500] : Colors.grey;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('sections'),
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: 20.h),
        _sections.isNotEmpty
            ? GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15.w,
                  mainAxisSpacing: 15.h,
                  childAspectRatio: 1.2,
                ),
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  return SectionCard(
                    section: _sections[index],
                    onTap: () => _navigateToSection(_sections[index]),
                    isDarkMode: isDarkMode,
                  );
                },
              )
            : Center(
                child: Text(
                  AppLocalizations.of(context).translate('no_sections'),
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16.sp,
                    color: noSectionsColor,
                  ),
                ),
              ),
      ],
    );
  }

  // Navigation methods
  void _navigateToWordDetail(WordModel word) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordDetailPage(
          wordId: word.id,
          word: word.word,
          description: word.description,
          image: word.imagePath,
          categoryColor: AppColors.getWordCardBackgroundColor(context),
          videoPath: word.videoPath,
        ),
      ),
    );
  }

  void _navigateToSection(SectionModel section) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SectionDetailPage(
          sectionId: section.id,
          title: section.title,
          category: section.title,
          categoryColor: section.color,
        ),
      ),
    );
  }
}