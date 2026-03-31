import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/car_loading_widget.dart';
import '../../data/models/user_model.dart';
import '../../data/seed_data.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/helpers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  UserModel _fallbackUser() {
    final fb = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    return UserModel(
      uid: fb?.uid ?? '',
      name: fb?.displayName ?? fb?.email?.split('@').first ?? 'User',
      email: fb?.email ?? '',
      phone: fb?.phoneNumber ?? '',
      photoUrl: fb?.photoURL ?? '',
      role: 'user',
      profileComplete: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: userAsync.when(
        loading: () => const CarLoadingWidget(message: 'Loading profile'),
        error: (_, __) => _buildProfileBody(context, ref, _fallbackUser(), false),
        data: (userData) => _buildProfileBody(
          context,
          ref,
          userData ?? _fallbackUser(),
          isAdmin,
        ),
      ),
    );
  }

  Widget _buildProfileBody(
    BuildContext context,
    WidgetRef ref,
    UserModel userData,
    bool isAdmin,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Profile Info ────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: userData.photoUrl.isNotEmpty
                              ? userData.photoUrl
                              : UserModel.defaultProfilePhoto,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Online Status Dot
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E), // Green 500
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Name & Info
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userData.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 4),
                if (userData.phone.isNotEmpty)
                  Text(
                    userData.phone,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                if (userData.email.isNotEmpty)
                  Text(
                    userData.email,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
              ],
            ),
          ),

          // ── Menu Items ────────────────────────────────────────
          Container(
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Account
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildSectionHeader(context, 'ACCOUNT'),
                ),
                const SizedBox(height: 8),
                _buildMenuCard(context, [
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: AppStrings.editProfile,
                    onTap: () => context.push(AppRoutes.editProfile),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.lock_outline_rounded,
                    title: AppStrings.changePassword,
                    onTap: () => context.push(AppRoutes.changePassword),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.calendar_month_outlined,
                    title: AppStrings.myBookings,
                    onTap: () => context.push(AppRoutes.bookingHistory),
                    showDivider: false,
                  ),
                ]),

                const SizedBox(height: 24),

                // Preferences
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildSectionHeader(context, 'PREFERENCES'),
                ),
                const SizedBox(height: 8),
                _buildMenuCard(context, [
                  _buildMenuItem(
                    context,
                    icon: Icons.favorite_border_rounded,
                    title: AppStrings.favorites,
                    onTap: () => context.push(AppRoutes.favorites),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.photo_library_outlined,
                    title: 'Photo Gallery',
                    onTap: () => context.push(AppRoutes.gallery),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.camera_alt_outlined,
                    title: 'Camera',
                    onTap: () => context.push(AppRoutes.camera),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_none_rounded,
                    title: AppStrings.notifications,
                    onTap: () => context.push(AppRoutes.notifications),
                  ),

                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: AppStrings.settings,
                    onTap: () => context.push(AppRoutes.settings),
                    showDivider: false,
                  ),
                ]),

                const SizedBox(height: 24),

                // Support
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildSectionHeader(context, 'SUPPORT'),
                ),
                const SizedBox(height: 8),
                _buildMenuCard(context, [
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: AppStrings.helpSupport,
                    onTap: () => context.push(AppRoutes.helpSupport),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.article_outlined,
                    title: 'Driving Tips',
                    onTap: () => context.push(AppRoutes.newsFeed),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.description_outlined,
                    title: AppStrings.termsPrivacy,
                    onTap: () => context.push(AppRoutes.termsPrivacy),
                    showDivider: false,
                  ),
                ]),

                // Admin section
                if (isAdmin) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSectionHeader(context, 'ADMIN'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuCard(context, [
                    _buildMenuItem(
                      context,
                      icon: Icons.admin_panel_settings_rounded,
                      title: AppStrings.adminPanel,
                      onTap: () => context.push(AppRoutes.adminDashboard),
                      iconColor: AppColors.primary,
                      showDivider: false,
                    ),
                  ]),
                ],

                // Dev Tools (owner only)
                if (userData.role == 'owner') ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSectionHeader(context, 'DEV TOOLS'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuCard(context, [
                    _buildMenuItem(
                      context,
                      icon: Icons.cloud_upload_outlined,
                      title: 'Re-Seed 25 Luxury Cars',
                      onTap: () async {
                        final confirm = await AppDialog.confirm(
                          context,
                          title: 'Re-Seed Luxury Cars',
                          message: 'This will DELETE all existing cars and add 25 luxury cars. Continue?',
                          confirmText: 'Seed Now',
                          icon: Icons.cloud_upload_outlined,
                        );
                        if (confirm && context.mounted) {
                          try {
                            await SeedData.seedCarsForCurrentUser();
                            // Success: seeded silently
                          } catch (e) {
                            if (context.mounted) {
                              Helpers.showSnackBar(context, 'Seed failed: $e', isError: true);
                            }
                          }
                        }
                      },
                      iconColor: const Color(0xFF4CAF50),
                      showDivider: false,
                    ),
                  ]),
                ],

                const SizedBox(height: 32),

                // Logout button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await AppDialog.danger(
                        context,
                        title: 'Sign Out',
                        message: 'Are you sure you want to sign out?',
                        confirmText: 'Sign Out',
                        cancelText: 'Stay',
                        icon: Icons.logout_rounded,
                      );
                      if (confirm) {
                        await ref.read(authNotifierProvider.notifier).signOut();
                        if (context.mounted) {
                          context.go(AppRoutes.login);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Helper widgets
  // ─────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
           top: BorderSide(color: AppColors.border),
           bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    bool showDivider = true,
  }) {
    final c = iconColor ?? AppColors.textSecondary;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: c, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textLight,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 68),
            child: Divider(
              height: 1, 
              color: AppColors.border,
            ),
          ),
      ],
    );
  }
}
