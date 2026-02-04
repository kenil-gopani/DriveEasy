import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/datasources/user_datasource.dart';
import '../../data/models/user_model.dart';

// Datasource providers
final authDatasourceProvider = Provider((ref) => AuthDatasource());
final userDatasourceProvider = Provider((ref) => UserDatasource());

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authDatasource = ref.watch(authDatasourceProvider);
  return authDatasource.authStateChanges;
});

// Current user provider
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final userDatasource = ref.watch(userDatasourceProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return userDatasource.userStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Auth notifier for auth operations
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthDatasource _authDatasource;
  // ignore: unused_field - Reserved for future user operations
  final UserDatasource _userDatasource;

  AuthNotifier(this._authDatasource, this._userDatasource)
    : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String role = 'user',
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authDatasource.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authDatasource.signIn(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authDatasource.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> resetPassword(String email) async {
    await _authDatasource.resetPassword(email);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _authDatasource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  // Phone OTP Authentication
  Future<void> sendPhoneOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(String error) onVerificationFailed,
  }) async {
    await _authDatasource.sendPhoneOTP(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationCompleted: onVerificationCompleted,
      onVerificationFailed: onVerificationFailed,
    );
  }

  Future<void> verifyPhoneOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authDatasource.verifyPhoneOTP(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authDatasource.signInWithPhoneCredential(credential);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
      return AuthNotifier(
        ref.watch(authDatasourceProvider),
        ref.watch(userDatasourceProvider),
      );
    });

// Is admin provider
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.when(
    data: (user) => user?.isAdmin ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Is owner provider
final isOwnerProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.when(
    data: (user) => user?.isOwner ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Can list cars provider (owner or admin)
final canListCarsProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.when(
    data: (user) => user?.canListCars ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});
