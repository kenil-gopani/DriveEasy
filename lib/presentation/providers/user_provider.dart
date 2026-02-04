import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../data/datasources/user_datasource.dart';
import '../../data/datasources/notification_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/models/notification_model.dart';

import 'auth_provider.dart';

// Notification datasource provider
final notificationDatasourceProvider = Provider(
  (ref) => NotificationDatasource(),
);

// User notifications stream
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

// User profile notifier
class UserProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final UserDatasource _userDatasource;

  UserProfileNotifier(this._userDatasource)
    : super(const AsyncValue.data(null));

  Future<void> updateProfile(UserModel user) async {
    state = const AsyncValue.loading();
    try {
      await _userDatasource.updateUser(
        user.copyWith(updatedAt: DateTime.now()),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<String> uploadAndUpdatePhoto(String uid, File file) async {
    state = const AsyncValue.loading();
    try {
      final photoUrl = await _userDatasource.uploadProfilePhoto(uid, file);
      await _userDatasource.updateProfilePhoto(uid, photoUrl);
      state = const AsyncValue.data(null);
      return photoUrl;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<void>>((ref) {
      return UserProfileNotifier(ref.watch(userDatasourceProvider));
    });
