import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/post_model.dart';

/// Service for making HTTP GET requests to public APIs.
class ApiService {
  ApiService._();

  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  /// Fetches the list of posts from JSONPlaceholder.
  /// Throws an [Exception] if the request fails or returns non-200.
  static Future<List<PostModel>> fetchPosts() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/posts'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
      return json
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load posts (HTTP ${response.statusCode})');
    }
  }
}
