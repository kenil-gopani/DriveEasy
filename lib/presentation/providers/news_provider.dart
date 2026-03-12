import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/news_service.dart';

final newsServiceProvider = Provider<NewsService>((ref) => NewsService());

final carNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final newsService = ref.watch(newsServiceProvider);
  return newsService.fetchCarNews();
});
