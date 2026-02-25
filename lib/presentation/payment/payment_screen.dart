import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/utils/helpers.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  // Cash is the only active method; it's pre-selected
  String _selectedMethod = 'Cash';
  bool _isLoading = false;

  final _fmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);
    try {
      final userId = ref.read(currentUserProvider).valueOrNull?.uid;
      if (userId == null) throw Exception('Please log in again');

      final bookingState = ref.read(bookingNotifierProvider);
      if (bookingState.carId == null) {
        throw Exception('No car selected. Go back and select a car.');
      }
      if (bookingState.pickupDate == null || bookingState.dropDate == null) {
        throw Exception('Please select pickup and drop-off dates.');
      }
      if (bookingState.pickupLocation == null) {
        throw Exception('Please select a pickup location.');
      }

      ref
          .read(bookingNotifierProvider.notifier)
          .setPaymentMethod(_selectedMethod);
      await ref.read(bookingNotifierProvider.notifier).createBooking(userId);

      if (mounted) context.go(AppRoutes.bookingConfirmation);
    } catch (e) {
      if (mounted) Helpers.showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingNotifierProvider);
    final totalAmount = _fmt.format(bookingState.totalPrice);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text(AppStrings.payment)),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Confirming your booking…',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Order Summary Card ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
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
                    Row(
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Order Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _summaryRow(
                      context,
                      '🚗 Car',
                      bookingState.carName ?? 'N/A',
                    ),
                    _summaryRow(
                      context,
                      '📅 Duration',
                      '${bookingState.totalDays} days',
                    ),
                    _summaryRow(
                      context,
                      '📍 Pickup',
                      bookingState.pickupLocation ?? 'N/A',
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          totalAmount,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Payment Methods ─────────────────────────────────
              Text(
                'Select Payment Method',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Pay when you pick up your car',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Cash on Delivery (active)
              _PaymentMethodTile(
                icon: Icons.money_rounded,
                iconColor: const Color(0xFF4CAF50),
                title: 'Cash on Delivery',
                subtitle: 'Pay cash at the time of pickup',
                isSelected: _selectedMethod == 'Cash',
                isEnabled: true,
                onTap: () => setState(() => _selectedMethod = 'Cash'),
              ),

              const SizedBox(height: 10),

              // UPI (coming soon)
              _PaymentMethodTile(
                icon: Icons.account_balance_rounded,
                iconColor: AppColors.textLight,
                title: 'UPI',
                subtitle: 'GPay, PhonePe, Paytm — coming soon',
                isSelected: false,
                isEnabled: false,
                onTap: null,
                badge: 'Coming Soon',
              ),

              const SizedBox(height: 10),

              // Card (coming soon)
              _PaymentMethodTile(
                icon: Icons.credit_card_rounded,
                iconColor: AppColors.textLight,
                title: 'Credit / Debit Card',
                subtitle: 'Visa, Mastercard, RuPay — coming soon',
                isSelected: false,
                isEnabled: false,
                onTap: null,
                badge: 'Coming Soon',
              ),

              const SizedBox(height: 32),

              // ── Cash info banner ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You\'ll pay $totalAmount in cash when you pick up the car. No upfront charge.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Confirm Button ──────────────────────────────────
              PrimaryButton(
                text: 'Confirm Booking — Pay $totalAmount at Pickup',
                onPressed: _confirmBooking,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.security,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Booking secured by Drive Easy',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Payment Method Tile widget ────────────────────────────────────────────────
class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;
  final String? badge;

  const _PaymentMethodTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.12)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.primary : iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isEnabled
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge or check
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String name;
  final IconData icon;
  final String description;

  PaymentMethod({
    required this.name,
    required this.icon,
    required this.description,
  });
}
