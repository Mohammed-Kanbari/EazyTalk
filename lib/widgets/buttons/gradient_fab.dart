import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class GradientFloatingActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final List<Color> gradientColors;
  final List<Color> darkgradientColors;


  const GradientFloatingActionButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.gradientColors = const [Color(0xFF00D0FF), Color(0xFF0088FF)],
    this.darkgradientColors = const [Color(0xFF007ACC), Color(0xFF003F7F)],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode ? darkgradientColors : gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(isDarkMode ? 0.2 : 0.4),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
        onPressed: onPressed,
      ),
    );
  }
}