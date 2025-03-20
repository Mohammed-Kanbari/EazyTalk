import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

class WordDetailPage extends StatefulWidget {
  final int wordId;
  final String word;
  final String description;
  final String image;
  final Color categoryColor;
  final String? videoPath;

  const WordDetailPage({
    Key? key,
    required this.wordId,
    required this.word,
    required this.description,
    required this.image,
    required this.categoryColor,
    this.videoPath,
  }) : super(key: key);

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  bool isFavorite = false;
  int _selectedTabIndex = 0;
  String _errorMessage = '';
  
  // Video player
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  // Data from Supabase
  List<Map<String, dynamic>> instructions = [];
  List<Map<String, dynamic>> tips = [];
  String difficultyLevel = 'beginner';
  bool isCommonPhrase = false;

  final List<String> _tabTitles = ['وصف', 'تعليمات', 'نصائح للإتقان'];

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadWordDetails();
    _checkIfFavorite();
  }

  // Initialize video player if video path is available
  void _initializeVideo() {
    if (widget.videoPath != null && widget.videoPath!.isNotEmpty) {
      _videoController = VideoPlayerController.asset(widget.videoPath!)
        ..initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
          });
        }).catchError((error) {
          print("Error initializing video: $error");
        });
    }
  }

  // Load word details from Supabase (instructions and tips)
  Future<void> _loadWordDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch instructions for this word
      final instructionsResponse = await _supabase
          .from('Instructions')
          .select()
          .eq('word_id', widget.wordId)
          .order('step_number');

      // Fetch tips for this word
      final tipsResponse = await _supabase
          .from('Tips')
          .select()
          .eq('word_id', widget.wordId);

      // Fetch additional word details
      final wordDetailsResponse = await _supabase
          .from('Words')
          .select('difficulty_level, is_common_phrase')
          .eq('id', widget.wordId)
          .single();

      setState(() {
        instructions = instructionsResponse;
        tips = tipsResponse;
        
        // Set difficulty level and commonality
        if (wordDetailsResponse != null) {
          difficultyLevel = wordDetailsResponse['difficulty_level'] ?? 'beginner';
          isCommonPhrase = wordDetailsResponse['is_common_phrase'] ?? false;
        }
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading word details: $e');
      setState(() {
        _errorMessage = 'Failed to load word details.';
        _isLoading = false;
      });
    }
  }

  // Check if word is favorited
// Fix for the user ID null check in _checkIfFavorite() method
Future<void> _checkIfFavorite() async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    
    // If user is not logged in, we can't check favorites
    if (userId == null) {
      return;
    }
    
    // Now that we've checked userId is not null, we can safely use it
    final response = await _supabase
        .from('UserFavorites')
        .select()
        .eq('user_id', userId) // userId is guaranteed non-null here
        .eq('word_id', widget.wordId);

    setState(() {
      isFavorite = response.isNotEmpty;
    });
  } catch (e) {
    print('Error checking favorites: $e');
  }
}

