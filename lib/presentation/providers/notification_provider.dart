import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/notification_datasource.dart';
import '../../data/models/notification_model.dart';
import 'auth_provider.dart';

// Re-export notification datasource provider
final notificationDatasourceProvider = Provider(
  (ref) => NotificationDatasource(),
);

// User notifications stream provider
final userNotificationsProvider = StreamProvider<List<NotificationModel>>((
  ref,
) {
  final user = ref.watch(currentUserProvider);
  final datasource = ref.watch(notificationDatasourceProvider);

  return user.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return datasource.userNotificationsStream(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// Unread notifications count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(userNotificationsProvider);
  return notifications.when(
    data: (list) => list.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Notification operations notifier
class NotificationNotifier extends StateNotifier<AsyncValue<void>> {
  final NotificationDatasource _datasource;

  NotificationNotifier(this._datasource) : super(const AsyncValue.data(null));

  Future<void> markAsRead(String notificationId) async {
    try {
      await _datasource.markAsRead(notificationId);
    } catch (e) {
      // Silent fail for mark as read
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _datasource.markAllAsRead(userId);
    } catch (e) {
      // Silent fail
    }
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
}

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, AsyncValue<void>>((ref) {
      return NotificationNotifier(ref.watch(notificationDatasourceProvider));
    });
