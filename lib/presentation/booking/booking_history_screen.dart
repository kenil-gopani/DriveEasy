import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/booking_model.dart';
import '../providers/booking_provider.dart';

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text(AppStrings.bookingHistory)),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return EmptyState(
              icon: Icons.calendar_today_outlined,
              title: AppStrings.noBookings,
              subtitle: 'Start booking cars to see them here',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _BookingCard(booking: bookings[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = Helpers.getStatusColor(booking.status);
    final statusIcon = Helpers.getStatusIcon(booking.status);

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
          // Car image and status
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  booking.carImage,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: AppColors.background,
                    child: const Icon(Icons.directions_car, size: 60),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        booking.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Booking details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.carName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.calendar_today,
                  '${DateFormat('MMM dd').format(booking.pickupDate)} - ${DateFormat('MMM dd, yyyy').format(booking.dropDate)}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on, booking.pickupLocation),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.payment, booking.paymentMethod),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${booking.totalDays} days',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '₹${booking.totalPrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    if (booking.status == 'pending')
                      OutlinedButton.icon(
                        onPressed: () => _cancelBooking(context, ref),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Future<void> _cancelBooking(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.danger(
      context,
      title: 'Cancel Booking',
      message:
          'Are you sure you want to cancel your booking for ${booking.carName}? This cannot be undone.',
      confirmText: 'Yes, Cancel',
      cancelText: 'Keep Booking',
      icon: Icons.cancel_outlined,
    );
    if (confirmed && context.mounted) {
      await ref
          .read(bookingNotifierProvider.notifier)
          .cancelBooking(booking.id);
      if (context.mounted) {
        Helpers.showSnackBar(context, 'Booking cancelled successfully');
      }
    }
  }
}
