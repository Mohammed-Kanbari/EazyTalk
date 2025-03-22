import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  // Stream to listen to connectivity changes
  Stream<bool> get connectivityStream => Connectivity()
      .onConnectivityChanged
      .map((result) => result == ConnectivityResult.none);

  // Check current connectivity status
  Future<bool> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
  }

  // Show connectivity dialog
  static void showConnectivityDialog(BuildContext context, TextStyle titleStyle, TextStyle contentStyle, TextStyle buttonStyle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'No Internet Connection',
            style: titleStyle,
          ),
          content: Text(
            'Please check your internet connection to use all features.',
            style: contentStyle,
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: buttonStyle,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}