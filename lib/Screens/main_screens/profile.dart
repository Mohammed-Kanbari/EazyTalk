import 'package:eazytalk/Screens/secondary_screens/profile_pages/change_pass.dart';
import 'package:eazytalk/Screens/secondary_screens/profile_pages/deaf_excursions.dart';
import 'package:eazytalk/Screens/secondary_screens/profile_pages/edit_profile.dart';
import 'package:eazytalk/Screens/secondary_screens/profile_pages/help_us.dart';
import 'package:eazytalk/Screens/secondary_screens/profile_pages/more_on_deaf.dart';
import 'package:eazytalk/Screens/secondary_screens/profile_pages/terms_and_services.dart';
import 'package:eazytalk/Screens/starting_screens/login.dart'; // Import login page
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for local storage
import 'dart:convert'; // For base64 decoding

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  bool _isLoadingUserData = true;
  String _userName = 'User';
  String _userEmail = '';
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoadingUserData = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Set email from Firebase Auth
        _userEmail = user.email ?? '';
        
        // Get additional data from Firestore
        final userData = await _firestore.collection('users').doc(user.uid).get();
        
        if (userData.exists) {
          setState(() {
            _userName = userData.data()?['username'] ?? 'User';
            _profileImageBase64 = userData.data()?['profileImageBase64'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  // Navigate to edit profile and refresh data when returning
  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const EditProfile())
    );
    
    // If profile was updated, refresh the data
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (result['username'] != null) {
          _userName = result['username'];
        }
        if (result['profileImageBase64'] != null) {
          _profileImageBase64 = result['profileImageBase64'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 27.0.h, right: 28.w, left: 28.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Brightness toggle functionality
                    },
                    child: Image.asset(
                      'assets/icons/brightness 1.png',
                      width: 28.w,
                      height: 28.h,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            
            // User profile section with data
            _isLoadingUserData 
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.h),
                    child: CircularProgressIndicator(
                      color: const Color(0xFF00D0FF),
                    ),
                  ),
                )
              : Padding(
                padding: EdgeInsets.only(right: 28.w, left: 28.w),
                child: Row(
                  children: [
                    // Profile Image
                    Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: const Color(0xFFF5F5F5),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _profileImageBase64 != null 
                        ? Image.memory(
                            base64Decode(_profileImageBase64!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              Image.asset(
                                'assets/images/Rectangle 24.png',
                                width: 120.w,
                                height: 120.h,
                                fit: BoxFit.cover,
                              ),
                          )
                        : Image.asset(
                            'assets/images/Rectangle 24.png',
                            width: 120.w,
                            height: 120.h,
                            fit: BoxFit.cover,
                          ),
                    ),
                    SizedBox(width: 22.w),
                    
                    // User info section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            _userEmail,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF706E71),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          
                          // Edit Profile Button
                          Container(
                            height: 32.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: const Color(0xFF00D0FF),
                            ),
                            child: IntrinsicWidth(
                              child: MaterialButton(
                                onPressed: _navigateToEditProfile,
                                splashColor: const Color(0x52FFFFFF),
                                minWidth: 0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/icons/editing 1.png',
                                      width: 20.w,
                                      height: 20.h,
                                    ),
                                    SizedBox(width: 8.h),
                                    Text(
                                      'Edit Profile',
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontFamily: 'Sora',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 50.h),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.25),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Divider(
                color: const Color.fromARGB(255, 232, 232, 232),
                thickness: 1,
                height: 2,
              ),
            ),
            // Add the menu list below the divider
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    children: [
                      _buildMenuItem(
                        Icons.lock,
                        'Change Password',
                        const Color(0xFF00D0FF),
                        () => _handleChangePassword(),
                      ),
                      _buildMenuItem(
                        Icons.info,
                        'More On Deaf People',
                        const Color(0xFF00D0FF),
                        () => _handleMoreOnDeafPeople(),
                      ),
                      _buildMenuItem(
                        Icons.location_on,
                        'Deaf-Friendly Excursions',
                        const Color(0xFF00D0FF),
                        () => _handleDeafFriendlyExcursions(),
                      ),
                      _buildMenuItem(
                        Icons.help,
                        'Help Us',
                        const Color(0xFF00D0FF),
                        () => _handleHelpUs(),
                      ),
                      _buildMenuItem(
                        Icons.description,
                        'Terms & Services',
                        const Color(0xFF00D0FF),
                        () => _handleTermsAndServices(),
                      ),
                      _buildMenuItem(
                        Icons.language,
                        'Language',
                        const Color(0xFF00D0FF),
                        () => _handleLanguage(),
                      ),
                      _buildMenuItem(
                        Icons.logout,
                        'Logout',
                        Colors.red,
                        () => _handleLogout(),
                      ),
                    ],
                  ),
                  // Overlay loading indicator when logging out
                  if (_isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFF00D0FF),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build each menu item with a custom onTap action
  Widget _buildMenuItem(
      IconData icon, String text, Color iconColor, VoidCallback onTapAction) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          title: Text(
            text,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: text == 'Logout' ? Colors.red : const Color(0xFF333333),
            ),
          ),
          onTap: onTapAction, // Use the passed callback
        ),
      ),
    );
  }

  // Placeholder methods for each action
  void _handleChangePassword() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePass()));
  }

  void _handleMoreOnDeafPeople() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MoreOnDeaf()));
  }

  void _handleDeafFriendlyExcursions() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DeafFriendlyExcursions()));
  }

  void _handleHelpUs() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpUsPage()));
  }

  void _handleTermsAndServices() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsAndServicesPage()));
  }

  void _handleLanguage() {
    print('Navigating to Language settings screen');
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageScreen()));
  }

  // Implement logout functionality with confirmation dialog
  void _handleLogout() async {
    // Show confirmation dialog
    final bool confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Logout',
          style: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontFamily: 'DM Sans',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: const Color(0xFF00D0FF),
                fontFamily: 'DM Sans',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D0FF),
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Sora',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;

    // If user confirmed logout
    if (confirmLogout) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Clear any locally stored data (shared preferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Sign out from Firebase
        await _auth.signOut();
        
        // Navigate to login screen and remove all previous routes
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false, // Remove all previous routes
          );
        }
      } catch (e) {
        // Show error message if logout fails
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to logout: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}