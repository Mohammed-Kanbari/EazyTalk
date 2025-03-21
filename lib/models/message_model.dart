import 'package:intl/intl.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // Helper method for formatting time
  String get formattedTime {
    return DateFormat('h:mm a').format(timestamp).toLowerCase();
  }
}