import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  String? _selectedMethod;
  bool _isLoading = false;

  final List<PaymentMethod> _methods = [
    PaymentMethod(
      name: 'UPI',
      icon: Icons.account_balance,
      description: 'Pay using UPI apps',
    ),
    PaymentMethod(
      name: 'Card',
      icon: Icons.credit_card,
      description: 'Credit or Debit Card',
    ),
    PaymentMethod(
      name: 'Cash',
      icon: Icons.money,
      description: 'Pay at pickup',
    ),
  ];

  Future<void> _processPayment() async {
    if (_selectedMethod == null) {
      Helpers.showSnackBar(
        context,
        'Please select a payment method',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(currentUserProvider).valueOrNull?.uid;
      if (userId == null) throw Exception('Please login again');

      final bookingState = ref.read(bookingNotifierProvider);

      // Validate booking state
      if (bookingState.carId == null) {
        throw Exception('No car selected. Please go back and select a car.');
      }
      if (bookingState.pickupDate == null || bookingState.dropDate == null) {
        throw Exception('Please select pickup and drop-off dates.');
      }
      if (bookingState.pickupLocation == null) {
        throw Exception('Please select a pickup location.');
      }

      ref
          .read(bookingNotifierProvider.notifier)
          .setPaymentMethod(_selectedMethod!);

      await ref.read(bookingNotifierProvider.notifier).createBooking(userId);

      if (mounted) {
        context.go(AppRoutes.bookingConfirmation);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text(AppStrings.payment)),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Processing payment...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow('Car', bookingState.carName ?? 'N/A'),
                    _buildSummaryRow(
                      'Duration',
                      '${bookingState.totalDays} days',
                    ),
                    _buildSummaryRow(
                      'Pickup',
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
                          '\$${bookingState.totalPrice.toStringAsFixed(2)}',
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
              const SizedBox(height: 32),
              // Payment methods
              Text(
                AppStrings.selectPaymentMethod,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...(_methods.map((method) => _buildPaymentMethodCard(method))),
              const SizedBox(height: 32),
              // Pay button
              PrimaryButton(
                text: 'Pay \$${bookingState.totalPrice.toStringAsFixed(2)}',
                onPressed: _selectedMethod != null ? _processPayment : null,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              // Security note
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.security,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Secure payment powered by Drive Easy',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = _selectedMethod == method.name;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMethod = method.name);
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
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                method.icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    method.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
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
