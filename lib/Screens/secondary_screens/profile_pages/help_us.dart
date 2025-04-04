import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/services/media/media_picker_service.dart';
import 'package:eazytalk/services/upload/media_upload_service.dart';
import 'package:eazytalk/widgets/common/info_card.dart';
import 'package:eazytalk/widgets/common/modal_header.dart';
import 'package:eazytalk/widgets/inputs/form_field_container.dart';
import 'package:eazytalk/widgets/media/media_preview.dart';
import 'package:eazytalk/widgets/buttons/primary_button.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

class HelpUsPage extends StatefulWidget {
  const HelpUsPage({Key? key}) : super(key: key);

  @override
  State<HelpUsPage> createState() => _HelpUsPageState();
}

class _HelpUsPageState extends State<HelpUsPage> {
  // Media selection and preview
  File? _mediaFile;
  bool _isVideo = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  // Form data
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _signNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;

  // Loading state
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Available categories for signs
  List<String> get _categories {
    final l10n = AppLocalizations.of(context);
    return [
      l10n.translate('alphabet'),
      l10n.translate('numbers'),
      l10n.translate('common_phrases'),
      l10n.translate('greetings'),
      l10n.translate('family'),
      l10n.translate('colors'),
      l10n.translate('time'),
      l10n.translate('food'),
      l10n.translate('weather'),
      l10n.translate('other'),
    ];
  }

  // Services
  final MediaPickerService _mediaPickerService = MediaPickerService();
  final MediaUploadService _mediaUploadService = MediaUploadService();

  @override
  void dispose() {
    _signNameController.dispose();
    _descriptionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  // Handle media selection
  void _handleMediaSelection(File file, bool isVideo, VideoPlayerController? controller) {
    setState(() {
      _mediaFile = file;
      _isVideo = isVideo;
      
      if (_videoController != null) {
        _videoController!.dispose();
      }
      
      _videoController = controller;
      _isVideoInitialized = controller != null;
    });
  }

  // Show media picker options
  void _showMediaPickerOptions() {
    _mediaPickerService.showMediaPickerOptions(
      context,
      onMediaSelected: _handleMediaSelection,
    );
  }

  // Update progress during upload
  void _updateProgress(double progress) {
    if (mounted) {
      setState(() {
        _uploadProgress = progress;
      });
    }
  }

  // Handle media upload
  Future<void> _uploadData() async {
    if (_mediaFile == null) {
      _showSnackBar(AppLocalizations.of(context).translate('help_us_please_select'));
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final result = await _mediaUploadService.uploadSignMedia(
        mediaFile: _mediaFile!,
        isVideo: _isVideo,
        signName: _signNameController.text,
        category: _selectedCategory!,
        description: _descriptionController.text,
        onProgressUpdate: _updateProgress,
      );

      if (result['success']) {
        // Reset form
        _resetForm();
        _showThankYouDialog();
      } else {
        _showSnackBar(result['message']);
      }
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context).translate('help_us_error_upload', [e.toString()]));
    } finally {
      if (mounted && _isUploading) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // Reset form after successful submission
  void _resetForm() {
    setState(() {
      _mediaFile = null;
      _isVideo = false;
      if (_videoController != null) {
        _videoController!.dispose();
        _videoController = null;
      }
      _isVideoInitialized = false;
      _signNameController.clear();
      _descriptionController.clear();
      _selectedCategory = null;
    });
  }

  // Show thank you dialog after successful submission
  void _showThankYouDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final secondaryTextColor = isDarkMode ? Colors.grey[300] : Colors.black87;
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        contentPadding: EdgeInsets.all(20.r),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 50.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.translate('thank_you'),
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.translate('submission_thanks'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
                color: secondaryTextColor,
              ),
            ),
            SizedBox(height: 20.h),
            PrimaryButton(
              text: l10n.translate('continue'),
              onPressed: () => Navigator.pop(context),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  // Show snackbar for feedback
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: ModalHeader(
                      title: l10n.translate('help_us_title'),
                      onClose: () => Navigator.pop(context),
                    ),
                  ),
          
                  SizedBox(height: 30.h),
          
