import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:eazytalk/core/constants/api_constants.dart';
import 'package:eazytalk/models/message_model.dart';

class GeminiService {
  late GenerativeModel _model;
  late ChatSession _chatSession;
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;

  // Initialize the Gemini model
  Future<bool> initializeModel() async {
    try {
      _model = GenerativeModel(
        model: ApiConstants.geminiModel,
        apiKey: ApiConstants.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1000,
        ),
      );
      
      _chatSession = _model.startChat(
        history: [
          Content.text("You are EazyChat AI, a helpful and friendly assistant."),
        ],
      );
      
      _isInitialized = true;
      return true;
    } catch (e) {
      print("Error initializing Gemini model: $e");
      return false;
    }
  }

  // Send message to Gemini API
  Future<Message> sendMessage(String messageText) async {
    if (!_isInitialized) {
      return Message(
        text: "AI model is not initialized. Please restart the app or check logs for details.",
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
    
    try {
      final response = await _chatSession.sendMessage(
        Content.text(messageText),
      );
      
      final responseText = response.text;
      
      return Message(
        text: responseText ?? "Sorry, I couldn't generate a response.",
        isUser: false,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print("Gemini API error: $e");
      
      String errorMsg = e.toString();
      if (errorMsg.contains("API key")) {
        errorMsg = "Invalid API key or API key not set up correctly.";
      } else if (errorMsg.contains("network")) {
        errorMsg = "Network error. Please check your internet connection.";
      } else if (errorMsg.contains("quota")) {
        errorMsg = "API quota exceeded. Please try again later.";
      } else if (errorMsg.length > 100) {
        errorMsg = "${errorMsg.substring(0, 100)}...";
      }
      
      return Message(
        text: "Sorry, there was an error: $errorMsg",
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }
}