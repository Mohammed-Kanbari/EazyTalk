import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:eazytalk/models/instruction_model.dart';
import 'package:eazytalk/models/tip_model.dart';
import 'package:eazytalk/services/sign_language/sign_language_service.dart';
import 'package:eazytalk/services/favorites/favorites_service.dart';
import 'package:eazytalk/services/video/video_service.dart';
import 'package:eazytalk/widgets/common/error_display.dart';
import 'package:eazytalk/widgets/words/word_video_player.dart';
import 'package:eazytalk/widgets/words/word_info_card.dart';
import 'package:eazytalk/widgets/words/word_tabs.dart';
import 'package:eazytalk/widgets/words/instruction_step.dart';
import 'package:eazytalk/widgets/words/tip_item.dart';
import 'package:eazytalk/widgets/words/empty_tab_content.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

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
  final SignLanguageService _signService = SignLanguageService();
  final FavoritesService _favoritesService = FavoritesService();
  
  // State variables
  bool _isLoading = true;
  bool _isFavorite = false;
  int _selectedTabIndex = 0;
  String _errorMessage = '';
  String _translation = '';
  
  // Data from services
  List<InstructionModel> _instructions = [];
  List<TipModel> _tips = [];
  String _difficultyLevel = 'beginner';
  bool _isCommonPhrase = false;
  
  // Video player
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  
  // Tab titles for both English and Arabic
  late List<String> _tabTitles;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadWordDetails();
    _checkIfFavorite();
  }

  // Initialize video player
  Future<void> _initializeVideo() async {
    if (widget.videoPath != null && widget.videoPath!.isNotEmpty) {
      final controller = await VideoService.initializeAssetVideo(widget.videoPath);
      
      if (controller != null && mounted) {
        setState(() {
          _videoController = controller;
          _isVideoInitialized = true;
        });
      }
    }
  }

  // Load word details from service
  Future<void> _loadWordDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final details = await _signService.fetchWordDetails(widget.wordId);
      
      setState(() {
        _instructions = details['instructions'];
        _tips = details['tips'];
        _difficultyLevel = details['difficultyLevel'];
        _isCommonPhrase = details['isCommonPhrase'];
        _translation = details['translation'];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Check if word is in favorites
  Future<void> _checkIfFavorite() async {
    try {
      final favorites = await _favoritesService.getUserFavorites();
      
      if (mounted) {
        setState(() {
          _isFavorite = favorites.contains(widget.wordId);
        });
      }
    } catch (e) {
      print('Error checking favorites: $e');
    }
  }

  // Toggle favorite status
  Future<void> _toggleFavorite() async {
    try {
      // Optimistic update
      setState(() {
        _isFavorite = !_isFavorite;
      });
      
      // Call service to update favorite status
      final success = await _favoritesService.toggleFavorite(widget.wordId);
      
      // Revert if failed
      if (!success && mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
    } catch (e) {
      // Revert and show error
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating favorites: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    VideoService.disposeController(_videoController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    // Initialize tab titles
    _tabTitles = [
      AppLocalizations.of(context).translate('description'),
      AppLocalizations.of(context).translate('instructions'),
      AppLocalizations.of(context).translate('tips'),
    ];
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Custom header with back button and favorite button
            Padding(
              padding: EdgeInsets.only(top: 27.h, left: 28.w, right: 28.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(isRTL ? 3.14159 : 0),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/icons/back-arrow.png',
                width: 22.w,
                height: 22.h,
                color: textColor,
                errorBuilder: (context, error, stackTrace) => Icon(
                  isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  size: 20.sp,
                  color: textColor,
                ),
              ),
            ),
          ),
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Color(0xFF2A2A2A) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : textColor,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content area
            _buildContent(),
          ],
        ),
      ),
    );
  }

  // Build content based on loading state
  Widget _buildContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
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
          onRetry: _loadWordDetails,
        ),
      );
    } else {
      return Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Video player
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 60.h),
                child: WordVideoPlayer(
                  controller: _videoController,
                  isInitialized: _isVideoInitialized,
                ),
              ),

              // Word info card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: WordInfoCard(
                  word: widget.word,
                  translation: _translation,
                  difficultyLevel: _getDifficultyText(_difficultyLevel),
                  difficultyColor: _getDifficultyColor(_difficultyLevel, isDarkMode),
                  isCommonPhrase: _isCommonPhrase,
                  isDarkMode: isDarkMode,
                ),
              ),

              // Tabs section
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Column(
                  children: [
                    // Tab bar
                    WordTabs(
                      tabTitles: _tabTitles,
                      selectedTabIndex: _selectedTabIndex,
                      onTabSelected: (index) {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                    ),

                    // Tab content
                    Padding(
                      padding: EdgeInsets.all(28.r),
                      child: _buildTabContent(isDarkMode),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Build tab content based on selected tab
  Widget _buildTabContent(bool isDarkMode) {
    switch (_selectedTabIndex) {
      case 0: // Description
        return _buildDescriptionTab(isDarkMode);
      case 1: // Instructions
        return _buildInstructionsTab(isDarkMode);
      case 2: // Tips
        return _buildTipsTab(isDarkMode);
      default:
        return _buildDescriptionTab(isDarkMode);
    }
  }

  // Description tab content
  Widget _buildDescriptionTab(bool isDarkMode) {
    final textColor = AppColors.getTextPrimaryColor(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.description,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16.sp,
            height: 1.5,
            color: textColor,
          ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 20.h),
        SizedBox(height: 8.h),
        // Empty text to maintain spacing consistent with original design
        Text(
          '',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16.sp,
            height: 1.5,
            color: textColor,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  // Instructions tab content
  Widget _buildInstructionsTab(bool isDarkMode) {
    if (_instructions.isEmpty) {
      return EmptyTabContent(
        message: AppLocalizations.of(context).translate('no_instructions'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _instructions.map((instruction) {
        return InstructionStep(
          number: instruction.stepNumber.toString(),
          description: instruction.instruction,
        );
      }).toList(),
    );
  }

  // Tips tab content
  Widget _buildTipsTab(bool isDarkMode) {
    if (_tips.isEmpty) {
      return EmptyTabContent(
        message: AppLocalizations.of(context).translate('no_tips'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _tips.map((tip) {
        return TipItem(
          text: tip.tip,
        );
      }).toList(),
    );
  }
  
  // Helper method to get difficulty text in Arabic
  String _getDifficultyText(String level) {
    return AppLocalizations.of(context).translate(level);
  }

  // Helper method to get difficulty color with dark mode support
  Color _getDifficultyColor(String level, bool isDarkMode) {
    Color baseColor;
    
    switch (level) {
      case 'beginner':
        baseColor = Color(0xFFFCE8DD); // Light orange
        break;
      case 'intermediate':
        baseColor = Color(0xFFD4F8E5); // Light green
        break;
      case 'advanced':
        baseColor = Color(0xFFFFDDF4); // Light pink
        break;
      default:
        baseColor = Color(0xFFFCE8DD); // Light orange
    }
    
    // If in dark mode, adjust the color to be darker but still visible
    if (isDarkMode) {
      final hsl = HSLColor.fromColor(baseColor);
      return hsl.withLightness(hsl.lightness * 0.6).toColor(); // Reduce lightness for dark mode
    }
    
    return baseColor;
  }
}