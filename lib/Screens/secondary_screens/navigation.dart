import 'package:eazytalk/Screens/main_screens/chatting.dart';
import 'package:eazytalk/Screens/main_screens/learning_signs.dart';
import 'package:eazytalk/Screens/main_screens/offline_tools.dart';
import 'package:eazytalk/Screens/main_screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0; // Default to "Connect" (Chatting page)

  final List<Widget> _pages = [
    const Chatting(),
    const LearnSignsPage(),
    const OfflineTools(),
    const Profile(),
  ];

  // Define icon paths for selected and unselected states
  final List<Map<String, String>> _iconPaths = [
    {
      'selected': 'assets/icons/chat_selected.png',
      'unselected': 'assets/icons/chat_unselected.png',
    },
    {
      'selected': 'assets/icons/sign_selected.png',
      'unselected': 'assets/icons/sign_unselected.png',
    },
    {
      'selected': 'assets/icons/offline_selected.png',
      'unselected': 'assets/icons/offline_unselected.png',
    },
    {
      'selected': 'assets/icons/profile_selected.png',
      'unselected': 'assets/icons/profile_unselected.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        /* or use if you need to preserve the state of pages (e.g., form inputs, scroll positions).
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        */
        child: _pages[_selectedIndex], //if state preservation isn’t necessary or if you want a fresh instance of the page each time - when memory efficiency is a priority         
      ),
      bottomNavigationBar: Container(
        height: 85.h,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -5),
              blurRadius: 30,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          selectedItemColor: const Color(0xFF00D0FF),
          unselectedItemColor: Colors.black.withOpacity(0.62),
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
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            _buildNavItem(0, "Connect"),
            _buildNavItem(1, "Learn Signs"),
            _buildNavItem(2, "Offline Tools"),
            _buildNavItem(3, "Profile"),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(int index, String label) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        _selectedIndex == index
            ? _iconPaths[index]['selected']!
            : _iconPaths[index]['unselected']!,
        width: 32.w,
        height: 32.h,
      ),
      label: label,
    );
  }
}