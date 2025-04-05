import 'package:eazytalk/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/services/sign_language/text_to_sign_service.dart';
import 'package:eazytalk/widgets/common/secondary_header.dart';
import 'package:eazytalk/widgets/speech_to_text/text_area.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

class TextToSignScreen extends StatefulWidget {
  const TextToSignScreen({Key? key}) : super(key: key);

  @override
  State<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends State<TextToSignScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextToSignService _textToSignService = TextToSignService();
  
  // State variables
  bool _isLoading = false;
  bool _hasResult = false;
  List<Map<String, dynamic>> _signData = []; // Contains both words and letters data
  Map<int, bool> _imageLoadErrors = {}; // Track which images failed to load
  String _errorMessage = '';
  String _selectedDisplayMode = 'image'; // 'image' or 'avatar'
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Convert text to sign language
  Future<void> _convertTextToSign() async {
    final text = _textController.text.trim();
    
    if (text.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).translate('enter_text_first');
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasResult = false;
      _imageLoadErrors.clear(); // Reset image load errors
      _signData.clear();
    });
    
    try {
      if (_selectedDisplayMode == 'image') {
        // Call service to get sign language images
        final results = await _textToSignService.convertTextToSignImages(text);
        
        if (results.isEmpty) {
          setState(() {
            _errorMessage = AppLocalizations.of(context).translate('no_images_found') ?? 
                            'No sign language images found for the text';
            _isLoading = false;
          });
          return;
        }
        
        setState(() {
          _signData = results;
          _hasResult = true;
          _isLoading = false;
        });
      } else {
        // In avatar mode, we'll get the animation URL
        final success = await _textToSignService.prepareAvatarAnimation(text);
        
        setState(() {
          _hasResult = success;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  // Handle image load errors
  void _onImageError(int index) {
    setState(() {
      _imageLoadErrors[index] = true;
    });
    
    // Check if all images failed
    final letterItems = _signData.where((item) => item['type'] == 'letter').toList();
    if (_imageLoadErrors.length == letterItems.length && letterItems.isNotEmpty) {
      // All images failed to load
      setState(() {
        _errorMessage = AppLocalizations.of(context).translate('images_failed_to_load') ??
                        'All images failed to load. Try simpler words or a different phrase.';
      });
    }
  }
  
  // Try fallback image URL when primary image fails to load
  void _tryFallbackImageUrl(int index, String letter) async {
    try {
      // Find the item at this index
      final item = _signData.firstWhere(
        (item) => item['type'] == 'letter' && item['letter'] == letter,
        orElse: () => {},
      );
      
      if (item.isEmpty || !item.containsKey('fallbackUrls')) return;
      
      final fallbackUrls = item['fallbackUrls'];
      if (fallbackUrls != null && fallbackUrls.isNotEmpty) {
        setState(() {
          // Update the URL to the fallback
          item['url'] = fallbackUrls.first;
          
          // Remove the used fallback URL from the list
          List<String> newFallbackUrls = List<String>.from(fallbackUrls);
          newFallbackUrls.removeAt(0);
          item['fallbackUrls'] = newFallbackUrls;
          
          // Remove from error tracking to retry with new URL
          _imageLoadErrors.remove(index);
        });
      }
    } catch (e) {
      print('Error getting fallback URL: $e');
      // Keep the error state
    }
  }
  
  // Copy text to clipboard
  void _copyText() {
    if (_textController.text.isNotEmpty) {
      _textToSignService.copyToClipboard(_textController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('copy_to_clipboard')))
      );
    }
  }
  
  // Clear input text
  void _clearText() {
    setState(() {
      _textController.clear();
      _hasResult = false;
      _signData = [];
      _errorMessage = '';
      _imageLoadErrors.clear();
    });
  }
  
  // Toggle between image and avatar modes
  void _toggleDisplayMode() {
    setState(() {
      _selectedDisplayMode = _selectedDisplayMode == 'image' ? 'avatar' : 'image';
      // Clear previous results when switching modes
      _hasResult = false;
      _signData = [];
      _imageLoadErrors.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Header
              SecondaryHeader(
                title: localizations.translate('text_to_sign'),
                onBackPressed: () => Navigator.pop(context),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 30.h),
                        
                        // Mode toggle button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildModeToggleButton(isDarkMode),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        
                        // Text input area
                        TranscriptionTextArea(
                          height: 230.h,
                          controller: _textController,
                          onChanged: (value) {},
                          onCopy: _copyText,
                          onClear: _clearText,
                          isDarkMode: isDarkMode,
                          hintText: localizations.translate('hint_text_to_sign') 
                        ),
                        
                        SizedBox(height: 30.h),
                        
                        // Convert button
                        _buildConvertButton(),
                        
                        SizedBox(height: 20.h),
                        
                        // Results section
                        if (_isLoading)
                          _buildLoadingIndicator()
                        else if (_errorMessage.isNotEmpty)
                          _buildErrorMessage()
                        else if (_hasResult)
                          _selectedDisplayMode == 'image'
                              ? _buildImageResults()
                              : _buildAvatarResult()
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build the mode toggle button
  Widget _buildModeToggleButton(bool isDarkMode) {
    return GestureDetector(
      onTap: _toggleDisplayMode,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedDisplayMode == 'image' ? Icons.person_outline : Icons.image,
              size: 18.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              _selectedDisplayMode == 'image' 
                  ? AppLocalizations.of(context).translate('use_avatar')
                  : AppLocalizations.of(context).translate('use_images'),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConvertButton() {
    final l10n = AppLocalizations.of(context);
    
    return PrimaryButton(
      text: l10n.translate('convert_to_sign'),
      onPressed: _isLoading ? null : _convertTextToSign,
      isLoading: _isLoading,
      margin: EdgeInsets.zero,
    );
  }
  
  // Build loading indicator
  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(height: 30.h),
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: 16.h),
        Text(
          AppLocalizations.of(context).translate('converting_to_sign'),
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16.sp,
            color: AppColors.getTextPrimaryColor(context),
          ),
        ),
      ],
    );
  }
  
  // Build error message
  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      margin: EdgeInsets.only(top: 20.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                AppLocalizations.of(context).translate('error'),
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            _errorMessage,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
              color: AppColors.getTextPrimaryColor(context),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build image results
  Widget _buildImageResults() {
    // Count actual letter items (exclude word markers)
    final letterItems = _signData.where((item) => item['type'] == 'letter').toList();
    
    // Check if all images failed to load
    bool allImagesFailed = letterItems.isNotEmpty && 
                          _imageLoadErrors.length == letterItems.length;
    
    if (allImagesFailed) {
      return _buildImagesFailedMessage();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('sign_language_representation') ?? 
          'ASL Fingerspelling Representation',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimaryColor(context),
          ),
        ),
        SizedBox(height: 16.h),
        
        // Original text display
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '"${_textController.text.trim()}"',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextPrimaryColor(context),
            ),
          ),
        ),
        
        SizedBox(height: 16.h),
        
        /* Explanation of fingerspelling
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('fingerspelling_note') ?? 
                'Note: This shows ASL fingerspelling (letter by letter)',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextPrimaryColor(context),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalizations.of(context).translate('fingerspelling_description') ?? 
                'Real ASL often uses specific signs for whole words rather than spelling each letter',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                  color: AppColors.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
        ), */
        
        SizedBox(height: 16.h),
        
        // Display words grouped by their letters
        ..._buildWordsWithLetters(),
        
        SizedBox(height: 20.h),
        
        // Attribution text
        Text(
          AppLocalizations.of(context).translate('powered_by_signconverter') ?? 
          'Powered by SignConverter.com - American Sign Language',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12.sp,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  // Build the words with their letters
  List<Widget> _buildWordsWithLetters() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List<Widget> wordGroups = [];
    
    int currentWordStart = -1;
    String currentWord = '';
    
    // Go through all sign data and group by words
    for (int i = 0; i < _signData.length; i++) {
      final item = _signData[i];
      
      if (item['type'] == 'word_marker') {
        // If we have a previous word, finish it
        if (currentWordStart >= 0) {
          wordGroups.add(
            _buildWordGroup(
              currentWord, 
              currentWordStart, 
              i - 1
            )
          );
        }
        
        // Start a new word
        currentWordStart = i + 1;
        currentWord = item['word'];
      }
    }
    
    // Add the last word if there is one
    if (currentWordStart >= 0 && currentWordStart < _signData.length) {
      wordGroups.add(
        _buildWordGroup(
          currentWord, 
          currentWordStart, 
          _signData.length - 1
        )
      );
    }
    
    return wordGroups;
  }
  
  // Build a group of letter signs for a word
  Widget _buildWordGroup(String word, int startIndex, int endIndex) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Get only the letter items in this range
    final letterItems = _signData
      .sublist(startIndex, endIndex + 1)
      .where((item) => item['type'] == 'letter')
      .toList();
    
    if (letterItems.isEmpty) {
      return SizedBox.shrink(); // Skip if no letters
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Word label
        Padding(
          padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
          child: Text(
            word,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimaryColor(context),
            ),
          ),
        ),
        
        // Grid of letter signs
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // More columns for letters
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 0.75,
          ),
          itemCount: letterItems.length,
          itemBuilder: (context, localIndex) {
            // Find the actual index in the _signData array
            int globalIndex = -1;
            for (int i = startIndex; i <= endIndex; i++) {
              if (_signData[i]['type'] == 'letter') {
                globalIndex++;
                if (globalIndex == localIndex) {
                  globalIndex = i;
                  break;
                }
              }
            }
            
            if (globalIndex < 0) {
              return SizedBox.shrink();
            }
            
            final letterItem = letterItems[localIndex];
            
            // Skip failed images
            if (_imageLoadErrors[globalIndex] == true) {
              return _buildPlaceholderCard(globalIndex, letterItem['letter']);
            }
            return _buildSignImageCard(letterItem['url'], globalIndex, letterItem['letter']);
          },
        ),
        
        Divider(height: 32.h, thickness: 1, color: isDarkMode ? Colors.grey[800] : Colors.grey[300]),
      ],
    );
  }
  
  // Build a message when all images fail to load
  Widget _buildImagesFailedMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      margin: EdgeInsets.only(top: 20.h),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                AppLocalizations.of(context).translate('warning') ?? 'Warning',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).translate('images_failed_to_load') ?? 
            'The sign language images could not be loaded.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
              color: AppColors.getTextPrimaryColor(context),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).translate('try_simpler_text') ?? 
            'Try using simpler words or common phrases.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
              fontStyle: FontStyle.italic,
              color: AppColors.getTextPrimaryColor(context),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build a placeholder card for failed images
  Widget _buildPlaceholderCard(int index, [String? letter]) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final label = letter ?? '#${index + 1}';
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Placeholder
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 24.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppLocalizations.of(context).translate('no_sign') ?? 'No sign',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10.sp,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Label
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.r)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build a single sign image card
  Widget _buildSignImageCard(String imageUrl, int index, [String? letter]) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final label = letter ?? '#${index + 1}';
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / 
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Mark image as failed
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _onImageError(index);
                        
                        // Try fallback URLs if available
                        if (letter != null) {
                          _tryFallbackImageUrl(index, letter);
                        }
                      });
                      return Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Label
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.r)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build avatar result
  Widget _buildAvatarResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('sign_language_animation'),
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimaryColor(context),
          ),
        ),
        SizedBox(height: 16.h),
        
        // Avatar animation view
        Container(
          width: double.infinity,
          height: 300.h,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: _textToSignService.getAvatarWidget(),
        ),
        
        SizedBox(height: 20.h),
        
        // Controls for avatar animation
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAvatarControlButton(
              icon: Icons.replay,
              label: AppLocalizations.of(context).translate('replay') ?? 'Replay',
              onPressed: _textToSignService.replayAvatarAnimation,
            ),
            SizedBox(width: 24.w),
            _buildAvatarControlButton(
              icon: Icons.speed,
              label: AppLocalizations.of(context).translate('speed') ?? 'Speed',
              onPressed: _textToSignService.toggleAvatarSpeed,
            ),
          ],
        ),
        
        SizedBox(height: 20.h),
        
        // Attribution text
        Text(
          AppLocalizations.of(context).translate('powered_by_signall') ?? 
          'Powered by SignAll AI',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12.sp,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  // Avatar control button
  Widget _buildAvatarControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12.sp,
              color: AppColors.getTextPrimaryColor(context),
            ),
          ),
        ],
      ),
    );
  }
}