import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';

class HelpUsPage extends StatefulWidget {
  const HelpUsPage({Key? key}) : super(key: key);

  @override
  State<HelpUsPage> createState() => _HelpUsPageState();
}

class _HelpUsPageState extends State<HelpUsPage> {
  // Media selection and preview
  final ImagePicker _picker = ImagePicker();
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

  // Get Supabase client instance
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _signNameController.dispose();
    _descriptionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        setState(() {
          _mediaFile = File(pickedFile.path);
          _isVideo = false;
          // Reset video if one was selected previously
          _videoController?.dispose();
          _videoController = null;
          _isVideoInitialized = false;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  // Pick video from gallery or camera
  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 10), // Limit video length
      );

      if (pickedFile != null) {
        final videoFile = File(pickedFile.path);

        // Initialize video controller
        final videoController = VideoPlayerController.file(videoFile);
        await videoController.initialize();

        setState(() {
          _mediaFile = videoFile;
          _isVideo = true;
          _videoController = videoController;
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking video: $e');
    }
  }

  // Show media picker options (camera/gallery for both image and video)
  void _showMediaPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add a Sign',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20.h),

              // Camera options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPickerOption(
                    icon: Icons.camera_alt,
                    title: 'Take Photo',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildPickerOption(
                    icon: Icons.videocam,
                    title: 'Record Video',
                    onTap: () {
                      Navigator.pop(context);
                      _pickVideo(ImageSource.camera);
                    },
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Gallery options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPickerOption(
                    icon: Icons.photo_library,
                    title: 'Gallery Photo',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  _buildPickerOption(
                    icon: Icons.video_library,
                    title: 'Gallery Video',
                    onTap: () {
                      Navigator.pop(context);
                      _pickVideo(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build media picker option buttons
  Widget _buildPickerOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: const Color(0xFF00D0FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              size: 30.sp,
              color: const Color(0xFF00D0FF),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Upload media to Supabase Storage and save metadata to Firestore
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
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }



      // Create a unique file name with UUID
      final uuid = Uuid();
      final fileExt = path.extension(_mediaFile!.path);
      final fileName = '${uuid.v4()}$fileExt';
      final fileType = _isVideo ? 'videos' : 'images';

      // Determine mime type
      final mimeType = lookupMimeType(_mediaFile!.path) ??
          (_isVideo ? 'video/mp4' : 'image/jpeg');

      // Start progress simulation
      _simulateProgress();

      // Upload to Supabase Storage
      final bytes = await _mediaFile!.readAsBytes();

      // Path in Supabase Storage
      final storagePath = 'user_signs/$fileType/$fileName';

      // Upload file to Supabase Storage
      final response = await _supabase.storage
          .from('eazytalk') // Your bucket name in Supabase
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: mimeType,
            ),
          );

      // Get public URL for the uploaded file
      final fileUrl =
          _supabase.storage.from('eazytalk').getPublicUrl(storagePath);

      // Update progress
      setState(() {
        _uploadProgress = 0.8;
      });

      // Save metadata to Firestore
      await FirebaseFirestore.instance.collection('user_signs').add({
        'userId': user.uid,
        'userEmail': user.email,
        'signName': _signNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'fileUrl': fileUrl,
        'filePath': storagePath,
        'fileType': _isVideo ? 'video' : 'image',
        'status': 'pending', // For moderation
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update progress to 100%
      setState(() {
        _uploadProgress = 1.0;
      });

      // Reset form
      setState(() {
        _mediaFile = null;
        _isVideo = false;
        _videoController?.dispose();
        _videoController = null;
        _isVideoInitialized = false;
        _signNameController.clear();
        _descriptionController.clear();
        _selectedCategory = null;
        _isUploading = false;
      });

      _showThankYouDialog();
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showSnackBar('Error uploading sign: $e');
    }
  }

  // Simulates progress updates for a smoother user experience
  void _simulateProgress() {
    const totalSteps = 20;
    for (int i = 1; i <= totalSteps; i++) {
      Future.delayed(Duration(milliseconds: 50 * i), () {
        if (mounted && _isUploading && _uploadProgress < 0.7) {
          setState(() {
            _uploadProgress = i / totalSteps * 0.7; // Go up to 70%
          });
        }
      });
    }
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
                color: const Color(0xFF00D0FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: const Color(0xFF00D0FF),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D0FF),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
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
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // App Bar
                  Padding(
                    padding: EdgeInsets.only(top: 27.h, left: 28.w, right: 28.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 28.w, height: 28.h),
                        Text(
                          'Help Us Improve',
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
                  ),
          
                  SizedBox(height: 30.h),
          
                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 28.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Introduction section
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F5),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: const Color(0xFFE8E8E8),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline,
                                        color: const Color(0xFF00D0FF),
                                        size: 24.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Contribute to EazyTalk',
                                        style: TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'Help us expand our sign language database by submitting signs you know. Your contributions make EazyTalk better for everyone!',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 14.sp,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
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
          
                            // Media preview or placeholder
                            GestureDetector(
                              onTap: _showMediaPickerOptions,
                              child: Container(
                                width: double.infinity,
                                height: 200.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F3F5),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: const Color(0xFFE8E8E8),
                                  ),
                                ),
                                child: _mediaFile == null
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            color: const Color(0xFF00D0FF),
                                            size: 40.sp,
                                          ),
                                          SizedBox(height: 12.h),
                                          Text(
                                            'Tap to add a photo or video',
                                            style: TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 14.sp,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            'Show the sign clearly in good lighting',
                                            style: TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 12.sp,
                                              color: Colors.black38,
                                            ),
                                          ),
                                        ],
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(16.r),
                                        child: _isVideo
                                            ? _isVideoInitialized
                                                ? Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      AspectRatio(
                                                        aspectRatio:
                                                            _videoController!
                                                                .value
                                                                .aspectRatio,
                                                        child: VideoPlayer(
                                                            _videoController!),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          _videoController!
                                                                  .value.isPlaying
                                                              ? Icons.pause
                                                              : Icons.play_arrow,
                                                          color: Colors.white,
                                                          size: 40.sp,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _videoController!
                                                                    .value
                                                                    .isPlaying
                                                                ? _videoController!
                                                                    .pause()
                                                                : _videoController!
                                                                    .play();
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  )
                                                : Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color:
                                                          const Color(0xFF00D0FF),
                                                    ),
                                                  )
                                            : Image.file(
                                                _mediaFile!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                      ),
                              ),
                            ),
          
                            if (_mediaFile != null)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: _showMediaPickerOptions,
                                      icon: Icon(
                                        Icons.refresh,
                                        size: 16.sp,
                                        color: const Color(0xFF00D0FF),
                                      ),
                                      label: Text(
                                        'Change',
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 12.sp,
                                          color: const Color(0xFF00D0FF),
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
                                            _isVideoInitialized = false;
                                          }
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
                              ),
          
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
                            Text(
                              'Sign Name:',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextFormField(
                              controller: _signNameController,
                              decoration: InputDecoration(
                                hintText: 'Enter the meaning of this sign',
                                hintStyle: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14.sp,
                                  color: Colors.black38,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF1F3F5),
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
                            ),
          
                            SizedBox(height: 16.h),
          
                            // Category dropdown
                            Text(
                              'Category:',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F5),
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
                            ),
          
                            SizedBox(height: 16.h),
          
                            // Description field
                            Text(
                              'Description (Optional):',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    'Add any additional information about this sign',
                                hintStyle: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14.sp,
                                  color: Colors.black38,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF1F3F5),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
          
                            SizedBox(height: 32.h),
          
                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: _isUploading ? null : _uploadData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00D0FF),
                                  disabledBackgroundColor:
                                      const Color(0xFF00D0FF).withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Submit Sign',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
          
                            SizedBox(height: 20.h),
          
                            // Additional information
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F3F5),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.black54,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        'Your submission will be reviewed by our team before being added to the app.',
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 12.sp,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          
              // Loading overlay
              if (_isUploading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: _uploadProgress,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF00D0FF),
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
