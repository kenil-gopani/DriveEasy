import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/utils/helpers.dart';
import '../providers/booking_provider.dart';
import '../providers/car_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _pickupDate;
  DateTime? _dropDate;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _pickupDate = DateTime.now().add(const Duration(days: 1));
    _dropDate = DateTime.now().add(const Duration(days: 3));

    // Set initial dates in booking provider after frame completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pickupDate != null && _dropDate != null) {
        ref
            .read(bookingNotifierProvider.notifier)
            .setDates(pickupDate: _pickupDate!, dropDate: _dropDate!);
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isPickup) async {
    final initialDate = isPickup ? _pickupDate : _dropDate;
    final firstDate = isPickup
        ? DateTime.now()
        : (_pickupDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isPickup) {
          _pickupDate = picked;
          if (_dropDate != null && _dropDate!.isBefore(picked)) {
            _dropDate = picked.add(const Duration(days: 1));
          }
        } else {
          _dropDate = picked;
        }
      });

      if (_pickupDate != null && _dropDate != null) {
        ref
            .read(bookingNotifierProvider.notifier)
            .setDates(pickupDate: _pickupDate!, dropDate: _dropDate!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingNotifierProvider);
    final carAsync = ref.watch(carByIdProvider(bookingState.carId ?? ''));

    if (bookingState.carId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.booking)),
        body: const Center(child: Text('No car selected')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text(AppStrings.booking)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car summary card
            Container(
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
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      bookingState.carImage ?? '',
                      width: 80,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 60,
                        color: AppColors.background,
                        child: const Icon(Icons.directions_car),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookingState.carName ?? 'Car',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${bookingState.pricePerDay?.toStringAsFixed(0) ?? '0'}/day',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Date selection
            Text(
              AppStrings.selectDates,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateCard(
                    label: AppStrings.pickupDate,
                    date: _pickupDate,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateCard(
                    label: AppStrings.dropoffDate,
                    date: _dropDate,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Pickup location
            Text(
              AppStrings.pickupLocation,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            carAsync.when(
              data: (car) {
                if (car == null || car.pickupLocations.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text('No pickup locations available'),
                  );
                }
                return Column(
                  children: car.pickupLocations.map((location) {
                    final isSelected = _selectedLocation == location;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedLocation = location);
                        ref
                            .read(bookingNotifierProvider.notifier)
                            .setPickupLocation(location);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textLight,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(location)),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error loading locations'),
            ),
            const SizedBox(height: 24),
            // Price summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPriceRow(
                    AppStrings.totalDays,
                    '${bookingState.totalDays} days',
                  ),
                  const Divider(height: 24),
                  _buildPriceRow(
                    'Price per day',
                    '\$${bookingState.pricePerDay?.toStringAsFixed(0) ?? '0'}',
                  ),
                  const Divider(height: 24),
                  _buildPriceRow(
                    AppStrings.totalPrice,
                    '\$${bookingState.totalPrice.toStringAsFixed(0)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Continue button
            PrimaryButton(
              text: AppStrings.continueText,
              onPressed: _canContinue()
                  ? () => context.push(AppRoutes.payment)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  bool _canContinue() {
    return _pickupDate != null &&
        _dropDate != null &&
        _selectedLocation != null;
  }

  Widget _buildDateCard({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? DateFormat('MMM dd, yyyy').format(date)
                      : 'Select',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                )
              : Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
