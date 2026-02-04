import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/notification_datasource.dart';
import '../../data/models/favorite_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/car_model.dart';
import '../../data/datasources/car_datasource.dart';
import 'auth_provider.dart';

// Notification datasource provider (shared)
final _notificationDatasourceProvider = Provider(
  (ref) => NotificationDatasource(),
);

// User favorites stream
final userFavoritesProvider = StreamProvider<List<FavoriteModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final datasource = ref.watch(_notificationDatasourceProvider);

  return user.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return datasource.userFavoritesStream(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// Favorite car IDs set for quick lookup
final favoriteCarIdsProvider = Provider<Set<String>>((ref) {
  final favorites = ref.watch(userFavoritesProvider);
  return favorites.when(
    data: (list) => list.map((f) => f.carId).toSet(),
    loading: () => {},
    error: (_, __) => {},
  );
});

// Favorites with car details
final favoriteCarsProvider = FutureProvider<List<CarModel>>((ref) async {
  final favoriteIds = ref.watch(favoriteCarIdsProvider);
  if (favoriteIds.isEmpty) return [];

  final carDatasource = ref.watch(Provider((ref) => CarDatasource()));
  final List<CarModel> cars = [];

  for (final carId in favoriteIds) {
    final car = await carDatasource.getCarById(carId);
    if (car != null) cars.add(car);
  }

  return cars;
});

// Car reviews stream
final carReviewsProvider = StreamProvider.family<List<ReviewModel>, String>((
  ref,
  carId,
) {
  final datasource = ref.watch(_notificationDatasourceProvider);
  return datasource.carReviewsStream(carId);
});

// Favorites notifier
class FavoritesNotifier extends StateNotifier<AsyncValue<void>> {
  final NotificationDatasource _datasource;

  FavoritesNotifier(this._datasource) : super(const AsyncValue.data(null));

  Future<void> toggleFavorite(String userId, String carId) async {
    state = const AsyncValue.loading();
    try {
      await _datasource.toggleFavorite(userId, carId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<bool> isFavorite(String userId, String carId) async {
    return await _datasource.isFavorite(userId, carId);
  }
}

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<void>>((ref) {
      return FavoritesNotifier(ref.watch(_notificationDatasourceProvider));
    });

// Reviews notifier
class ReviewsNotifier extends StateNotifier<AsyncValue<void>> {
  final NotificationDatasource _datasource;
  final CarDatasource _carDatasource;

  ReviewsNotifier(this._datasource, this._carDatasource)
    : super(const AsyncValue.data(null));

  Future<void> addReview({
    required String userId,
    required String userName,
    String? userPhoto,
    required String carId,
    required double rating,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    try {
      final review = ReviewModel(
        id: '',
        userId: userId,
        userName: userName,
        userPhoto: userPhoto ?? '',
        carId: carId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await _datasource.addReview(review);

      // Update car rating
      final reviews = await _datasource.getCarReviews(carId);
      if (reviews.isNotEmpty) {
        final avgRating =
            reviews.map((r) => r.rating).reduce((a, b) => a + b) /
            reviews.length;
        await _carDatasource.updateCarRating(carId, avgRating, reviews.length);
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    state = const AsyncValue.loading();
    try {
      await _datasource.deleteReview(reviewId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final reviewsNotifierProvider =
    StateNotifierProvider<ReviewsNotifier, AsyncValue<void>>((ref) {
      return ReviewsNotifier(
        ref.watch(_notificationDatasourceProvider),
        ref.watch(Provider((ref) => CarDatasource())),
      );
    });
