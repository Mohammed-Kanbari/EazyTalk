import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordUpdateService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Update user password
  Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Get current user
      User? user = _auth.currentUser;
      
      if (user == null) {
        return {
          'success': false,
          'message': 'No user is currently signed in.',
          'code': 'user-not-found'
        };
      }

      // Get the user's credentials with current password for reauthentication
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // Reauthenticate the user first
      await user.reauthenticateWithCredential(credential);
      
      // Then update the password
      await user.updatePassword(newPassword);
      
      return {'success': true, 'message': 'Password updated successfully'};
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
      
      return {
        'success': false,
        'message': errorMessage,
        'code': e.code
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
        'code': 'unknown-error'
      };
    }
  }
  
  // Show a snackbar to inform the user about the result
  static void showResultSnackBar(BuildContext context, bool success, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: success 
            ? Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(message),
                ],
              )
            : Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}