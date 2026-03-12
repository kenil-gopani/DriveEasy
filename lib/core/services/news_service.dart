import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String sourceName;
  final DateTime publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      sourceName: json['source']?['name'] ?? 'Unknown',
      publishedAt:
          DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class NewsService {
  // Using a free NewsAPI.org key. (Note: in production this should be in an env file)
  static const String _apiKey = 'f892348570ab418fa7ee7848c4ae171f';
  static const String _baseUrl = 'https://newsapi.org/v2/everything';

  Future<List<NewsArticle>> fetchCarNews() async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?q="cars" OR "auto show" OR "electric vehicle"&sortBy=publishedAt&language=en&apiKey=$_apiKey',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List articlesList = data['articles'] ?? [];

        return articlesList
            .where(
              (json) => json['title'] != null && json['urlToImage'] != null,
            )
            .map((json) => NewsArticle.fromJson(json))
            .take(10) // Limit to top 10 recent articles
            .toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching news: $e');
    }
  }
}
