import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eazytalk/widgets/voice_navigation/voice_command_guide.dart';

class VoiceCommandHelper {
  static const String _hasShownGuideKey = 'has_shown_voice_command_guide';
  
  // Show the guide dialog when the user first encounters the voice command button
  static Future<void> showGuideIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool hasShownGuide = prefs.getBool(_hasShownGuideKey) ?? false;
    
    if (!hasShownGuide) {
      // Mark as shown so we don't show it again
      await prefs.setBool(_hasShownGuideKey, true);
      
      // Show the tooltip guiding users to the voice command feature
      if (context.mounted) {
        _showVoiceCommandIntroduction(context);
      }
    }
  }
  
  // Show an introduction tooltip to help users discover the voice command feature
  static void _showVoiceCommandIntroduction(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('New Feature: Voice Commands'),
            content: const Text(
              'You can now navigate the app using voice commands. Tap the microphone button in the bottom right to try it out!'
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Later'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  navigateToVoiceCommandGuide(context);
                },
                child: const Text('Learn More'),
              ),
            ],
          );
        },
      );
    });
  }
  
  // Navigate to the voice command guide screen
  static void navigateToVoiceCommandGuide(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VoiceCommandGuide()),
    );
  }
}