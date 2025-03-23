import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class WordTabs extends StatelessWidget {
  final List<String> tabTitles;
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  
  const WordTabs({
    Key? key,
    required this.tabTitles,
    required this.selectedTabIndex,
    required this.onTabSelected,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Check if we're in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Set theme-appropriate colors
    final dividerColor = isDarkMode ? Color(0xFF323232) : Colors.grey[200]!;
    final selectedTextColor = AppColors.primary;
    final unselectedTextColor = isDarkMode ? Colors.grey[600] : Colors.grey;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: List.generate(
          tabTitles.length,
          (index) => _buildTabItem(
            index, 
            selectedTextColor, 
            unselectedTextColor!
          ),
        ),
      ),
    );
  }
  
  Widget _buildTabItem(int index, Color selectedColor, Color unselectedColor) {
    final isSelected = selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            tabTitles[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? selectedColor : unselectedColor,
            ),
          ),
        ),
      ),
    );
  }
}