import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePass extends StatefulWidget {
  const ChangePass({super.key});

  @override
  State<ChangePass> createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  // Password validation states
  bool _hasMinLength = false;
  bool _hasCapitalLetter = false;
  bool _hasNumber = false;
  bool _doPasswordsMatch = false;

  void _validatePasswords() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 6;
      _hasCapitalLetter = RegExp(r'[A-Z]').hasMatch(password);
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _doPasswordsMatch = password == _confirmPasswordController.text;
    });
  }

  // Check if password meets all criteria
  bool get _isPasswordValid => _hasMinLength && _hasCapitalLetter && _hasNumber;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Method to update password in Firebase
  Future<void> _updatePassword() async {
    // First validate all fields
    if (!_isPasswordValid || !_doPasswordsMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the password issues before continuing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user is currently signed in.',
        );
      }

      // Get the user's credentials with current password for reauthentication
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      // Reauthenticate the user first
      await user.reauthenticateWithCredential(credential);
      
      // Then update the password
      await user.updatePassword(_passwordController.text);
      
      // Success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8.w),
                Text('Password updated successfully'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found. Please sign in again.';
          break;
        case 'wrong-password':
          errorMessage = 'The current password is incorrect.';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please log in again before changing your password.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Please use a stronger password.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fixed header
                    Padding(
                      padding: EdgeInsets.only(top: 27.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(width: 28.w, height: 28.h),
                          Text(
                            'Reset Password',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.close, size: 28.sp),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                  
                    // Main content
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced title section with icon
                      Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 24.sp,
                            color: const Color(0xFF00D0FF),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Enter New Password',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 12.h),
                      
                      // Updated instruction text with enhanced password requirements
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8FC),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFCCEEF5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18.sp,
                              color: const Color(0xFF00D0FF),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Your new password must be different from previously used passwords and include at least 6 characters, one capital letter, and one number.',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Current Password Label
                      Text(
                        'Current Password :',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      
                      SizedBox(height: 9.h),
                      // Current Password Field
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        style: TextStyle(fontSize: 16.sp, fontFamily: 'DM Sans'),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: 'Enter your current password',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFC7C7C7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF00D0FF), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFC7C7C7), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword = !_obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Password Label with icon
                      Row(
                        children: [
                          Text(
                            'New Password :',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          if (_passwordController.text.isNotEmpty)
                            Icon(
                              _isPasswordValid ? Icons.check_circle : Icons.error,
                              color: _isPasswordValid ? Colors.green : Colors.red,
                              size: 16.sp,
                            ),
                        ],
                      ),
                      
                      SizedBox(height: 9.h),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(fontSize: 16.sp, fontFamily: 'DM Sans'),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: 'Enter your new password',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFC7C7C7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF00D0FF), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _passwordController.text.isEmpty 
                                  ? const Color(0xFFC7C7C7) 
                                  : _isPasswordValid ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                              width: 1
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      // Password requirements checklist
                      if (_passwordController.text.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 12.h, left: 4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRequirementRow(
                                _hasMinLength,
                                'At least 6 characters'
                              ),
                              SizedBox(height: 4.h),
                              _buildRequirementRow(
                                _hasCapitalLetter,
                                'Contains at least one capital letter'
                              ),
                              SizedBox(height: 4.h),
                              _buildRequirementRow(
                                _hasNumber,
                                'Contains at least one number'
                              ),
                            ],
                          ),
                        ),
                      
                      SizedBox(height: 24.h),
                      
                      // Confirm Password Label with icon
                      Row(
                        children: [
                          Text(
                            'Confirm Password :',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          if (_confirmPasswordController.text.isNotEmpty)
                            Icon(
                              _doPasswordsMatch ? Icons.check_circle : Icons.error,
                              color: _doPasswordsMatch ? Colors.green : Colors.red,
                              size: 16.sp,
                            ),
                        ],
                      ),
                      
                      SizedBox(height: 9.h),
                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: TextStyle(fontSize: 16.sp, fontFamily: 'DM Sans'),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: 'Confirm your new password',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFC7C7C7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF00D0FF), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _confirmPasswordController.text.isEmpty 
                                  ? const Color(0xFFC7C7C7) 
                                  : _doPasswordsMatch ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                              width: 1
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      // Password match hint
                      if (_confirmPasswordController.text.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h, left: 4.w),
                          child: _buildRequirementRow(
                            _doPasswordsMatch,
                            'Passwords match'
                          ),
                        ),
                      
                      // Add spacing before button
                      SizedBox(height: 80.h),
                      
                      
                      // Reset Button with loading state
                      SizedBox(
                        height: 50.h,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading || !_isPasswordValid || !_doPasswordsMatch || _currentPasswordController.text.isEmpty
                              ? null 
                              : _updatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D0FF),
                            disabledBackgroundColor: const Color(0xFF00D0FF).withOpacity(0.5),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      
                      // Add extra space at bottom to ensure scrolling can show all fields 
                      // even when keyboard is open
                      SizedBox(height: 20.h),
                    ],
                  ),
               ] ),
              ),
            );
          }),
        ),
      ),
    );
  }
  
  // Helper method to build requirement row with icons
  Widget _buildRequirementRow(bool isMet, String text) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          size: 16.sp,
          color: isMet ? Colors.green : Colors.red,
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: 'DM Sans',
            color: isMet ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
      ],
    );
  }
}