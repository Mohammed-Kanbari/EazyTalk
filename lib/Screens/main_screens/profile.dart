import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/core/theme/text_styles.dart';
import 'package:eazytalk/services/auth/auth_service.dart';
import 'package:eazytalk/services/theme/theme_service.dart';
import 'package:eazytalk/services/user/user_service.dart';
import 'package:eazytalk/services/language/language_service.dart';
import 'package:eazytalk/l10n/app_localizations.dart';
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
  bool _isDarkMode = ThemeService.isDarkMode;

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

  // Toggle theme
  Future<void> _toggleTheme() async {
    final isDarkMode = await ThemeService.toggleTheme();
    setState(() {
      _isDarkMode = isDarkMode;
    });
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

  // Handle language selection
  void _handleLanguage() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final backgroundColor = AppColors.getSurfaceColor(context);
    
    // Get current language code
    final currentLanguage = LanguageService.getCurrentLanguage();
    
    // Show dialog with language options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          AppLocalizations.of(context).translate('language'),
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // English option
            _buildLanguageOption(
              'en',
              'English',
              currentLanguage == 'en',
              isDarkMode,
            ),
            
            SizedBox(height: 8.h),
            
            // Arabic option
            _buildLanguageOption(
              'ar',
              'العربية',
              currentLanguage == 'ar',
              isDarkMode,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).translate('cancel'),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a language option in the dialog
  Widget _buildLanguageOption(
    String languageCode,
    String languageName,
    bool isSelected,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: () async {
        // Close the dialog
        Navigator.pop(context);
        
        // Change language
        await LanguageService.setLanguage(languageCode);
        
        // Update UI (will trigger app rebuild via locale notifier)
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDarkMode ? AppColors.primary.withOpacity(0.2) : AppColors.primary.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14.sp,
                  color: isSelected ? AppColors.primary : AppColors.getTextPrimaryColor(context),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header with title and brightness toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ScreenHeader(
                  title: AppLocalizations.of(context).translate('profile'),
                  textColor: AppColors.getTextPrimaryColor(context),
                ),
                GestureDetector(
                  onTap: _toggleTheme,
                  child: Padding(
                    padding: EdgeInsets.only(right: 28.w, top: 27.h, left: 28.w),
                    child: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: AppColors.getTextPrimaryColor(context),
                      size: 28.sp,
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
                    color: isDarkMode 
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black.withOpacity(0.25),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Divider(
                color: AppColors.getDividerColor(context),
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
    // Check if we're in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Theme-appropriate colors
    final unselectedColor =
        isDarkMode ? Colors.grey[600] : Colors.black.withOpacity(0.62);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      children: [
        ProfileMenuItem(
          icon: Icons.lock,
          text: AppLocalizations.of(context).translate('change_password'),
          iconColor: AppColors.primary,
          onTap: () => _navigateTo(const ChangePass()),
        ),
        ProfileMenuItem(
          icon: Icons.info,
          text: AppLocalizations.of(context).translate('more_on_deaf'),
          iconColor: AppColors.primary,
          onTap: () => _navigateTo(const MoreOnDeaf()),
        ),
        ProfileMenuItem(
          icon: Icons.location_on,
          text: AppLocalizations.of(context).translate('deaf_excursions_profile'),
          iconColor: AppColors.primary,
          onTap: () => _navigateTo(const DeafFriendlyExcursions()),
        ),
        ProfileMenuItem(
          icon: Icons.help,
          text: AppLocalizations.of(context).translate('help_us'),
          iconColor: AppColors.primary,
          onTap: () => _navigateTo(const HelpUsPage()),
        ),
        ProfileMenuItem(
          icon: Icons.description,
          text: AppLocalizations.of(context).translate('terms_services'),
          iconColor: AppColors.primary,
          onTap: () => _navigateTo(const TermsAndServicesPage()),
        ),
        ProfileMenuItem(
          icon: Icons.language,
          text: AppLocalizations.of(context).translate('language'),
          iconColor: AppColors.primary,
          onTap: _handleLanguage,
        ),
        ProfileMenuItem(
          icon: Icons.logout,
          text: AppLocalizations.of(context).translate('logout'),
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