                  // Form content
                  Expanded(
                    child: _buildFormContent(),
                  ),
                ],
              ),
          
              // Loading overlay
              if (_isUploading)
                _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // Build main form content
  Widget _buildFormContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction section
            InfoCard(
              title: l10n.translate('contribute'),
              content: l10n.translate('contribute_content'),
              icon: Icons.lightbulb_outline,
            ),

            SizedBox(height: 24.h),

            // Media upload section
            Text(
              l10n.translate('upload_sign'),
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: 16.h),

            // Media preview
            MediaPreview(
              mediaFile: _mediaFile,
              isVideo: _isVideo,
              videoController: _videoController,
              isVideoInitialized: _isVideoInitialized,
              onTap: _showMediaPickerOptions,
              isDarkMode: isDarkMode,
            ),

            // Media action buttons (change/remove)
            if (_mediaFile != null)
              _buildMediaActionButtons(),

            SizedBox(height: 24.h),

            // Sign details section
            Text(
              l10n.translate('sign_details'),
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: 16.h),

            // Sign name field
            FormFieldContainer(
              label: l10n.translate('sign_name'),
              child: _buildSignNameField(isDarkMode),
            ),

            SizedBox(height: 16.h),

            // Category dropdown
            FormFieldContainer(
              label: l10n.translate('category'),
              child: _buildCategoryDropdown(isDarkMode),
            ),

            SizedBox(height: 16.h),

            // Description field
            FormFieldContainer(
              label: l10n.translate('description_optional'),
              child: _buildDescriptionField(isDarkMode),
            ),

            SizedBox(height: 32.h),

            // Submit button
            PrimaryButton(
              text: l10n.translate('submit_sign'),
              onPressed: _isUploading ? null : _uploadData,
              width: double.infinity,
            ),

            SizedBox(height: 20.h),

            // Additional information
            InfoCard(
              content: l10n.translate('review_note'),
              icon: Icons.info_outline,
            ),
            
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // Build media action buttons (change/remove)
  Widget _buildMediaActionButtons() {
    final textColor = AppColors.getTextPrimaryColor(context);
    final l10n = AppLocalizations.of(context);
    
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: _showMediaPickerOptions,
            icon: Icon(
              Icons.refresh,
              size: 16.sp,
              color: AppColors.primary,
            ),
            label: Text(
              l10n.translate('help_us_change'),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12.sp,
                color: AppColors.primary,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _mediaFile = null;
                _isVideo = false;
                if (_videoController != null) {
                  _videoController!.dispose();
                  _videoController = null;
                }
                _isVideoInitialized = false;
              });
            },
            icon: Icon(
              Icons.delete_outline,
              size: 16.sp,
              color: Colors.red,
            ),
            label: Text(
              l10n.translate('help_us_remove'),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12.sp,
                color: Colors.red,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build sign name field
  Widget _buildSignNameField(bool isDarkMode) {
    final textColor = AppColors.getTextPrimaryColor(context);
    final backgroundColor = isDarkMode ? const Color(0xFF2A2A2A) : AppColors.backgroundGrey;
    final hintColor = isDarkMode ? Colors.grey[600] : Colors.black38;
    final l10n = AppLocalizations.of(context);
    
    return TextFormField(
      controller: _signNameController,
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14.sp,
        color: textColor,
      ),
      decoration: InputDecoration(
        hintText: l10n.translate('enter_sign'),
        hintStyle: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14.sp,
          color: hintColor,
        ),
        filled: true,
        fillColor: backgroundColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.translate('required_field');
        }
        return null;
      },
    );
  }

  // Build category dropdown
  Widget _buildCategoryDropdown(bool isDarkMode) {
    final textColor = AppColors.getTextPrimaryColor(context);
    final backgroundColor = isDarkMode ? const Color(0xFF2A2A2A) : AppColors.backgroundGrey;
    final hintColor = isDarkMode ? Colors.grey[600] : Colors.black38;
    final dropdownIconColor = isDarkMode ? Colors.grey[400] : Colors.black54;
    final l10n = AppLocalizations.of(context);
    
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      dropdownColor: AppColors.getSurfaceColor(context),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        hintText: l10n.translate('select_category'),
        hintStyle: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14.sp,
          color: hintColor,
        ),
      ),
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14.sp,
        color: textColor,
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(
            category,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
              color: textColor,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return l10n.translate('required_field');
        }
        return null;
      },
      icon: Icon(
        Icons.arrow_drop_down,
        color: dropdownIconColor,
      ),
    );
  }

  // Build description field
  Widget _buildDescriptionField(bool isDarkMode) {
    final textColor = AppColors.getTextPrimaryColor(context);
    final backgroundColor = isDarkMode ? const Color(0xFF2A2A2A) : AppColors.backgroundGrey;
    final hintColor = isDarkMode ? Colors.grey[600] : Colors.black38;
    final l10n = AppLocalizations.of(context);
    
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14.sp,
        color: textColor,
      ),
      decoration: InputDecoration(
        hintText: l10n.translate('add_info'),
        hintStyle: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14.sp,
          color: hintColor,
        ),
        filled: true,
        fillColor: backgroundColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Build loading overlay
  Widget _buildLoadingOverlay() {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: _uploadProgress,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.translate('help_us_upload_progress', [(_uploadProgress * 100).toStringAsFixed(0)]),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}