// Similarly, fix the _toggleFavorite() method
Future<void> _toggleFavorite() async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to be signed in to save favorites')),
      );
      return;
    }

    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      // Add to favorites
      await _supabase.from('UserFavorites').insert({
        'user_id': userId, // userId is guaranteed non-null here
        'word_id': widget.wordId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      // Remove from favorites
      await _supabase
          .from('UserFavorites')
          .delete()
          .eq('user_id', userId) // userId is guaranteed non-null here
          .eq('word_id', widget.wordId);
    }
  } catch (e) {
    print('Error toggling favorite: $e');
    // Revert state if operation failed
    setState(() {
      isFavorite = !isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update favorites')),
    );
  }
}


  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.black,
                        size: 18.sp,
                      ),
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
                        onPressed: _loadWordDetails,
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Video card
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 28.w, vertical: 60.h),
                        child: Container(
                          width: double.infinity,
                          height: 200.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Show video player if initialized, otherwise show image
                                _isVideoInitialized && _videoController != null
                                    ? VideoPlayer(_videoController!)
                                    : Image.asset(
                                        widget.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.videocam,
                                                size: 50.sp,
                                                color: Colors.grey[400],
                                              ),
                                              SizedBox(height: 8.h),
                                              Text(
                                                'Video demonstration',
                                                style: TextStyle(
                                                  fontFamily: 'DM Sans',
                                                  fontSize: 14.sp,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                // Play button overlay
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_videoController != null && _isVideoInitialized) {
                                        setState(() {
                                          _videoController!.value.isPlaying
                                              ? _videoController!.pause()
                                              : _videoController!.play();
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 60.h,
                                      height: 60.h,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _videoController != null && _isVideoInitialized && _videoController!.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Color(0xFF00D0FF),
                                        size: 40.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Word card with tags
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28.w),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: 24.h, horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Color(0xFFE8E8E8),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                spreadRadius: 2,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Arabic word title
                              Text(
                                widget.word,
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 28.sp, // Larger text size
                                  fontWeight: FontWeight.w700, // Bolder text
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 20.h), // More spacing

                              // Tags row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildTag(
                                    _getDifficultyText(difficultyLevel), 
                                    _getDifficultyColor(difficultyLevel),
                                  ),
                                  SizedBox(width: 16.w), // Spacing between tags
                                  if (isCommonPhrase)
                                    _buildTag('عبارة شائعة', Color(0xFFE6DAFF)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tabs section
                      Padding(
                        padding: EdgeInsets.only(top: 16.h),
                        child: Column(
                          children: [
                            // Tab bar
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 28.w),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: List.generate(
                                  _tabTitles.length,
                                  (index) => _buildTabItem(index),
                                ),
                              ),
                            ),

                            // Tab content
                            Padding(
                              padding: EdgeInsets.all(28.r),
                              child: _buildTabContent(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Build tag widget
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14.sp, // Slightly larger
          fontWeight: FontWeight.w600, // Bolder
          color: Colors.black87,
        ),
      ),
    );
  }

  // Get text for difficulty level
  String _getDifficultyText(String level) {
    switch (level) {
      case 'beginner':
        return 'مبتدئ';
      case 'intermediate':
        return 'متوسط';
      case 'advanced':
        return 'متقدم';
      default:
        return 'مبتدئ';
    }
  }

  // Get color for difficulty level
  Color _getDifficultyColor(String level) {
    switch (level) {
      case 'beginner':
        return Color(0xFFFCE8DD); // Light orange
      case 'intermediate':
        return Color(0xFFD4F8E5); // Light green
      case 'advanced':
        return Color(0xFFFFDDF4); // Light pink
      default:
        return Color(0xFFFCE8DD); // Light orange
    }
  }

  // Build tab item widget
  Widget _buildTabItem(int index) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Color(0xFF00D0FF) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            _tabTitles[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Color(0xFF00D0FF) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // Build tab content based on selected tab
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // Description
        return _buildDescriptionTab();
      case 1: // Instructions
        return _buildInstructionsTab();
      case 2: // Tips
        return _buildTipsTab();
      default:
        return _buildDescriptionTab();
    }
  }

  // Description tab content
  Widget _buildDescriptionTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.description,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16.sp,
            height: 1.5,
            color: Colors.black87,
          ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 20.h),
        SizedBox(height: 8.h),
        Text(
          '',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16.sp,
            height: 1.5,
            color: Colors.black87,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  // Instructions tab content with data from Supabase
  Widget _buildInstructionsTab() {
    if (instructions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48.sp,
                color: Colors.grey,
              ),
              SizedBox(height: 16.h),
              Text(
                'لا توجد تعليمات متاحة لهذه الإشارة',
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: instructions.map((instruction) {
        return _buildInstructionStep(
          number: instruction['step_number'].toString(),
          description: instruction['instruction'],
        );
      }).toList(),
    );
  }

  // Tips tab content with data from Supabase
  Widget _buildTipsTab() {
    if (tips.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48.sp,
                color: Colors.grey,
              ),
              SizedBox(height: 16.h),
              Text(
                'لا توجد نصائح متاحة لهذه الإشارة',
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tips.map((tip) {
        return _buildTipItem(tip['tip']);
      }).toList(),
    );
  }

  // Build instruction step widget
  Widget _buildInstructionStep({
    required String number,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: Color(0xFF00D0FF).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00D0FF),
                ),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16.sp,
                height: 1.5,
                color: Colors.black87,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  // Build tip item widget
  Widget _buildTipItem(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF00D0FF),
            size: 24.sp,
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16.sp,
                height: 1.5,
                color: Colors.black87,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}