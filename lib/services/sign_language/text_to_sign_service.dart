import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TextToSignService {
  // For avatar mode
  InAppWebViewController? _webViewController;
  bool _isAvatarReady = false;
  double _avatarSpeed = 1.0;
  
  // Copy to clipboard helper
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
  
  // Convert text to sign language images using SignConverter.com
  Future<List<Map<String, dynamic>>> convertTextToSignImages(String text) async {
    try {
      // Split the text into individual words
      final words = text.split(' ').where((word) => word.trim().isNotEmpty).toList();
      List<Map<String, dynamic>> result = [];
      
      // For each word, break it down into individual letters
      for (var word in words) {
        try {
          final cleanWord = word.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
          if (cleanWord.isEmpty) continue;
          
          // Add the word as a marker
          result.add({
            'type': 'word_marker',
            'word': cleanWord,
          });
          
          // Break the word into individual letters
          for (var i = 0; i < cleanWord.length; i++) {
            final letter = cleanWord[i];
            
            // Only process valid ASL characters
            if (_isValidASLCharacter(letter)) {
              final urls = _getSignImageUrls(letter);
              
              // Add letter with its URL
              if (urls.isNotEmpty) {
                result.add({
                  'type': 'letter',
                  'letter': letter,
                  'url': urls.first,
                  'fallbackUrls': urls.skip(1).toList(),
                });
              }
            }
          }
        } catch (e) {
          print('Error processing word "$word": $e');
          // Continue with next word even if one fails
        }
      }
      
      return result;
    } catch (e) {
      throw 'Failed to convert text to sign language: $e';
    }
  }
  
  // Helper method to generate possible sign language image URLs
  List<String> _getSignImageUrls(String letter) {
    List<String> urls = [];
    
    // Primary source: SignConverter.com (letters for ASL fingerspelling)
    urls.add('https://signconverter.com/assets/asl-version/$letter.jpg');
    
    // Fallback sources if we need them in the future
    
    // Potential fallback 1: Lifeprint
    urls.add('https://www.lifeprint.com/asl101/fingerspelling/abc/$letter.gif');
    
    // Potential fallback 2: HandSpeak
    urls.add('https://www.handspeak.com/spell/alphabet/$letter.jpg');
    
    return urls;
  }
  
  // Check if character is valid for ASL fingerspelling
  bool _isValidASLCharacter(String char) {
    // Letters a-z are valid
    if (RegExp(r'[a-z]').hasMatch(char)) {
      return true;
    }
    
    // Numbers 0-9 are valid
    if (RegExp(r'[0-9]').hasMatch(char)) {
      return true;
    }
    
    // Some ASL has special signs for some punctuation
    if (['.', '?', '!', ','].contains(char)) {
      return true;
    }
    
    return false;
  }
  
  // Fallback method to get sign image from a different source if first one fails
  Future<String?> getAlternativeSignImage(String word) async {
    try {
      // Try alternative source - some words might be available at ASL browser
      final altUrl = 'https://www.signasl.org/sign/$word';
      
      // We're not actually doing a fetch here since that would require HTML parsing
      // This is a placeholder for a more complex implementation
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Prepare avatar animation
  Future<bool> prepareAvatarAnimation(String text) async {
    try {
      // In a real implementation, you would prepare the animation
      // by calling an API or setting up the avatar
      
      // Simulate network delay
      await Future.delayed(Duration(seconds: 2));
      
      // Set the avatar as ready
      _isAvatarReady = true;
      
      // If we have a web view controller, load the animation
      if (_webViewController != null) {
        await _loadAvatarAnimation(text);
      }
      
      return true;
    } catch (e) {
      _isAvatarReady = false;
      throw 'Failed to prepare avatar animation: $e';
    }
  }
  
  // Load animation into WebView
  Future<void> _loadAvatarAnimation(String text) async {
    if (_webViewController == null) return;
    
    try {
      // Encode the text for URL safety
      final encodedText = Uri.encodeComponent(text);
      
      // Create JavaScript to load the animation
      // In a real implementation, you would use the actual API URL
      final js = '''
        // This is a placeholder for the actual API integration
        // In a real implementation, you would call the sign language API
        
        // Simulate animation loading
        document.body.innerHTML = '<div style="display: flex; justify-content: center; align-items: center; height: 100%; color: white; font-family: sans-serif;">' +
          '<h2>Animating: "$text"</h2>' +
          '</div>';
          
        // Report back that animation is loaded
        window.flutter_inappwebview.callHandler('onAnimationLoaded', true);
      ''';
      
      // Execute the JavaScript
      await _webViewController!.evaluateJavascript(source: js);
    } catch (e) {
      print('Error loading avatar animation: $e');
    }
  }
  
  // Replay avatar animation
  void replayAvatarAnimation() {
    if (_webViewController != null && _isAvatarReady) {
      _webViewController!.reload();
    }
  }
  
  // Toggle avatar animation speed
  void toggleAvatarSpeed() {
    // Cycle through speeds: 1.0 -> 0.75 -> 0.5 -> 1.0
    _avatarSpeed = _avatarSpeed == 1.0 ? 0.75 : (_avatarSpeed == 0.75 ? 0.5 : 1.0);
    
    if (_webViewController != null && _isAvatarReady) {
      _webViewController!.evaluateJavascript(
        source: 'document.querySelector("h2").innerText += " (Speed: $_avatarSpeed×)";'
      );
    }
  }
  
  // Get web view widget for avatar
  Widget getAvatarWidget() {
    return InAppWebView(
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          javaScriptEnabled: true,
          useShouldOverrideUrlLoading: true,
        ),
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        
        // Add JavaScript handler for communication
        controller.addJavaScriptHandler(
          handlerName: 'onAnimationLoaded',
          callback: (args) {
            // Handle animation loaded event
            print('Animation loaded: ${args.first}');
          }
        );
        
        // Load initial content
        controller.loadData(
          data: '''
          <!DOCTYPE html>
          <html>
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <style>
                body {
                  margin: 0;
                  padding: 0;
                  background-color: #000;
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  height: 100vh;
                  color: white;
                  font-family: sans-serif;
                }
              </style>
            </head>
            <body>
              <h3>Enter text and press Convert</h3>
            </body>
          </html>
          ''',
          mimeType: 'text/html',
          encoding: 'utf-8',
        );
      },
      onLoadStop: (controller, url) {
        if (_isAvatarReady) {
          // If animation should be loaded, load it
          controller.getUrl().then((currentUrl) {
            if (currentUrl?.toString().contains('about:blank') == true) {
              // This is initial load, we need to set up the animation
              _loadAvatarAnimation('');
            }
          });
        }
      },
    );
  }
}