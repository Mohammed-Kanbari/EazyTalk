import 'package:eazytalk/Screens/main_screens/chatting.dart';
import 'package:eazytalk/Screens/main_screens/learning_signs.dart';
import 'package:eazytalk/Screens/main_screens/smart_tools.dart';
import 'package:eazytalk/Screens/main_screens/profile.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> with TickerProviderStateMixin {
  int _selectedIndex = 0; // Default to "Connect" (Chatting page)
  
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

  // Define navigation items as constants for better organization
  static const List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      label: "Connect",
      selectedIconPath: 'assets/icons/chat_selected.png',
      unselectedIconPath: 'assets/icons/chat_unselected.png',
    ),
    _NavigationItem(
      label: "Learn Signs",
      selectedIconPath: 'assets/icons/sign_selected.png',
      unselectedIconPath: 'assets/icons/sign_unselected.png',
    ),
    _NavigationItem(
      label: "Smart Tools",
      selectedIconPath: 'assets/icons/tools_selected.png',
      unselectedIconPath: 'assets/icons/tools_unselected.png',
    ),
    _NavigationItem(
      label: "Profile",
      selectedIconPath: 'assets/icons/profile_selected.png',
      unselectedIconPath: 'assets/icons/profile_unselected.png',
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers for each tab
    _animationControllers = List.generate(
      _navigationItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    
    // Initialize animations
    _animations = _animationControllers.map((controller) => 
      Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.elasticOut,
        ),
      )
    ).toList();
    
    // Start the animation for the initial selected tab
    _animationControllers[_selectedIndex].forward();
  }
  
  @override
  void dispose() {
    // Dispose all animation controllers
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Theme-appropriate colors
    final backgroundColor = AppColors.getBackgroundColor(context);
    final navBarColor = isDarkMode ? AppColors.darkSurface : Colors.white;
    final unselectedColor = isDarkMode ? Colors.grey[600] : Colors.black.withOpacity(0.62);
    final shadowColor = isDarkMode 
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        // Using IndexedStack to preserve the state of pages
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
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
          items: _navigationItems
              .asMap()
              .entries
              .map((entry) => _buildNavItem(entry.key, entry.value, isDarkMode))
              .toList(),
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

  BottomNavigationBarItem _buildNavItem(int index, _NavigationItem item, bool isDarkMode) {
    return BottomNavigationBarItem(
      icon: AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _selectedIndex == index ? _animations[index].value : 1.0,
            child: Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: Image.asset(
                _selectedIndex == index ? item.selectedIconPath : item.unselectedIconPath,
                width: 32.w,
                height: 32.h,
                // Apply white tint for unselected icons in dark mode
                color: (_selectedIndex != index && isDarkMode) ? Colors.white70 : null,
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
  final String label;
  final String selectedIconPath;
  final String unselectedIconPath;

  const _NavigationItem({
    required this.label,
    required this.selectedIconPath,
    required this.unselectedIconPath,
  });
}