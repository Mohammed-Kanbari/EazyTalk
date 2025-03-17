import 'package:eazytalk/Screens/secondary_screens/navigation.dart';
import 'package:eazytalk/Screens/starting_screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obsecurePassword = true;
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
            errorMessage = 'No account found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email.';
            break;
          default:
            errorMessage = 'An error occurred: ${e.message}';
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
            SnackBar(content: Text('An unexpected error occurred: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false); // Hide loading spinner
      }
    }
  }

  Future <void> _resetPassword() async {
    if(_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );  
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent. Check your inbox.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send password reset email: $e')),
      );
    }
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
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00D0FF),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'Hi there, sign in to continue',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      SizedBox(height: 31.h),
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
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: _resetPassword,
                        child: Text(
                          'Forget Password ?',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF787579),
                          ),
                        ),
                      ),
                      SizedBox(height: 100.h),
                      Container(
                        height: 44.h,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF00D0FF),
                        ),
                        child: MaterialButton(
                          onPressed: _isLoading ? null : _validateAndLogin, // Fixed callback
                          minWidth: double.infinity,
                          splashColor: const Color.fromARGB(83, 255, 255, 255),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Sign In',
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
                            "Don't have an account?",
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
                                MaterialPageRoute(builder: (context) => const Signup()),
                              );
                            },
                            child: Text(
                              ' Sign up',
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