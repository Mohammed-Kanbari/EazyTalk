import 'package:eazytalk/Screens/secondary_screens/navigation.dart';
import 'package:eazytalk/Screens/starting_screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool _obsecurePassword = true;
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
              const SnackBar(
                content: Text('A verification email has been sent. Please check your inbox.'),
              ),
            );
          }

          // Step 3: Wait for verification with a dialog
          bool verified = await _showVerificationDialog(user);
          if (!verified && mounted) {
            // If not verified (e.g., user closed dialog or app), delete the user
            await user.delete();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signup canceled. Please verify your email to complete registration.')),
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
            errorMessage = 'This email is already registered.';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak (minimum 6 characters).';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format.';
            break;
          default:
            errorMessage = 'An error occurred: ${e.message}';
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

    await showDialog<void>(
      context: context,
      barrierDismissible: true, // Allow closing the dialog
      builder: (context) => AlertDialog(
        title: const Text('Verify Your Email'),
        content: const Text('Please click the link in the email we sent to complete signup.'),
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
                  const SnackBar(content: Text('Email not verified yet. Please check your inbox.')),
                );
              }
            },
            child: const Text('I’ve Verified'),
          ),
          TextButton(
            onPressed: () async {
              await user.sendEmailVerification(); // Resend verification email
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification email resent.')),
              );
            },
            child: const Text('Resend Email'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog without verifying
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    return isVerified;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
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
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: screenWidth * 0.24,
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
                            'EazyTalk',
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
                        'Create Account',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00D0FF),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'Sign up to experience communication without barriers',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      SizedBox(height: 31.h),
                      Text(
                        'Username :',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      SizedBox(height: 9.h),
                      TextFormField(
                        controller: _usernameController,
                        style: TextStyle(fontSize: 16.sp, fontFamily: 'DM Sans'),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: 'Enter your name',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFC7C7C7),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF00D0FF), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFC7C7C7), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorMaxLines: 2,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your username';
                          }
                          if (value.trim().length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 28.h),
                      Text(
                        'Email :',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      SizedBox(height: 9.h),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: 16.sp, fontFamily: 'DM Sans'),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFC7C7C7),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF00D0FF), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFC7C7C7), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorMaxLines: 2,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 28.h),
                      Text(
                        'Password :',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      SizedBox(height: 9.h),
                      TextFormField(
                        controller: _passwordController,
                        autocorrect: false,
                        obscureText: _obsecurePassword,
                        style: TextStyle(fontSize: 16.sp, fontFamily: 'DM Sans'),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFC7C7C7),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF00D0FF), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFC7C7C7), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obsecurePassword = !_obsecurePassword;
                              });
                            },
                            icon: Icon(
                              color: const Color(0xFFC7C7C7),
                              _obsecurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            ),
                          ),
                          errorMaxLines: 2,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your password';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Password must contain at least one capital letter';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Password must contain at least one number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 37.h),
                      Container(
                        height: 44.h,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF00D0FF),
                        ),
                        child: MaterialButton(
                          onPressed: _isLoading ? null : _validateAndSignup,
                          minWidth: double.infinity,
                          splashColor: const Color.fromARGB(83, 255, 255, 255),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Sign Up',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: screenWidth < 400 ? 10 : 14,
                                    fontFamily: 'Sora',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 26.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'DM Sans',
                              color: const Color(0xFF757575),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Login()),
                              );
                            },
                            child: Text(
                              ' Log in',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'DM Sans',
                                color: const Color(0xFF00D0FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),
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