import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_dialog.dart';

import '../../data/seed_data.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: user.when(
        data: (userData) {
          if (userData == null) {
            return const Center(child: Text('Please login'));
          }
          return CustomScrollView(
            slivers: [
              // Profile Header
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(gradient: AppColors.heroGradient),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => context.pop(),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Profile',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () =>
                                    context.push(AppRoutes.editProfile),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Avatar
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundColor: AppColors.surface,
                                  backgroundImage: userData.photoUrl.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          userData.photoUrl,
                                        )
                                      : null,
                                  child: userData.photoUrl.isEmpty
                                      ? Text(
                                          userData.name.isNotEmpty
                                              ? userData.name[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 45,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              if (isAdmin)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'ADMIN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userData.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userData.email,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                          ),
                          if (userData.phone.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              userData.phone,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Menu Items
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, -24, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Account Section
                        _buildSectionHeader(context, 'Account'),
                        const SizedBox(height: 12),
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
                        // Preferences Section
                        _buildSectionHeader(context, 'Preferences'),
                        const SizedBox(height: 12),
                        _buildMenuCard(context, [
                          _buildMenuItem(
                            context,
                            icon: Icons.favorite_border_rounded,
                            title: AppStrings.favorites,
                            onTap: () => context.push(AppRoutes.favorites),
                          ),
                          _buildMenuItem(
                            context,
                            icon: Icons.notifications_outlined,
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
                        // Support Section
                        _buildSectionHeader(context, 'Support'),
                        const SizedBox(height: 12),
                        _buildMenuCard(context, [
                          _buildMenuItem(
                            context,
                            icon: Icons.help_outline_rounded,
                            title: AppStrings.helpSupport,
                            onTap: () => context.push(AppRoutes.helpSupport),
                          ),
                          _buildMenuItem(
                            context,
                            icon: Icons.description_outlined,
                            title: AppStrings.termsPrivacy,
                            onTap: () => context.push(AppRoutes.termsPrivacy),
                            showDivider: false,
                          ),
                        ]),
                        if (isAdmin) ...[
                          const SizedBox(height: 24),
                          _buildSectionHeader(context, 'Admin'),
                          const SizedBox(height: 12),
                          _buildMenuCard(context, [
                            _buildMenuItem(
                              context,
                              icon: Icons.admin_panel_settings_rounded,
                              title: AppStrings.adminPanel,
                              onTap: () =>
                                  context.push(AppRoutes.adminDashboard),
                              iconColor: AppColors.accent,
                              showDivider: false,
                            ),
                          ]),
                        ],
                        if (userData.role == 'owner') ...[
                          const SizedBox(height: 24),
                          _buildSectionHeader(context, 'Dev Tools'),
                          const SizedBox(height: 12),
                          _buildMenuCard(context, [
                            _buildMenuItem(
                              context,
                              icon: Icons.cloud_upload_outlined,
                              title: '🚗 Re-Seed 25 Luxury Cars',
                              subtitle: 'Clears old cars & adds luxury fleet',
                              iconColor: const Color(0xFF4CAF50),
                              onTap: () async {
                                final confirm = await AppDialog.confirm(
                                  context,
                                  title: 'Re-Seed Luxury Cars',
                                  message:
                                      'This will DELETE all existing cars and add 25 luxury cars (Lamborghini, Ferrari, Rolls-Royce, Bugatti…) with your account as owner. Continue?',
                                  confirmText: 'Seed Now',
                                  icon: Icons.cloud_upload_outlined,
                                );
                                if (confirm && context.mounted) {
                                  try {
                                    final result =
                                        await SeedData.seedCarsForCurrentUser();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(result),
                                          backgroundColor: const Color(
                                            0xFF4CAF50,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              showDivider: false,
                            ),
                          ]),
                        ],
                        const SizedBox(height: 24),
                        // Logout Button
                        GestureDetector(
                          onTap: () async {
                            final confirm = await AppDialog.danger(
                              context,
                              title: 'Sign Out',
                              message:
                                  'Are you sure you want to sign out of Drive Easy?',
                              confirmText: 'Sign Out',
                              cancelText: 'Stay',
                              icon: Icons.logout_rounded,
                            );
                            if (confirm) {
                              await ref
                                  .read(authNotifierProvider.notifier)
                                  .signOut();
                              if (context.mounted) {
                                context.go(AppRoutes.login);
                              }
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.logout,
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading profile')),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textLight,
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
          ),
      ],
    );
  }
}
