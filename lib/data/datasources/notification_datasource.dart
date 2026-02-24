import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../models/review_model.dart';
import '../models/favorite_model.dart';

class NotificationDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      _firestore.collection('notifications');

  CollectionReference<Map<String, dynamic>> get _reviewsCollection =>
      _firestore.collection('reviews');

  CollectionReference<Map<String, dynamic>> get _favoritesCollection =>
      _firestore.collection('favorites');

  // Notifications
  Stream<List<NotificationModel>> userNotificationsStream(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _notificationsCollection.add(notification.toMap());
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).delete();
  }

  /// Builds a booking confirmed notification model (does NOT save it).
  NotificationModel buildBookingNotification(String userId, String carName) {
    return NotificationModel(
      id: '',
      userId: userId,
      title: 'Booking Confirmed! 🎉',
      message:
          'Your booking for $carName has been confirmed. Have a great ride!',
      type: 'booking',
      isRead: false,
      createdAt: DateTime.now(),
    );
  }

  // Reviews
  Future<List<ReviewModel>> getCarReviews(String carId) async {
    final snapshot = await _reviewsCollection
        .where('carId', isEqualTo: carId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<ReviewModel>> carReviewsStream(String carId) {
    return _reviewsCollection
        .where('carId', isEqualTo: carId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addReview(ReviewModel review) async {
    await _reviewsCollection.add(review.toMap());
  }

  Future<void> deleteReview(String reviewId) async {
    await _reviewsCollection.doc(reviewId).delete();
  }

  // Favorites
  Future<List<FavoriteModel>> getUserFavorites(String userId) async {
    final snapshot = await _favoritesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => FavoriteModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<FavoriteModel>> userFavoritesStream(String userId) {
    return _favoritesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FavoriteModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<bool> isFavorite(String userId, String carId) async {
    final snapshot = await _favoritesCollection
        .where('userId', isEqualTo: userId)
        .where('carId', isEqualTo: carId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> addToFavorites(String userId, String carId) async {
    await _favoritesCollection.add({
      'userId': userId,
      'carId': carId,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> removeFromFavorites(String userId, String carId) async {
    final snapshot = await _favoritesCollection
        .where('userId', isEqualTo: userId)
        .where('carId', isEqualTo: carId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> toggleFavorite(String userId, String carId) async {
    final isFav = await isFavorite(userId, carId);
    if (isFav) {
      await removeFromFavorites(userId, carId);
    } else {
      await addToFavorites(userId, carId);
    }
  }
}
