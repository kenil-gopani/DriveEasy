import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/booking_model.dart';
import '../providers/booking_provider.dart';

class ManageBookingsScreen extends ConsumerWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(allBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text(AppStrings.manageBookings)),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return EmptyState(
              icon: Icons.calendar_today_outlined,
              title: 'No Bookings',
              subtitle: 'Bookings will appear here',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _AdminBookingCard(booking: bookings[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AdminBookingCard extends ConsumerWidget {
  final BookingModel booking;

  const _AdminBookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = Helpers.getStatusColor(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Helpers.getStatusIcon(booking.status),
                      color: statusColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(booking.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        booking.carImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.background,
                          child: const Icon(Icons.directions_car),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.carName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'User: ${booking.userId.substring(0, 8)}...',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${booking.totalPrice.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(DateFormat('MMM dd').format(booking.pickupDate)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Drop-off',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(DateFormat('MMM dd').format(booking.dropDate)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(booking.paymentMethod),
                        ],
                      ),
                    ),
                  ],
                ),
                if (booking.status == 'pending' ||
                    booking.status == 'confirmed') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (booking.status == 'pending')
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _updateStatus(context, ref, 'confirmed'),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Confirm'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.success,
                              side: const BorderSide(color: AppColors.success),
                            ),
                          ),
                        ),
                      if (booking.status == 'pending')
                        const SizedBox(width: 12),
                      if (booking.status == 'confirmed')
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _updateStatus(context, ref, 'completed'),
                            icon: const Icon(Icons.done_all, size: 18),
                            label: const Text('Complete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.success,
                              side: const BorderSide(color: AppColors.success),
                            ),
                          ),
                        ),
                      if (booking.status == 'confirmed')
                        const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _updateStatus(context, ref, 'cancelled'),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateStatus(BuildContext context, WidgetRef ref, String status) async {
    try {
      await ref
          .read(bookingNotifierProvider.notifier)
          .updateBookingStatus(booking.id, status);
      if (context.mounted) {
        Helpers.showSnackBar(context, 'Status updated to $status');
      }
    } catch (e) {
      if (context.mounted) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }
}
