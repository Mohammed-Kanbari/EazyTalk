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

  const PasswordInputField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.showValidationIcon = false,
    this.isValid = false,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
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
                color: Colors.black87,
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
          style: TextStyle(fontSize: 16.sp, fontFamily: 'DM Sans'),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w400,
              color: AppColors.iconGrey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.controller.text.isEmpty 
                    ? AppColors.iconGrey
                    : (widget.showValidationIcon ? 
                        (widget.isValid ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5))
                        : AppColors.iconGrey),
                width: 1
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey,
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