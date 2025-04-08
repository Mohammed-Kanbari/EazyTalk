import 'package:eazytalk/Screens/main_screens/chatting.dart';
import 'package:eazytalk/Screens/main_screens/learning_signs.dart';
import 'package:eazytalk/Screens/main_screens/smart_tools.dart';
import 'package:eazytalk/Screens/main_screens/profile.dart';
import 'package:eazytalk/Screens/secondary_screens/chatbot.dart';
import 'package:eazytalk/Screens/secondary_screens/speech-to-text.dart';
import 'package:eazytalk/Widgets/voice_navigation/voice_command_button.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/l10n/app_localizations.dart';
import 'package:eazytalk/services/voice_navigation/voice_navigation_service.dart';
import 'package:eazytalk/widgets/voice_navigation/voice_command_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/services/video_call/call_listener_service.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> with TickerProviderStateMixin {
  int _selectedIndex = 0; // Default to "Connect" (Chatting page)

  // Navigation key for the voice navigation service
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Voice navigation service
  late VoiceNavigationService _voiceNavigationService;

  // Animation controllers for each tab
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  // Using const constructors for better performance
  static const List<Widget> _pages = [
    Chatting(),
    LearnSignsPage(),
    SmartToolsScreen(),
    Profile(),
  ];

  // Define navigation items without labels (will be set in build)
  static const List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      labelKey: 'connect',
      selectedIconPath: 'assets/icons/chat_selected.png',
      unselectedIconPath: 'assets/icons/chat_unselected.png',
    ),
    _NavigationItem(
      labelKey: 'learn_signs',
      selectedIconPath: 'assets/icons/sign_selected.png',
      unselectedIconPath: 'assets/icons/sign_unselected.png',
    ),
    _NavigationItem(
      labelKey: 'smart_tools',
      selectedIconPath: 'assets/icons/tools_selected.png',
      unselectedIconPath: 'assets/icons/tools_unselected.png',
    ),
    _NavigationItem(
      labelKey: 'profile',
      selectedIconPath: 'assets/icons/profile_selected.png',
      unselectedIconPath: 'assets/icons/profile_unselected.png',
    ),
  ];

  late CallListenerService _callListenerService;

  @override
  void initState() {
    super.initState();

    // Initialize the voice navigation service
    _voiceNavigationService = VoiceNavigationService(
      navigatorKey: _navigatorKey,
      onChangeTab: (index) {
        if (index >= 0 && index < _navigationItems.length) {
          _onItemTapped(index);
        }
      },
    );

    // Initialize call listener service
    _callListenerService = CallListenerService();

    // Start listening for incoming calls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _callListenerService.startListening(context);
    });

    // Initialize animation controllers for each tab
    _animationControllers = List.generate(
      _navigationItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    // Initialize animations
    _animations = _animationControllers
        .map((controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
              CurvedAnimation(
                parent: controller,
                curve: Curves.elasticOut,
              ),
            ))
        .toList();

    // Start the animation for the initial selected tab
    _animationControllers[_selectedIndex].forward();
  }

  void _showVoiceCommandHelp() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const VoiceCommandGuide()));
  }

  @override
  void dispose() {
    // Stop listening for incoming calls
    _callListenerService.stopListening();

    // Dispose all animation controllers
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<BottomNavigationBarItem> _buildNavigationItems(
      BuildContext context, bool isDarkMode) {
    final localizations = AppLocalizations.of(context);

    return _navigationItems
        .asMap()
        .entries
        .map((entry) => _buildNavItem(
              entry.key,
              _NavigationItem(
                labelKey: entry.value.labelKey,
                label: localizations.translate(entry.value.labelKey),
                selectedIconPath: entry.value.selectedIconPath,
                unselectedIconPath: entry.value.unselectedIconPath,
              ),
              isDarkMode,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Theme-appropriate colors
    final backgroundColor = AppColors.getBackgroundColor(context);
    final navBarColor = isDarkMode ? AppColors.darkSurface : Colors.white;
    final unselectedColor =
        isDarkMode ? Colors.grey[600] : Colors.black.withOpacity(0.62);
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);

    return Scaffold(
      key: _navigatorKey,
      backgroundColor: backgroundColor,
      body: SafeArea(
        // Using IndexedStack to preserve the state of pages
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      floatingActionButton: VoiceCommandButton(
          onLongPress: _showVoiceCommandHelp,
          navigationService: _voiceNavigationService),
      floatingActionButtonLocation: isRTL
          ? (_selectedIndex == 0
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat)
          : (_selectedIndex == 0
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBarColor,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, -5),
              blurRadius: 30,
            ),
          ],
        ),
        child: Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: navBarColor,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: unselectedColor,
            selectedLabelStyle: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w400,
            ),
            showUnselectedLabels: true,
            currentIndex: _selectedIndex,
            elevation: 0, // Remove default elevation to use custom shadow
            onTap: _onItemTapped,
            items: _buildNavigationItems(context, isDarkMode),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      // Reset previous animation
      _animationControllers[_selectedIndex].reset();

      // Update selected index
      _selectedIndex = index;

      // Start new animation
      _animationControllers[_selectedIndex].forward();
    });
  }

  BottomNavigationBarItem _buildNavItem(
      int index, _NavigationItem item, bool isDarkMode) {
    return BottomNavigationBarItem(
      icon: AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _selectedIndex == index ? _animations[index].value : 1.0,
            child: Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: Image.asset(
                _selectedIndex == index
                    ? item.selectedIconPath
                    : item.unselectedIconPath,
                width: 32.w,
                height: 32.h,
                // Apply white tint for unselected icons in dark mode
                color: (_selectedIndex != index && isDarkMode)
                    ? Colors.white70
                    : null,
              ),
            ),
          );
        },
      ),
      label: item.label,
    );
  }
}

// Helper class to store navigation item data
class _NavigationItem {
  final String labelKey;
  final String selectedIconPath;
  final String unselectedIconPath;
  final String? label; // Optional label for translated text

  const _NavigationItem({
    required this.labelKey,
    required this.selectedIconPath,
    required this.unselectedIconPath,
    this.label,
  });
}
