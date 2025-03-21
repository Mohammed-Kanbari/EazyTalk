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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen header
            const ScreenHeader(title: 'Learn Sign Language'),
            SizedBox(height: 30.h),
            
            // Content area with loading/error states
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
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
    return RichText(
      text: TextSpan(
        style: AppTextStyles.introText,
        children: [
          const TextSpan(text: 'Master '),
          TextSpan(
            text: 'essential signs',
            style: TextStyle(
              color: AppColors.primary,
            ),
          ),
          const TextSpan(text: ' for everyday communication.'),
        ],
      ),
    );
  }

  Widget _buildMostUsedWordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most Used Words :',
          style: AppTextStyles.sectionTitle,
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
                backgroundColor: AppColors.wordCardBackground,
                onTap: () => _navigateToWordDetail(_mostUsedWords[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sections :',
          style: AppTextStyles.sectionTitle,
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
                  );
                },
              )
            : Center(
                child: Text(
                  'No sections available',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16.sp,
                    color: Colors.grey,
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
          categoryColor: AppColors.wordCardBackground,
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