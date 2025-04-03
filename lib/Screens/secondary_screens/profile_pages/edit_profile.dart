// lib/Screens/secondary_screens/profile_pages/edit_profile.dart
import 'package:eazytalk/l10n/app_localizations.dart';
import 'package:eazytalk/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/models/user_model.dart';
import 'package:eazytalk/services/profile/profile_image_service.dart';
import 'package:eazytalk/services/user/user_profile_service.dart';
import 'package:eazytalk/widgets/common/modal_header.dart';
import 'package:eazytalk/widgets/profile/profile_image_picker.dart';
import 'package:eazytalk/widgets/inputs/profile_form_field.dart';


class EditProfile extends StatefulWidget {
  final String? currentName;
  final String? currentEmail;
  final String? currentProfileImageUrl;
  final String? currentProfileImageBase64;

  const EditProfile({
    Key? key,
    this.currentName,
    this.currentEmail,
    this.currentProfileImageUrl,
    this.currentProfileImageBase64,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  File? _imageFile;
  String? _profileImageUrl;
  String? _profileImageBase64;
  bool _isLoading = false;

  // Service instances
  final UserProfileService _userProfileService = UserProfileService();
  final ProfileImageService _profileImageService = ProfileImageService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName ?? 'User');
    _emailController = TextEditingController(text: widget.currentEmail ?? '');
    _profileImageUrl = widget.currentProfileImageUrl;
    _profileImageBase64 = widget.currentProfileImageBase64;
    
    // If no data was passed, fetch current user data
    if (widget.currentName == null || widget.currentEmail == null) {
      _fetchUserData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Fetch user data from service
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userModel = await _userProfileService.fetchUserProfile();
      
      if (userModel != null) {
        setState(() {
          _nameController.text = userModel.userName;
          _emailController.text = userModel.email;
          _profileImageUrl = userModel.profileImageUrl;
          _profileImageBase64 = userModel.profileImageBase64;
        });
      }
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context).translate('error_update'), isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle image picking
  Future<void> _handleImagePick() async {
    final result = await _profileImageService.pickImageFromGallery(context);
    
    if (result['success']) {
      setState(() {
        _imageFile = result['file'];
        _profileImageBase64 = result['base64'];
      });
      _showSnackBar('Profile picture selected');
    } else {
      _showSnackBar(result['message'], isError: true);
    }
  }

  // Save profile changes
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _userProfileService.updateUserProfile(
        name: _nameController.text.trim(),
        profileImageFile: _imageFile,
      );

      if (success) {
        _showSnackBar(AppLocalizations.of(context).translate('profile_updated'));
        
        // Return to previous screen with updated data
        if (mounted) {
          // If we have a new image, we need to return the URL
          if (_imageFile != null) {
            // But we don't have the URL yet since it's just uploaded
            // We'll pass the base64 for immediate display
            Navigator.pop(context, {
              'username': _nameController.text.trim(),
              'profileImageBase64': _profileImageBase64,
              'profileImageUrl': _profileImageUrl,
            });
          } else {
            Navigator.pop(context, {
              'username': _nameController.text.trim(),
              'profileImageBase64': _profileImageBase64,
              'profileImageUrl': _profileImageUrl,
            });
          }
        }
      } else {
        _showSnackBar(AppLocalizations.of(context).translate('error_update'), isError: true);
      }
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context).translate('error_update'), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to show snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    UserProfileService.showResultSnackBar(context, message, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Column(
                  children: [
                    // Header
                    ModalHeader(
                      title: l10n.translate('edit_profile'),
                      onClose: () => Navigator.pop(context),
                    ),
                    SizedBox(height: 50.h),
                    
                    // Form content
                    Expanded(
                      child: _buildFormContent(),
                    ),
                  ],
                ),
              ),
              
              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the form content
  Widget _buildFormContent() {
    final l10n = AppLocalizations.of(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image Picker
                  ProfileImagePicker(
                    profileImageUrl: _profileImageUrl,
                    profileImageBase64: _profileImageBase64,
                    imageFile: _imageFile,
                    onPickImage: _handleImagePick,
                  ),
                  SizedBox(height: 50.h),

                  // Name Input Field
                  ProfileFormField(
                    label: l10n.translate('name'),
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    prefixIcon: Icons.person_outline,
                    hintText: l10n.translate('enter_name'),
                  ),

                  SizedBox(height: 30.h),

                  // Email Input Field (Disabled)
                  ProfileFormField(
                    label: l10n.translate('email'),
                    controller: _emailController,
                    enabled: false,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    hintText: l10n.translate('enter_email'),
                  ),

                  Spacer(),
                  SizedBox(height: 60.h),

                  // Save Button
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  // Build the save button
  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context);
    
    return PrimaryButton(
      text: l10n.translate('save_changes'),
      onPressed: _saveProfile,
      isLoading: _isLoading,
      margin: EdgeInsets.only(bottom: 20.h),
    );
  }
}