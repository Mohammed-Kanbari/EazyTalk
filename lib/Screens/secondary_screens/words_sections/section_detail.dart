import 'package:eazytalk/Screens/secondary_screens/words_sections/word_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/models/word_model.dart';
import 'package:eazytalk/services/sign_language/sign_language_service.dart';
import 'package:eazytalk/services/favorites/favorites_service.dart';
import 'package:eazytalk/widgets/common/error_display.dart';
import 'package:eazytalk/widgets/common/secondary_header.dart';
import 'package:eazytalk/widgets/signs/section_word_card.dart';
import 'package:eazytalk/widgets/signs/section_search_bar.dart';
import 'package:eazytalk/widgets/signs/filter_option_item.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';

class SectionDetailPage extends StatefulWidget {
  final int sectionId;
  final String title;
  final String category;
  final Color categoryColor;

  const SectionDetailPage({
    Key? key,
    required this.sectionId,
    required this.title,
    required this.category,
    required this.categoryColor,
  }) : super(key: key);

  @override
  State<SectionDetailPage> createState() => _SectionDetailPageState();
}

class _SectionDetailPageState extends State<SectionDetailPage> {
  final SignLanguageService _signService = SignLanguageService();
  final FavoritesService _favoritesService = FavoritesService();
  
  bool _isLoading = true;
  List<WordModel> _words = [];
  String _errorMessage = '';
  String _searchQuery = '';
  
  // Filtering and sorting options
  bool _showFavoritesOnly = false;
  String _sortOption = 'alphabetical'; // 'alphabetical', 'difficulty'
  Set<int> _favoriteWordIds = {};
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Fetch words for the section
      final words = await _signService.fetchWordsBySection(widget.sectionId);
      // Fetch user's favorites
      final favorites = await _favoritesService.getUserFavorites();
      
      setState(() {
        _words = words;
        _favoriteWordIds = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  // Get filtered and sorted word list
  List<WordModel> _getFilteredWords() {
    return _signService.filterAndSortWords(
      words: _words,
      searchQuery: _searchQuery,
      showFavoritesOnly: _showFavoritesOnly,
      favoriteIds: _favoriteWordIds,
      sortOption: _sortOption,
    );
  }
  
  // Show options menu for sorting and filtering
  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            
            // Sort alphabetically
            FilterOptionItem(
              icon: Icons.sort_by_alpha,
              title: 'Sort alphabetically',
              isSelected: _sortOption == 'alphabetical',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _sortOption = 'alphabetical';
                });
              },
            ),
            
            // Sort by difficulty
            FilterOptionItem(
              icon: Icons.trending_up,
              title: 'Sort by difficulty',
              isSelected: _sortOption == 'difficulty',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _sortOption = 'difficulty';
                });
              },
            ),
            
            // Show favorites only
            FilterOptionItem(
              icon: Icons.favorite_border,
              title: 'Show favorites only',
              isSelected: _showFavoritesOnly,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _showFavoritesOnly = !_showFavoritesOnly;
                });
              },
            ),
            
            // Clear filters
            FilterOptionItem(
              icon: Icons.clear_all,
              title: 'Clear all filters',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _showFavoritesOnly = false;
                  _sortOption = 'alphabetical';
                  _searchQuery = '';
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Navigation to word detail page
  void _navigateToWordDetail(WordModel word) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordDetailPage(
          wordId: word.id,
          word: word.word,
          description: word.description,
          image: word.imagePath,
          categoryColor: widget.categoryColor,
          videoPath: word.videoPath,
        ),
      ),
    ).then((_) {
      // Refresh favorites when returning
      _refreshFavorites();
    });
  }
  
  // Refresh favorites without reloading all words
  Future<void> _refreshFavorites() async {
    final favorites = await _favoritesService.getUserFavorites();
    setState(() {
      _favoriteWordIds = favorites;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final filteredWords = _getFilteredWords();
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              SecondaryHeader(
                title: 'Words',
                onBackPressed: () => Navigator.pop(context),
                actionWidget: GestureDetector(
                  onTap: _showOptionsMenu,
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                    size: 24.sp,
                  ),
                ),
              ),
              SizedBox(height: 30.h,),
              
              // Main content area
              _buildContent(filteredWords),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent(List<WordModel> filteredWords) {
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
          onRefresh: () async {
            await _loadData();
          },
          color: AppColors.primary,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Search bar
              SectionSearchBar(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              
              // Category title
              _buildCategoryTitle(),
              
              // Words list or empty state
              _buildWordsList(filteredWords),
              
              // Bottom spacing
              SizedBox(height: 20.h),
            ],
          ),
        ),
      );
    }
  }
  
  Widget _buildCategoryTitle() {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.h),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.sectionTitle,
          children: [
            TextSpan(text: 'Common '),
            TextSpan(
              text: widget.title,
              style: TextStyle(
                color: widget.categoryColor,
              ),
            ),
            TextSpan(text: ' In Sign Language'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWordsList(List<WordModel> filteredWords) {
    if (filteredWords.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50.h),
          child: Column(
            children: [
              Icon(
                _showFavoritesOnly
                    ? Icons.favorite_border
                    : Icons.search_off,
                size: 60.sp,
                color: Colors.grey,
              ),
              SizedBox(height: 20.h),
              Text(
                _showFavoritesOnly
                    ? 'No favorites found'
                    : (_searchQuery.isNotEmpty
                        ? 'No words matching "$_searchQuery"'
                        : 'No words available in this section'),
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: filteredWords
          .map((word) => SectionWordCard(
                word: word,
                onTap: () => _navigateToWordDetail(word),
              ))
          .toList(),
    );
  }
}