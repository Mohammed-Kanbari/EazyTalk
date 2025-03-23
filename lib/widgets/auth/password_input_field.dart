import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';

class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool showValidationIcon;
  final bool isValid;
  final Function(bool) onVisibilityChanged;
  final bool isDarkMode;

  const PasswordInputField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.showValidationIcon = false,
    this.isValid = false,
    required this.onVisibilityChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextPrimaryColor(context);
    final hintColor = widget.isDarkMode 
        ? Colors.grey[600]
        : AppColors.iconGrey;
    
    // Define colors based on validation status
    final Color enabledBorderColor = widget.controller.text.isEmpty
        ? (widget.isDarkMode ? const Color(0xFF3A3A3A) : AppColors.iconGrey)
        : (widget.showValidationIcon
            ? (widget.isValid 
                ? Colors.green.withOpacity(widget.isDarkMode ? 0.7 : 0.5) 
                : Colors.red.withOpacity(widget.isDarkMode ? 0.7 : 0.5))
            : (widget.isDarkMode ? const Color(0xFF3A3A3A) : AppColors.iconGrey));
    
    // Background color for the field
    final Color? fillColor = widget.isDarkMode 
        ? const Color(0xFF1E1E1E)
        : null; // null will use default from theme
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with validation icon if needed
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const Spacer(),
            if (widget.showValidationIcon && widget.controller.text.isNotEmpty)
              Icon(
                widget.isValid ? Icons.check_circle : Icons.error,
                color: widget.isValid ? Colors.green : Colors.red,
                size: 16.sp,
              ),
          ],
        ),
        
        SizedBox(height: 9.h),
        
        // Password Input
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          autocorrect: false,
          style: TextStyle(
            fontSize: 16.sp, 
            fontFamily: 'DM Sans',
            color: textColor,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w400,
              color: hintColor,
            ),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: enabledBorderColor,
                width: 1
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: hintColor,
                size: 20.sp,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                  widget.onVisibilityChanged(_obscureText);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}