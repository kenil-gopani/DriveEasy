import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String sourceName;
  final String sourceFavicon;
  final String publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.sourceName,
    required this.sourceFavicon,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'Auto News India',
      description: json['description'] ?? '',
      url: json['link'] ?? '',
      imageUrl: json['image_url'] ?? 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&q=80&w=600',
      sourceName: json['source_name'] ?? 'Car News',
      sourceFavicon: json['source_icon'] ?? '',
      publishedAt: json['pubDate'] ?? '',
    );
  }
}

class NewsService {
  static const String _baseUrl = 'https://newsdata.io/api/1/latest';
  static const String _apiKey = 'pub_8f606cf95eaa4859b556f98547c6c41c';

  Future<List<NewsArticle>> fetchCarNews() async {
    try {
      // Strictly matched to user's specified NewsData.io dashboard parameters
      final Uri uri = Uri.parse(
        '$_baseUrl?apikey=$_apiKey'
        '&q=car%20india'
        '&country=in'
        '&language=en'
        '&category=technology'
        '&timezone=asia/kolkata'
        '&prioritydomain=top'
        '&image=1'
        '&video=0'
        '&removeduplicate=1'
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          final List results = data['results'] ?? [];
          return results.map((json) => NewsArticle.fromJson(json)).toList();
        } else {
          throw Exception('API error: ${data['message'] ?? 'Please check your NewsData dashboard.'}');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('NewsData.io error: $e');
      throw Exception('Could not refresh car news from India.');
    }
  }
}
