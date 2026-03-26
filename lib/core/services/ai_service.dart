import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _model = 'llama-3.3-70b-versatile';
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  final List<Map<String, String>> _history = [];

  static const String _systemPrompt =
      "You are DriveEasy's official AI Car Assistant. Your name is DriveEasy AI. "
      "You help users find, book, and learn about cars in our fleet. "
      "Be professional, helpful, and optimistic. If a user asks for a car recommendation, "
      "suggest popular models like Porsche 911 GT3, Rolls Royce Ghost, or Toyota Supra. "
      "Our fleet focuses on premium, drive-safe, and luxury experiences. "
      "Focus on local car culture in India when relevant. Keep answers concise and friendly.";

  AiService() {
    _initHistory();
  }

  void _initHistory() {
    _history.clear();
    _history.add({'role': 'system', 'content': _systemPrompt});
  }

  Future<String> getResponse(String message) async {
    // Add user message to history
    _history.add({'role': 'user', 'content': message});

    final body = jsonEncode({
      'model': _model,
      'messages': _history,
      'temperature': 0.8,
      'max_tokens': 512,
    });

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'] as String?;
        final reply = text?.trim() ?? 'Sorry, I couldn\'t understand that.';

        // Add model reply to history
        _history.add({'role': 'assistant', 'content': reply});

        return reply;
      } else {
        final err = jsonDecode(response.body);
        final errMsg = err['error']?['message'] ?? 'Unknown error';
        print('Groq API Error ${response.statusCode}: $errMsg');
        return 'Sorry, I ran into an issue ($errMsg). Please try again!';
      }
    } catch (e) {
      print('AI Service Error: $e');
      return 'I\'m having trouble connecting. Please check your internet and try again!';
    }
  }

  void resetChat() {
    _initHistory();
  }
}
