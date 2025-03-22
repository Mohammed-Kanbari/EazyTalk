import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Sign out user
  Future<void> signOut() async {
    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Sign out from Firebase
    await _auth.signOut();
  }
  
  // Show logout confirmation dialog
  Future<bool> showLogoutConfirmationDialog(BuildContext context, Color primaryColor) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Logout',
          style: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontFamily: 'DM Sans',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: primaryColor,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Sora',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}