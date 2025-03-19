import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File
import 'dart:convert'; // For base64 encoding
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// User Model for better data management
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageBase64;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageBase64,
    this.createdAt,
    this.updatedAt,
  });

  // Create a UserModel from Firestore data
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['username'] ?? 'User',
      email: data['email'] ?? '',
      profileImageBase64: data['profileImageBase64'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'username': name,
      'email': email,
      'profileImageBase64': profileImageBase64,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

// Main EditProfile Widget
class EditProfile extends StatefulWidget {
  final String? currentName;
  final String? currentEmail;
  final String? currentProfileImageBase64;

  const EditProfile({
    Key? key,
    this.currentName,
    this.currentEmail,
    this.currentProfileImageBase64,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _profileImageBase64;
  bool _isLoading = false;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName ?? 'User');
    _emailController = TextEditingController(text: widget.currentEmail ?? '');
    _profileImageBase64 = widget.currentProfileImageBase64;
    
    // If no data was passed, fetch current user data from Firestore
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

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userData = await _firestore.collection('users').doc(user.uid).get();
        
        if (userData.exists) {
          setState(() {
            _nameController.text = userData.data()?['username'] ?? 'User';
            _emailController.text = userData.data()?['email'] ?? user.email ?? '';
            _profileImageBase64 = userData.data()?['profileImageBase64'];
          });
        }
      }
    } catch (e) {
      _showSnackBar('Error fetching user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to pick an image from gallery with permission handling
  Future<void> _pickAndSaveImageLocally() async {
    // Request storage permission
    var status = await Permission.storage.request();

    if (status.isGranted) {
      // Permission granted, proceed with picking the image
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        // Using full quality with no dimension restrictions
      );
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        // Convert image to base64
        try {
          final bytes = await _imageFile!.readAsBytes();
          final base64Image = base64Encode(bytes);
          
          setState(() {
            _profileImageBase64 = base64Image;
          });
          
          _showSnackBar('Profile picture selected');
        } catch (e) {
          _showSnackBar('Error processing image: $e');
        }
      }
    } else if (status.isDenied) {
      // Permission denied
      _showSnackBar('Storage permission is required to pick an image');
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings
      openAppSettings();
    }
  }

  // Function to save profile changes to Firestore
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showSnackBar('No user logged in');
        return;
      }

      // Update Firestore with new data
      await _firestore.collection('users').doc(user.uid).update({
        'username': _nameController.text.trim(),
        'profileImageBase64': _profileImageBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('Profile updated successfully');
      
      // Return to previous screen with updated data
      if (mounted) {
        Navigator.pop(context, {
          'username': _nameController.text.trim(),
          'profileImageBase64': _profileImageBase64,
        });
      }
    } catch (e) {
      _showSnackBar('Error updating profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to show snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 27.h, left: 28.w, right: 28.w),
                child: Column(
                  children: [
                    // App Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 28.w, height: 28.h), // Placeholder for alignment
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, size: 28.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 50.h),
                    Expanded(
                      child: LayoutBuilder(builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile Image
                                  Center(
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: _pickAndSaveImageLocally,
                                          child: Container(
                                            width: 140.w,
                                            height: 140.h,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF5F5F5),
                                              border: Border.all(
                                                color: const Color(0xFFC7C7C7),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(12.r),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: _imageFile != null
                                                ? Image.file(
                                                    _imageFile!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : _profileImageBase64 != null
                                                    ? Image.memory(
                                                        base64Decode(_profileImageBase64!),
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) => Icon(
                                                          Icons.person,
                                                          size: 60.sp,
                                                          color: Colors.grey,
                                                        ),
                                                      )
                                                    : Icon(
                                                        Icons.person,
                                                        size: 60.sp,
                                                        color: Colors.grey,
                                                      ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: GestureDetector(
                                            onTap: _pickAndSaveImageLocally,
                                            child: Container(
                                              width: 40.w,
                                              height: 40.h,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00D0FF),
                                                borderRadius: BorderRadius.circular(8.r),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 20.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 50.h),

                                  // Name Input Field
                                  Text(
                                    'Name :',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 9.h),
                                  TextFormField(
                                    controller: _nameController,
                                    keyboardType: TextInputType.name,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontFamily: 'DM Sans',
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 15.h,
                                      ),
                                      hintText: 'Enter your name',
                                      hintStyle: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'DM Sans',
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFFC7C7C7),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: const Color(0xFFC7C7C7),
                                        size: 20.sp,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0xFF00D0FF),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0xFFC7C7C7),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 30.h),

                                  // Email Input Field (Disabled)
                                  Text(
                                    'Email :',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 9.h),
                                  TextFormField(
                                    controller: _emailController,
                                    enabled: false,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontFamily: 'DM Sans',
                                      color: Colors.black54,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFF5F5F5),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 15.h,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: const Color(0xFFC7C7C7),
                                        size: 20.sp,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE0E0E0),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                    ),
                                  ),

                                  Spacer(),
                                  SizedBox(height: 60.h),

                                  // Save Button
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 20.h),
                                    child: SizedBox(
                                      height: 44.h,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _saveProfile,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00D0FF),
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor: const Color(0xFF00D0FF).withOpacity(0.6),
                                          elevation: 0,
                                          padding: EdgeInsets.symmetric(vertical: 12.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 3,
                                              )
                                            : Text(
                                                'Save Changes',
                                                style: TextStyle(
                                                  fontFamily: 'Sora',
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              
              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00D0FF)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}