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
  final List<String> _categories = [
    'Alphabet',
    'Numbers',
    'Common Phrases',
    'Greetings',
    'Family',
    'Colors',
    'Time',
    'Food',
    'Weather',
    'Other'
  ];

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
      _showSnackBar('Please select a photo or video first');
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
      _showSnackBar('Error uploading sign: $e');
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              'Thank You!',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Your sign has been submitted for review. Your contribution helps make communication more accessible for everyone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20.h),
            PrimaryButton(
              text: 'Continue',
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
    return Scaffold(
      backgroundColor: Colors.white,
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
                      title: 'Help Us Improve',
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
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction section
            InfoCard(
              title: 'Contribute to EazyTalk',
              content: 'Help us expand our sign language database by submitting signs you know. Your contributions make EazyTalk better for everyone!',
              icon: Icons.lightbulb_outline,
            ),

            SizedBox(height: 24.h),

            // Media upload section
            Text(
              'Upload Sign',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
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
            ),

            // Media action buttons (change/remove)
            if (_mediaFile != null)
              _buildMediaActionButtons(),

            SizedBox(height: 24.h),

            // Sign details section
            Text(
              'Sign Details',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),

            // Sign name field
            FormFieldContainer(
              label: 'Sign Name:',
              child: _buildSignNameField(),
            ),

            SizedBox(height: 16.h),

            // Category dropdown
            FormFieldContainer(
              label: 'Category:',
              child: _buildCategoryDropdown(),
            ),

            SizedBox(height: 16.h),

            // Description field
            FormFieldContainer(
              label: 'Description (Optional):',
              child: _buildDescriptionField(),
            ),

            SizedBox(height: 32.h),

            // Submit button
            PrimaryButton(
              text: 'Submit Sign',
              onPressed: _isUploading ? null : _uploadData,
              width: double.infinity,
            ),

            SizedBox(height: 20.h),

            // Additional information
            InfoCard(
              content: 'Your submission will be reviewed by our team before being added to the app.',
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
              'Change',
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
              'Remove',
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
  Widget _buildSignNameField() {
    return TextFormField(
      controller: _signNameController,
      decoration: InputDecoration(
        hintText: 'Enter the meaning of this sign',
        hintStyle: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14.sp,
          color: Colors.black38,
        ),
        filled: true,
        fillColor: AppColors.backgroundGrey,
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
          return 'Please enter the sign name';
        }
        return null;
      },
    );
  }

// Build category dropdown
 Widget _buildCategoryDropdown() {
   return Container(
     decoration: BoxDecoration(
       color: AppColors.backgroundGrey,
       borderRadius: BorderRadius.circular(12.r),
     ),
     child: DropdownButtonFormField<String>(
       value: _selectedCategory,
       decoration: InputDecoration(
         contentPadding: EdgeInsets.symmetric(
           horizontal: 16.w,
           vertical: 14.h,
         ),
         border: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12.r),
           borderSide: BorderSide.none,
         ),
         hintText: 'Select a category',
         hintStyle: TextStyle(
           fontFamily: 'DM Sans',
           fontSize: 14.sp,
           color: Colors.black38,
         ),
       ),
       items: _categories.map((category) {
         return DropdownMenuItem<String>(
           value: category,
           child: Text(
             category,
             style: TextStyle(
               fontFamily: 'DM Sans',
               fontSize: 14.sp,
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
           return 'Please select a category';
         }
         return null;
       },
       icon: Icon(
         Icons.arrow_drop_down,
         color: Colors.black54,
       ),
       dropdownColor: Colors.white,
     ),
   );
 }

 // Build description field
 Widget _buildDescriptionField() {
   return TextFormField(
     controller: _descriptionController,
     maxLines: 3,
     decoration: InputDecoration(
       hintText: 'Add any additional information about this sign',
       hintStyle: TextStyle(
         fontFamily: 'DM Sans',
         fontSize: 14.sp,
         color: Colors.black38,
       ),
       filled: true,
       fillColor: AppColors.backgroundGrey,
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
             'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
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