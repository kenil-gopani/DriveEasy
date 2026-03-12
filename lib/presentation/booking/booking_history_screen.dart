import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/car_loading_widget.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/booking_model.dart';
import '../providers/booking_provider.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  String _selectedTab = 'Upcoming';

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(userBookingsProvider);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bookings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Segmented Controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _buildTab('Upcoming'),
                  _buildTab('Completed'),
                  _buildTab('Cancelled'),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: bookingsAsync.when(
              data: (bookings) {
                List<BookingModel> filteredBookings = [];
                if (_selectedTab == 'Upcoming') {
                  filteredBookings = bookings.where((b) {
                    final drop = DateTime(b.dropDate.year, b.dropDate.month, b.dropDate.day);
                    return b.status != 'cancelled' && !drop.isBefore(todayDate);
                  }).toList();
                } else if (_selectedTab == 'Completed') {
                  filteredBookings = bookings.where((b) {
                    final drop = DateTime(b.dropDate.year, b.dropDate.month, b.dropDate.day);
                    return b.status != 'cancelled' && drop.isBefore(todayDate);
                  }).toList();
                } else {
                  filteredBookings = bookings.where((b) => b.status == 'cancelled').toList();
                }

                if (filteredBookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 48,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No $_selectedTab Bookings',
                          style: const TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your bookings will appear here.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, i) {
                    return BookingCard(booking: filteredBookings[i], tab: _selectedTab);
                  },
                );
              },
              loading: () => const Center(child: CarLoadingWidget()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected 
                ? [BoxShadow(color: AppColors.shadowLight, blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Public Booking Card ───────────────────────────────────────────────────────
class BookingCard extends ConsumerWidget {
  final BookingModel booking;
  final String tab;
  
  const BookingCard({super.key, required this.booking, required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = booking.status == 'pending';
    final canCancel = booking.status == 'pending' || booking.status == 'confirmed';
    
    // Status Text and Color based on Tab/Status
    String statusText = 'Confirmed';
    Color statusBgColor = const Color(0xFFD1FAE5); // Emerald 100
    Color statusTextColor = const Color(0xFF047857); // Emerald 700
    
    if (tab == 'Completed') {
      statusText = 'Completed';
    } else if (tab == 'Cancelled') {
      statusText = 'Cancelled';
      statusBgColor = const Color(0xFFFEE2E2); // Red 100
      statusTextColor = const Color(0xFFB91C1C); // Red 700
    } else if (booking.status == 'pending') {
      statusText = 'Pending';
      statusBgColor = const Color(0xFFFEF3C7); // Amber 100
      statusTextColor = const Color(0xFFB45309); // Amber 700
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Image
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    imageUrl: booking.carImage,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Icon(Icons.directions_car, color: AppColors.textLight),
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 60), // Room for pill
                        child: Text(
                          booking.carName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${DateFormat('MMM dd').format(booking.pickupDate)} - ${DateFormat('MMM dd').format(booking.dropDate)} • ${booking.totalDays} Days',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${booking.totalPrice.toStringAsFixed(0)} Total',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Absolute Positioned Pill (Simulated with transform or just stack it up)
          // Wait, I can't absolutely position outside a stack easily if I want it exactly in top right.
          // Since it's inside the column, I will just stack the whole card content, but it's easier to just overlay.
          
          // Actions Footer
          if ((tab == 'Upcoming' && (canEdit || canCancel)) || booking.status == 'pending')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  if (canEdit)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => EditBookingSheet(booking: booking),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)), // Slate 300
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (canEdit && canCancel) const SizedBox(width: 12),
                  if (canCancel)
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                           final confirmed = await AppDialog.danger(
                            context,
                            title: 'Cancel Booking',
                            message: 'Cancel your booking for ${booking.carName}?',
                            confirmText: 'Yes, Cancel',
                            cancelText: 'Keep Booking',
                            icon: Icons.cancel_outlined,
                          );
                          if (confirmed && context.mounted) {
                            await ref.read(bookingNotifierProvider.notifier).cancelBooking(booking.id);
                            if (context.mounted) {
                              Helpers.showSnackBar(context, 'Booking cancelled');
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFECACA)), // Red 200
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFDC2626), // Red 600
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ).wrapWithStackPosition(
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusTextColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension StackWrapper on Widget {
  Widget wrapWithStackPosition(Positioned position) {
    return Stack(
      children: [
        this,
        position,
      ],
    );
  }
}


// ─── Public Edit Booking Bottom Sheet ──────────────────────────────────────────
class EditBookingSheet extends ConsumerStatefulWidget {
  final BookingModel booking;
  const EditBookingSheet({super.key, required this.booking});

  @override
  ConsumerState<EditBookingSheet> createState() => _EditBookingSheetState();
}

class _EditBookingSheetState extends ConsumerState<EditBookingSheet> {
  late DateTime _pickupDate;
  late DateTime _dropDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _pickupDate = widget.booking.pickupDate;
    _dropDate = widget.booking.dropDate;
  }

  int get _totalDays => _dropDate.difference(_pickupDate).inDays + 1;
  double get _pricePerDay => widget.booking.totalPrice / widget.booking.totalDays;
  double get _newTotal => _pricePerDay * _totalDays;

  Future<void> _pickDate(bool isPickup) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isPickup ? _pickupDate : _dropDate,
      firstDate: isPickup ? DateTime.now() : _pickupDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isPickup) {
        _pickupDate = picked;
        if (_dropDate.isBefore(picked.add(const Duration(days: 1)))) {
          _dropDate = picked.add(const Duration(days: 1));
        }
      } else {
        _dropDate = picked;
      }
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(bookingNotifierProvider.notifier).updateBooking(
            widget.booking.id,
            pickupDate: _pickupDate,
            dropDate: _dropDate,
            pickupLocation: widget.booking.pickupLocation,
            pricePerDay: _pricePerDay,
          );
      if (mounted) {
        Navigator.pop(context);
        Helpers.showSnackBar(context, 'Booking updated successfully ✓');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to update: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM dd, yyyy');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Edit Booking',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.booking.carName,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 32),

          // Dates row
          Row(
            children: [
              Expanded(
                child: BookingDateTile(
                  label: 'Pickup Date',
                  date: fmt.format(_pickupDate),
                  onTap: () => _pickDate(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BookingDateTile(
                  label: 'Return Date',
                  date: fmt.format(_dropDate),
                  onTap: () => _pickDate(false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Updated price preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_totalDays days × \$${_pricePerDay.toStringAsFixed(0)}/day',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '\$${_newTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Save button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, 
                shadowColor: Colors.transparent,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Public Date Tile ─────────────────────────────────────────────────────────
class BookingDateTile extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const BookingDateTile({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
               date,
               style: const TextStyle(
                 color: AppColors.textPrimary,
                 fontWeight: FontWeight.bold,
                 fontSize: 15,
               ),
               overflow: TextOverflow.ellipsis,
             ),
          ],
        ),
      ),
    );
  }
}
