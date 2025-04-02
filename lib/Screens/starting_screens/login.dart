import 'package:eazytalk/Screens/secondary_screens/navigation.dart';
import 'package:eazytalk/Screens/starting_screens/signup.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscurePassword = true;
  bool _isLoading = false; // Added for loading state
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateAndLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Show loading spinner
      try {
        // Sign in with email and password
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Navigate to Navigation page on success
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Navigation()),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle Firebase-specific errors
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = AppLocalizations.of(context).translate('no_account_email');
            break;
          case 'wrong-password':
            errorMessage = AppLocalizations.of(context).translate('wrong_credentials');
            break;
          case 'invalid-email':
            errorMessage = AppLocalizations.of(context).translate('valid_email');
            break;
          default:
            errorMessage = '${AppLocalizations.of(context).translate('login_failed')}: ${e.message}';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        // Catch any unexpected errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context).translate('login_failed')}: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false); // Hide loading spinner
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('email_required'))),
      );
      return;
    }
    
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('reset_email_sent'))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('failed_send_reset'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final backgroundColor = isDarkMode 
        ? AppColors.darkBackground
        : Colors.white;
    
    final textColor = isDarkMode 
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    
    final borderColor = isDarkMode 
        ? const Color(0xFF3A3A3A)
        : const Color(0xFFC7C7C7);

    final hintColor = isDarkMode 
        ? const Color(0xFF7A7A7A)
        : const Color(0xFFC7C7C7);

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.055),
                        child: Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/welcome.png',
                            width: screenWidth * 0.8,
                          ),
                        ),
                      ),
                      SizedBox(height: 38.h),
                      Text(
                        AppLocalizations.of(context).translate('login'),
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00D0FF),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        AppLocalizations.of(context).translate('hi_there'),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 31.h),
                      Text(
                        AppLocalizations.of(context).translate('email'),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 9.h),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontSize: 16.sp, 
                          fontFamily: 'DM Sans',
                          color: textColor,
                        ),
                        textDirection: TextDirection.ltr, // Always LTR for email addresses
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: AppLocalizations.of(context).translate('enter_email'),
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            color: hintColor,
                          ),
                          filled: true,
                          fillColor: isDarkMode ? const Color(0xFF1E1E1E) : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00D0FF), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: borderColor, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorMaxLines: 2,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context).translate('email_required');
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return AppLocalizations.of(context).translate('valid_email');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 28.h),
                      Text(
                        AppLocalizations.of(context).translate('password'),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 9.h),
                      TextFormField(
                        controller: _passwordController,
                        autocorrect: false,
                        obscureText: _obscurePassword,
                        style: TextStyle(
                          fontSize: 16.sp, 
                          fontFamily: 'DM Sans',
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: AppLocalizations.of(context).translate('enter_password'),
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            color: hintColor,
                          ),
                          filled: true,
                          fillColor: isDarkMode ? const Color(0xFF1E1E1E) : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00D0FF), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: borderColor, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              color: hintColor,
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            ),
                          ),
                          errorMaxLines: 2,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context).translate('password_required');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: _resetPassword,
                        child: Text(
                          AppLocalizations.of(context).translate('forgot_password'),
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? const Color(0xFFAAAAAAA) : const Color(0xFF787579),
                          ),
                        ),
                      ),
                      SizedBox(height: 100.h),
                      PrimaryButton(
                        text: AppLocalizations.of(context).translate('sign_in'),
                        isLoading: _isLoading,
                        onPressed: _validateAndLogin,
                      ),
                      SizedBox(height: 26.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate('no_account'),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'DM Sans',
                              color: isDarkMode ? Colors.grey[400] : const Color(0xFF757575),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Signup()),
                              );
                            },
                            child: Text(
                              ' ${AppLocalizations.of(context).translate('sign_up')}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'DM Sans',
                                color: const Color(0xFF00D0FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}