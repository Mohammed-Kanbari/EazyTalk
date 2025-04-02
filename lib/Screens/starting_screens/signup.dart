import 'package:eazytalk/Screens/secondary_screens/navigation.dart';
import 'package:eazytalk/Screens/starting_screens/login.dart';
import 'package:eazytalk/widgets/buttons/primary_button.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      UserCredential? userCredential;
      try {
        // Step 1: Create user with email and password
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Step 2: Send email verification
        User? user = userCredential.user;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).translate('verification_sent')),
              ),
            );
          }

          // Step 3: Wait for verification with a dialog
          bool verified = await _showVerificationDialog(user);
          if (!verified && mounted) {
            // If not verified (e.g., user closed dialog or app), delete the user
            await user.delete();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppLocalizations.of(context).translate('signup_canceled'))),
            );
            return;
          }

          // Step 4: If verified, write to Firestore and navigate
          if (mounted) {
            await _firestore.collection('users').doc(user.uid).set({
              'username': _usernameController.text.trim(),
              'email': _emailController.text.trim(),
              'createdAt': FieldValue.serverTimestamp(),
            });

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Navigation()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = AppLocalizations.of(context).translate('email_registered');
            break;
          case 'weak-password':
            errorMessage = AppLocalizations.of(context).translate('password_too_weak');
            break;
          case 'invalid-email':
            errorMessage = AppLocalizations.of(context).translate('valid_email');
            break;
          default:
            errorMessage = '${AppLocalizations.of(context).translate('error_update')}: ${e.message}';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
        // If user was created but an error occurred, delete it
        if (userCredential?.user != null) {
          await userCredential!.user!.delete();
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Show a dialog to prompt user to verify email and return verification status
  Future<bool> _showVerificationDialog(User user) async {
    bool isVerified = false;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dialogBgColor = isDarkMode ? AppColors.darkSurface : Colors.white;
    final textColor = AppColors.getTextPrimaryColor(context);
    final buttonColor = AppColors.primary;

    await showDialog<void>(
      context: context,
      barrierDismissible: true, // Allow closing the dialog
      builder: (context) => AlertDialog(
        backgroundColor: dialogBgColor,
        title: Text(
          AppLocalizations.of(context).translate('verify_email'),
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        content: Text(
          AppLocalizations.of(context).translate('click_link'),
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14.sp,
            color: textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Refresh user data to check verification status
              await user.reload();
              User? updatedUser = _auth.currentUser;
              if (updatedUser != null && updatedUser.emailVerified) {
                isVerified = true;
                Navigator.pop(context); // Close dialog
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context).translate('email_not_verified'))),
                );
              }
            },
            child: Text(
              AppLocalizations.of(context).translate('verified'),
              style: TextStyle(
                color: buttonColor,
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await user.sendEmailVerification(); // Resend verification email
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context).translate('verification_resent'))),
              );
            },
            child: Text(
              AppLocalizations.of(context).translate('resend_email'),
              style: TextStyle(
                color: buttonColor,
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog without verifying
            },
            child: Text(
              AppLocalizations.of(context).translate('cancel'),
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );

    return isVerified;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // Theme-appropriate colors
    final backgroundColor = AppColors.getBackgroundColor(context);
    final textColor = AppColors.getTextPrimaryColor(context);

    // Input field styling
    final borderColor =
        isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFC7C7C7);

    final hintColor =
        isDarkMode ? const Color(0xFF7A7A7A) : const Color(0xFFC7C7C7);

    final inputFillColor = isDarkMode ? const Color(0xFF1E1E1E) : null;

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
                        padding: EdgeInsets.only(top: screenHeight * 0.087),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            child: Image.asset(
                              'assets/images/appIcon1.png',
                              width: screenWidth * 0.24,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25.h),
                      Center(
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF00D0FF), Color(0xFF043477)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: Text(
                            AppLocalizations.of(context).translate('app_name'),
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00D0FF),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 57.h),
                      Text(
                        AppLocalizations.of(context).translate('create_account'),
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00D0FF),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        AppLocalizations.of(context).translate('sign_up_desc'),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 31.h),
                      Text(
                        AppLocalizations.of(context).translate('username'),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 9.h),
                      TextFormField(
                        controller: _usernameController,
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'DM Sans',
                            color: textColor),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          hintText: AppLocalizations.of(context).translate('enter_username'),
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            color: hintColor,
                          ),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFF00D0FF), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: borderColor, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorMaxLines: 2,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context).translate('required_field');
                          }
                          if (value.trim().length < 3) {
                            return AppLocalizations.of(context).translate('username_short');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 28.h),
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
                        textDirection: TextDirection.ltr, // Email is always LTR
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'DM Sans',
                            color: textColor),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          hintText: AppLocalizations.of(context).translate('enter_email'),
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            color: hintColor,
                          ),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFF00D0FF), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: borderColor, width: 1),
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
                            color: textColor),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          hintText: AppLocalizations.of(context).translate('enter_password'),
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            color: hintColor,
                          ),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFF00D0FF), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: borderColor, width: 1),
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
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                          ),
                          errorMaxLines: 2,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context).translate('password_required');
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return AppLocalizations.of(context).translate('capital_letter');
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return AppLocalizations.of(context).translate('contains_number');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 37.h),
                      PrimaryButton(
                        text: AppLocalizations.of(context).translate('sign_in'),
                        isLoading: _isLoading,
                        onPressed: _validateAndSignup,
                      ),
                      SizedBox(height: 26.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate('already_account'),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'DM Sans',
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : const Color(0xFF757575),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Login()),
                              );
                            },
                            child: Text(
                              ' ${AppLocalizations.of(context).translate('log_in')}',
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