import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/auth_provider.dart';

// Screens
import '../presentation/auth/splash_screen.dart';
import '../presentation/auth/onboarding_screen.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/signup_screen.dart';
import '../presentation/auth/forgot_password_screen.dart';
import '../presentation/auth/phone_login_screen.dart';
import '../presentation/auth/complete_profile_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/home/car_details_screen.dart';
import '../presentation/home/search_screen.dart';
import '../presentation/home/category_screen.dart';
import '../presentation/booking/booking_screen.dart';
import '../presentation/booking/booking_confirmation_screen.dart';
import '../presentation/booking/booking_history_screen.dart';
import '../presentation/payment/payment_screen.dart';
import '../presentation/profile/profile_screen.dart';
import '../presentation/profile/edit_profile_screen.dart';
import '../presentation/profile/change_password_screen.dart';
import '../presentation/profile/settings_screen.dart';
import '../presentation/favorites/favorites_screen.dart';
import '../presentation/reviews/reviews_screen.dart';
import '../presentation/notifications/notifications_screen.dart';
import '../presentation/support/help_support_screen.dart';
import '../presentation/support/terms_privacy_screen.dart';
import '../presentation/admin/admin_dashboard_screen.dart';
import '../presentation/admin/add_edit_car_screen.dart';
import '../presentation/admin/manage_bookings_screen.dart';
import '../presentation/admin/admin_car_list_screen.dart';

// Route paths
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String phoneLogin = '/phone-login';
  static const String completeProfile = '/complete-profile';
  static const String home = '/home';
  static const String carDetails = '/car/:id';
  static const String search = '/search';
  static const String category = '/category/:name';
  static const String booking = '/booking';
  static const String payment = '/payment';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String bookingHistory = '/booking-history';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String settings = '/settings';
  static const String favorites = '/favorites';
  static const String reviews = '/reviews/:carId';
  static const String notifications = '/notifications';
  static const String helpSupport = '/help-support';
  static const String termsPrivacy = '/terms-privacy';
  static const String adminDashboard = '/admin';
  static const String adminAddCar = '/admin/add-car';
  static const String adminEditCar = '/admin/edit-car/:id';
  static const String adminManageBookings = '/admin/bookings';
  static const String adminCarList = '/admin/cars';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.phoneLogin ||
          state.matchedLocation == AppRoutes.onboarding;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      // Don't redirect from splash - let it handle its own logic
      if (isSplash) return null;

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }

      // If logged in and trying to access auth routes
      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.phoneLogin,
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.carDetails,
        builder: (context, state) {
          final carId = state.pathParameters['id']!;
          return CarDetailsScreen(carId: carId);
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.category,
        builder: (context, state) {
          final categoryName = state.pathParameters['name']!;
          return CategoryScreen(category: categoryName);
        },
      ),
      GoRoute(
        path: AppRoutes.booking,
        builder: (context, state) => const BookingScreen(),
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingConfirmation,
        builder: (context, state) => const BookingConfirmationScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingHistory,
        builder: (context, state) => const BookingHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.reviews,
        builder: (context, state) {
          final carId = state.pathParameters['carId']!;
          return ReviewsScreen(carId: carId);
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpSupport,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.termsPrivacy,
        builder: (context, state) => const TermsPrivacyScreen(),
      ),
      // Admin routes
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAddCar,
        builder: (context, state) => const AddEditCarScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminEditCar,
        builder: (context, state) {
          final carId = state.pathParameters['id']!;
          return AddEditCarScreen(carId: carId);
        },
      ),
      GoRoute(
        path: AppRoutes.adminManageBookings,
        builder: (context, state) => const ManageBookingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCarList,
        builder: (context, state) => const AdminCarListScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
});
