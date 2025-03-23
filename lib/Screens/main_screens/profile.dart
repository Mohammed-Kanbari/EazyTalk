import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/services/auth/auth_service.dart';
import 'package:eazytalk/services/user/user_service.dart';
import 'package:eazytalk/widgets/common/screen_header.dart';
import 'package:eazytalk/widgets/profile/profile_header.dart';
import 'package:eazytalk/widgets/profile/menu_item.dart';

// Import screen pages
import 'package:eazytalk/Screens/secondary_screens/profile_pages/change_pass.dart';
import 'package:eazytalk/Screens/secondary_screens/profile_pages/deaf_excursions.dart';
import 'package:eazytalk/Screens/secondary_screens/profile_pages/edit_profile.dart';
import 'package:eazytalk/Screens/secondary_screens/profile_pages/help_us.dart';
import 'package:eazytalk/Screens/secondary_screens/profile_pages/more_on_deaf.dart';
import 'package:eazytalk/Screens/secondary_screens/profile_pages/terms_and_services.dart';
import 'package:eazytalk/Screens/starting_screens/login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _isLoadingUserData = true;
  String _userName = 'User';
  String _userEmail = '';
  String? _profileImageBase64;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from service
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoadingUserData = true;
    });

    try {
      final userData = await _userService.fetchUserProfile();

      setState(() {
        _userName = userData['userName'];
        _userEmail = userData['userEmail'];
        _profileImageUrl = userData['profileImageUrl'];
        _profileImageBase64 = userData['profileImageBase64'];
      });
    } catch (e) {
      _showSnackBar('Failed to load profile data: $e', isError: true);
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
        MaterialPageRoute(
            builder: (context) => EditProfile(
                  currentName: _userName,
                  currentEmail: _userEmail,
                  currentProfileImageUrl: _profileImageUrl,
                  currentProfileImageBase64: _profileImageBase64,
                )));

    // If profile was updated, refresh the data
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (result['username'] != null) {
          _userName = result['username'];
        }
        if (result['profileImageUrl'] != null) {
          _profileImageUrl = result['profileImageUrl'];
        }
        if (result['profileImageBase64'] != null) {
          _profileImageBase64 = result['profileImageBase64'];
        }
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with title and brightness toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ScreenHeader(title: 'Profile'),
                GestureDetector(
                  onTap: () {
                    // Brightness toggle functionality
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 28.w, top: 27.h),
                    child: Image.asset(
                      'assets/icons/brightness 1.png',
                      width: 28.w,
                      height: 28.h,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),

            // User profile section with data
            _isLoadingUserData
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.h),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(right: 28.w, left: 28.w),
                    child: ProfileHeader(
                      userName: _userName,
                      userEmail: _userEmail,
                      profileImageUrl: _profileImageUrl,
                      profileImageBase64: _profileImageBase64,
                      onEditPressed: _navigateToEditProfile,
                    ),
                  ),

            SizedBox(height: 50.h),

            // Divider with shadow
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Divider(
                color: AppColors.dividerColor,
                thickness: 1,
                height: 2,
              ),
            ),

            // Menu list with loading overlay
            Expanded(
              child: Stack(
                children: [
                  _buildMenuList(),
                  if (_isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
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

  // Build the menu list
  Widget _buildMenuList() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      children: [
        ProfileMenuItem(
          icon: Icons.lock,
          text: 'Change Password',
          iconColor: AppColors.primary,
          onTap: () => _navigateTo(const ChangePass()),
        ),
        ProfileMenuItem(
          icon: Icons.info,
          text: 'More On Deaf People',
          iconColor: AppColors.primary,
          onTap: () => _navigateTo(const MoreOnDeaf()),
        ),
        ProfileMenuItem(
          icon: Icons.location_on,
          text: 'Deaf-Friendly Excursions',
          iconColor: AppColors.primary,
          onTap: () => _navigateTo(const DeafFriendlyExcursions()),
        ),
        ProfileMenuItem(
          icon: Icons.help,
          text: 'Help Us',
          iconColor: AppColors.primary,
          onTap: () => _navigateTo(const HelpUsPage()),
        ),
        ProfileMenuItem(
          icon: Icons.description,
          text: 'Terms & Services',
          iconColor: AppColors.primary,
          onTap: () => _navigateTo(const TermsAndServicesPage()),
        ),
        ProfileMenuItem(
          icon: Icons.language,
          text: 'Language',
          iconColor: AppColors.primary,
          onTap: _handleLanguage,
        ),
        ProfileMenuItem(
          icon: Icons.logout,
          text: 'Logout',
          iconColor: Colors.red,
          isLogout: true,
          onTap: _handleLogout,
        ),
      ],
    );
  }

  // Helper method to navigate to a screen
  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  // Handle language selection
  void _handleLanguage() {
    print('Navigating to Language settings screen');
    // To be implemented
  }

  // Handle logout with confirmation
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final bool confirmLogout = await _authService.showLogoutConfirmationDialog(
        context, AppColors.primary);

    // If user confirmed logout
    if (confirmLogout) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.signOut();

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
          _showSnackBar('Failed to logout: $e', isError: true);
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
