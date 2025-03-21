import 'package:eazytalk/Screens/secondary_screens/words&sections/words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  List<Map<String, dynamic>> words = [];
  String _errorMessage = '';
  String _searchQuery = '';

  // Sorting and filtering options
  bool _showFavoritesOnly = false;
  String _sortOption = 'alphabetical'; // 'alphabetical', 'difficulty'

  // Store favorite word IDs
  Set<int> favoriteWordIds = {};

  @override
  void initState() {
    super.initState();
    _loadWords();
    _loadFavorites();
  }

  // Load words from Supabase
  Future<void> _loadWords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch words for the current section
      final wordsResponse = await _supabase
          .from('Words')
          .select()
          .eq('section_id', widget.sectionId)
          .order('word');

      setState(() {
        words = wordsResponse;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading words: $e');
      setState(() {
        _errorMessage = 'Failed to load words. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  // Load user's favorites
  Future<void> _loadFavorites() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      final response = await _supabase
          .from('UserFavorites')
          .select('word_id')
          .eq('user_id', user.uid);

      setState(() {
        favoriteWordIds =
            response.map<int>((item) => item['word_id'] as int).toSet();
      });
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // Filter and sort words based on user preferences
  List<Map<String, dynamic>> _getFilteredWords() {
    List<Map<String, dynamic>> filteredList = List.from(words);

    // Apply search filter if query exists
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList.where((word) {
        return word['word']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (word['description'] != null &&
                word['description']
                    .toString()
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Apply favorites filter if enabled
    if (_showFavoritesOnly) {
      filteredList = filteredList
          .where((word) => favoriteWordIds.contains(word['id']))
          .toList();
    }

    // Apply sorting
    if (_sortOption == 'alphabetical') {
      filteredList
          .sort((a, b) => a['word'].toString().compareTo(b['word'].toString()));
    } else if (_sortOption == 'difficulty') {
      // Sort by difficulty level (assuming levels like 'beginner', 'intermediate', 'advanced')
      filteredList.sort((a, b) {
        // Define the order of difficulty levels
        final difficultyOrder = {
          'beginner': 0,
          'intermediate': 1,
          'advanced': 2,
        };

        final diffA = a['difficulty_level'] ?? 'beginner';
        final diffB = b['difficulty_level'] ?? 'beginner';

        return (difficultyOrder[diffA] ?? 0)
            .compareTo(difficultyOrder[diffB] ?? 0);
      });
    }

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    final filteredWords = _getFilteredWords();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom app bar
              Padding(
                padding: EdgeInsets.only(top: 27.h, left: 28.w, right: 28.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/icons/back-arrow.png',
                        width: 22.w,
                        height: 22.h,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    Text(
                      'Words',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Show options menu
                        _showOptionsMenu();
                      },
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.black,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Loading indicator or error message
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00D0FF),
                    ),
                  ),
                )
              else if (_errorMessage.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60.sp,
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          _errorMessage,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16.sp,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30.h),
                        ElevatedButton(
                          onPressed: _loadWords,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00D0FF),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                          ),
                          child: Text(
                            'Try Again',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Expanded section with content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _loadWords();
                      await _loadFavorites();
                    },
                    color: Color(0xFF00D0FF),
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 28.w),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        // Search bar
                        // Search bar
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search words...',
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFC7C7C7),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: const Color(0xFF00D0FF),
                                size: 20.sp,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF1F3F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: const Color(0xFF00D0FF),
                                  width: 1.0,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14.h,
                                horizontal: 16.w,
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // Category title with colored word
                        Padding(
                          padding: EdgeInsets.only(bottom: 30.h),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
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
                        ),

                        // Words list or empty state
                        filteredWords.isNotEmpty
                            ? Column(
                                children: filteredWords
                                    .map((word) => _buildWordCard(word))
                                    .toList(),
                              )
                            : Center(
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
                              ),

                        // Bottom spacing
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Word card widget
  Widget _buildWordCard(Map<String, dynamic> word) {
    return GestureDetector(
      onTap: () {
        // Show word details
        _navigateToWordDetail(word);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Sign image with proper handling
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                word['image_path'] ?? 'assets/images/signs/default.png',
                width: 60.w,
                height: 60.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.sign_language,
                      size: 30.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Word and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word['word'] ?? 'Unknown',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    word['description'] ?? '',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.sp,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow icon
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: Color(0xFF00D0FF),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00D0FF).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show options menu
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
            _buildOptionItem(
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
            _buildOptionItem(
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
            _buildOptionItem(
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
            _buildOptionItem(
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

  // Option item widget
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Color(0xFF00D0FF) : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 16.sp,
          color: isSelected ? Color(0xFF00D0FF) : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }

  // Navigate to word detail page
  void _navigateToWordDetail(Map<String, dynamic> word) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordDetailPage(
          wordId: word['id'],
          word: word['word'] ?? 'Unknown',
          description: word['description'] ?? '',
          image: word['image_path'] ?? 'assets/images/signs/default.png',
          categoryColor: widget.categoryColor,
          videoPath: word['video_path'],
        ),
      ),
    ).then((_) {
      // Refresh favorites when coming back from word detail page
      _loadFavorites();
    });
  }
}
