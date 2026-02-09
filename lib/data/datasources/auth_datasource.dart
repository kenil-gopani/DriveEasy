import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';

class AuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Client ID is required for web platform
    clientId: kIsWeb
        ? '230143979477-47s1sdfm0lp44k5m6aga16b85035dld0.apps.googleusercontent.com'
        : null,
  );

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String role = 'user',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        throw Exception('User profile not found');
      }

      return UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    // Sign out from Google as well
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore Google sign-out errors
    }
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // Google Sign-In
  Future<UserModel> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // For Web: Use Firebase's native signInWithPopup (more reliable)
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // For Mobile: Use google_sign_in package
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          throw 'Google sign-in was cancelled';
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        userCredential = await _auth.signInWithCredential(credential);
      }

      final uid = userCredential.user!.uid;
      final email = userCredential.user!.email ?? '';
      final displayName =
          userCredential.user!.displayName ?? email.split('@').first;
      final photoUrl = userCredential.user!.photoURL;

      // Check if user exists in Firestore
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        // Update profile photo if available and changed
        if (photoUrl != null) {
          final existingUser = UserModel.fromMap(doc.data()!);
          if (existingUser.photoUrl != photoUrl) {
            await _firestore.collection('users').doc(uid).update({
              'photoUrl': photoUrl,
              'updatedAt': DateTime.now().toIso8601String(),
            });
          }
        }
        final updatedDoc = await _firestore.collection('users').doc(uid).get();
        return UserModel.fromMap(updatedDoc.data()!);
      }

      // Create new user if first time (Google sign-in)
      final user = UserModel(
        uid: uid,
        name: displayName,
        email: email,
        phone: '',
        role: 'user',
        photoUrl: photoUrl ?? '',
        profileComplete: false, // Mark as incomplete for Google signups
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e.toString().contains('cancelled') ||
          e.toString().contains('popup-closed')) {
        throw 'Google sign-in was cancelled';
      }
      throw 'Failed to sign in with Google. Please try again.';
    }
  }

  // Phone OTP Authentication
  int? _resendToken;

  Future<void> sendPhoneOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(String error) onVerificationFailed,
    bool isResend = false,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: isResend ? _resendToken : null,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: (e) {
          onVerificationFailed(_handlePhoneAuthException(e));
        },
        codeSent: (verificationId, resendToken) {
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // OTP auto-retrieval timed out, user needs to enter manually
        },
        timeout: const Duration(seconds: 120),
      );
    } catch (e) {
      onVerificationFailed(e.toString());
    }
  }

  String _handlePhoneAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number entered is invalid. Please check and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again after some time.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase Authentication.';
      case 'captcha-check-failed':
        return 'reCAPTCHA verification failed. Please try again.';
      case 'missing-phone-number':
        return 'Please enter a phone number.';
      case 'session-expired':
        return 'The verification session has expired. Please request a new OTP.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again.';
      case 'invalid-verification-id':
        return 'Verification session expired. Please request a new OTP.';
      default:
        return e.message ?? 'Phone authentication failed. Please try again.';
    }
  }

  Future<UserModel> verifyPhoneOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      return await signInWithPhoneCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handlePhoneAuthException(e);
    } catch (e) {
      throw 'Verification failed. Please try again.';
    }
  }

  Future<UserModel> signInWithPhoneCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;
      final phone = userCredential.user!.phoneNumber ?? '';

      // Check if user exists in Firestore
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }

      // Create new user if first time (phone login)
      // Set profileComplete to false so user is prompted to complete profile
      final user = UserModel(
        uid: uid,
        name: phone, // Use phone as temporary name
        email: '',
        phone: phone,
        role: 'user',
        profileComplete: false, // Mark as incomplete for phone signups
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handlePhoneAuthException(e);
    } catch (e) {
      throw 'Failed to sign in with phone. Please try again.';
    }
  }
}
