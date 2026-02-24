import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/notification_datasource.dart';
import '../../data/models/notification_model.dart';
import 'user_provider.dart'; // re-exports notificationDatasourceProvider, userNotificationsProvider, unreadNotificationsCountProvider

export 'user_provider.dart'
    show
        userNotificationsProvider,
        unreadNotificationsCountProvider,
        notificationDatasourceProvider;

// Notification operations notifier
class NotificationNotifier extends StateNotifier<AsyncValue<void>> {
  final NotificationDatasource _datasource;

  NotificationNotifier(this._datasource) : super(const AsyncValue.data(null));

  Future<void> markAsRead(String notificationId) async {
    try {
      await _datasource.markAsRead(notificationId);
    } catch (_) {}
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _datasource.markAllAsRead(userId);
    } catch (_) {}
  }

  Future<void> deleteNotification(String notificationId) async {
    state = const AsyncValue.loading();
    try {
      await _datasource.deleteNotification(notificationId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Creates a "Booking Confirmed" notification for the user.
  Future<void> createBookingNotification(String userId, String carName) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: 'Booking Confirmed! 🎉',
        message:
            'Your booking for $carName has been confirmed. Have a great ride!',
        type: 'booking',
        isRead: false,
        createdAt: DateTime.now(),
      );
      await _datasource.createNotification(notification);
    } catch (_) {}
  }

  /// Creates a cancellation notification for the user.
  Future<void> createCancellationNotification(
    String userId,
    String carName,
  ) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: 'Booking Cancelled',
        message: 'Your booking for $carName has been cancelled.',
        type: 'cancelled',
        isRead: false,
        createdAt: DateTime.now(),
      );
      await _datasource.createNotification(notification);
    } catch (_) {}
  }
}

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, AsyncValue<void>>((ref) {
      return NotificationNotifier(ref.watch(notificationDatasourceProvider));
    });
