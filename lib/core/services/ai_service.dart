import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // Provided Gemini API Key
  static const String _apiKey = 'AIzaSyAPqy8pmzAujno9FjtLuHPZlTtqJoQE3Qc';

  final GenerativeModel _model;
  ChatSession? _chat;

  AiService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: _apiKey,
          systemInstruction: Content.system(
            'You are DriveEasy’s official AI Car Assistant. Your name is DriveEasy AI. '
            'You help users find, book, and learn about cars in our fleet. '
            'Be professional, helpful, and optimistic. If a user asks for a car recommendation, '
            'suggest popular models like Porsche 911 GT3, Rolls Royce Ghost, or Toyota Supra. '
            'Our fleet focuses on premium, drive-safe, and luxury experiences. '
            'Focus on local car culture in India when relevant.'
          ),
        );

  Future<String> getResponse(String message) async {
    _chat ??= _model.startChat();
    
    try {
      final response = await _chat!.sendMessage(Content.text(message));
      return response.text ?? 'I’m sorry, I couldn’t process that. Try again?';
    } catch (e) {
      print('AI Service Error: $e');
      return 'I’m having a little trouble connecting right now. Let’s try that later!';
    }
  }

  void resetChat() {
    _chat = null;
  }
}
