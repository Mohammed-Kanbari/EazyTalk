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
import 'package:eazytalk/l10n/app_localizations.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getSurfaceColor(context);
    final bottomSheetHandleColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
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
                color: bottomSheetHandleColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            
            // Sort alphabetically
            FilterOptionItem(
              icon: Icons.sort_by_alpha,
              title: AppLocalizations.of(context).translate('sort_alphabetically'),
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
              title: AppLocalizations.of(context).translate('sort_by_difficulty'),
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
              title: AppLocalizations.of(context).translate('show_favorites'),
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
              title: AppLocalizations.of(context).translate('clear_filters'),
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
    // Get current theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Create a thematically appropriate category color
    final Color categoryColor = isDarkMode 
        ? _getDarkModeColor(widget.categoryColor)
        : widget.categoryColor;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordDetailPage(
          wordId: word.id,
          word: word.word,
          description: word.description,
          image: word.imagePath,
          categoryColor: categoryColor,
          videoPath: word.videoPath,
        ),
      ),
    ).then((_) {
      // Refresh favorites when returning
      _refreshFavorites();
    });
  }
  
  // Helper method for dark mode colors
  Color _getDarkModeColor(Color originalColor) {
    // If color is too light, darken it for better visibility in dark mode
    final hsl = HSLColor.fromColor(originalColor);
    
    // Lower lightness for dark mode to make colors deeper
    if (hsl.lightness > 0.5) {
      return hsl.withLightness(0.3).toColor();
    } else if (hsl.lightness > 0.3) {
      return hsl.withLightness(0.25).toColor();
    }
    
    // If already dark enough, return as is
    return originalColor;
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final filteredWords = _getFilteredWords();
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              SecondaryHeader(
                title: AppLocalizations.of(context).translate('words'),
                onBackPressed: () => Navigator.pop(context),
                actionWidget: GestureDetector(
                  onTap: _showOptionsMenu,
                  child: Icon(
                    Icons.more_vert,
                    color: textColor,
                    size: 24.sp,
                  ),
                ),
              ),
              SizedBox(height: 30.h,),
              
              // Main content area
              _buildContent(filteredWords, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent(List<WordModel> filteredWords, bool isDarkMode) {
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
                hintText: AppLocalizations.of(context).translate('search_words'),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              
              // Category title
              _buildCategoryTitle(isDarkMode),
              
              // Words list or empty state
              _buildWordsList(filteredWords, isDarkMode),
              
              // Bottom spacing
              SizedBox(height: 20.h),
            ],
          ),
        ),
      );
    }
  }
  
  Widget _buildCategoryTitle(bool isDarkMode) {
    final textColor = AppColors.getTextPrimaryColor(context);
    
    // Create a thematically appropriate category color
    final Color categoryColor = isDarkMode 
        ? _getDarkModeColor(widget.categoryColor)
        : widget.categoryColor;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 30.h),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          children: [
            TextSpan(
              text: AppLocalizations.of(context).translate('common_in_sign', [widget.title]),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWordsList(List<WordModel> filteredWords, bool isDarkMode) {
    final textColor = AppColors.getTextPrimaryColor(context);
    final emptyStateColor = isDarkMode ? Colors.grey[500] : Colors.grey;
    final iconColor = isDarkMode ? Colors.grey[600] : Colors.grey;
    
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
                color: iconColor,
              ),
              SizedBox(height: 20.h),
              Text(
                _showFavoritesOnly
                    ? AppLocalizations.of(context).translate('no_favorites')
                    : (_searchQuery.isNotEmpty
                        ? AppLocalizations.of(context).translate('no_words_match') + ' "$_searchQuery"'
                        : AppLocalizations.of(context).translate('no_words')),
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16.sp,
                  color: emptyStateColor,
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