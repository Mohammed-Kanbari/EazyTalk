import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  // Launch a URL in external application
  static Future<bool> launchExternalUrl(String url) async {
    final Uri uri = Uri.parse(url);
    
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error launching URL: $e');
      return false;
    }
  }
  
  // Show error snackbar if URL launch fails
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  // Launch URL and show error if it fails
  static Future<void> launchUrlWithErrorHandling(
    BuildContext context, 
    String url, 
    {String errorMessage = 'Could not launch the URL'}
  ) async {
    final success = await launchExternalUrl(url);
    
    if (!success) {
      showErrorSnackBar(context, errorMessage);
    }
  }
}