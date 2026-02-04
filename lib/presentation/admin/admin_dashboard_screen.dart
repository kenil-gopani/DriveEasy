import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/car_provider.dart';
import '../providers/booking_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsStreamProvider);
    final bookingsAsync = ref.watch(allBookingsProvider);
    final isAdmin = ref.watch(isAdminProvider);

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.adminPanel)),
        body: const Center(child: Text('Access Denied')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text(AppStrings.adminPanel)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: carsAsync.when(
                    data: (cars) => _buildStatCard(
                      context,
                      'Total Cars',
                      '${cars.length}',
                      Icons.directions_car,
                      AppColors.primary,
                    ),
                    loading: () => _buildStatCard(
                      context,
                      'Total Cars',
                      '...',
                      Icons.directions_car,
                      AppColors.primary,
                    ),
                    error: (_, __) => _buildStatCard(
                      context,
                      'Total Cars',
                      'Error',
                      Icons.directions_car,
                      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: bookingsAsync.when(
                    data: (bookings) => _buildStatCard(
                      context,
                      'Bookings',
                      '${bookings.length}',
                      Icons.calendar_today,
                      AppColors.accent,
                    ),
                    loading: () => _buildStatCard(
                      context,
                      'Bookings',
                      '...',
                      Icons.calendar_today,
                      AppColors.accent,
                    ),
                    error: (_, __) => _buildStatCard(
                      context,
                      'Bookings',
                      'Error',
                      Icons.calendar_today,
                      AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: bookingsAsync.when(
                    data: (bookings) {
                      final pending = bookings
                          .where((b) => b.status == 'pending')
                          .length;
                      return _buildStatCard(
                        context,
                        'Pending',
                        '$pending',
                        Icons.pending,
                        AppColors.warning,
                      );
                    },
                    loading: () => _buildStatCard(
                      context,
                      'Pending',
                      '...',
                      Icons.pending,
                      AppColors.warning,
                    ),
                    error: (_, __) => _buildStatCard(
                      context,
                      'Pending',
                      'Error',
                      Icons.pending,
                      AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: bookingsAsync.when(
                    data: (bookings) {
                      final completed = bookings
                          .where((b) => b.status == 'completed')
                          .length;
                      return _buildStatCard(
                        context,
                        'Completed',
                        '$completed',
                        Icons.check_circle,
                        AppColors.success,
                      );
                    },
                    loading: () => _buildStatCard(
                      context,
                      'Completed',
                      '...',
                      Icons.check_circle,
                      AppColors.success,
                    ),
                    error: (_, __) => _buildStatCard(
                      context,
                      'Completed',
                      'Error',
                      Icons.check_circle,
                      AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Quick actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              context,
              icon: Icons.add_circle,
              title: AppStrings.addCar,
              subtitle: 'Add a new car to the inventory',
              onTap: () => context.push(AppRoutes.adminAddCar),
            ),
            _buildActionTile(
              context,
              icon: Icons.directions_car,
              title: AppStrings.manageCars,
              subtitle: 'View and edit all cars',
              onTap: () => context.push(AppRoutes.adminCarList),
            ),
            _buildActionTile(
              context,
              icon: Icons.calendar_month,
              title: AppStrings.manageBookings,
              subtitle: 'View and update booking statuses',
              onTap: () => context.push(AppRoutes.adminManageBookings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
