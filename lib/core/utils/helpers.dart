import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class Helpers {
  static void showToast(String message, {bool isError = false}) {
    // Only show toasts for errors
    if (!isError) return;
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFFFF3B30),
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  /// Shows a professional error snackbar. Non-error calls are silently ignored.
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    SnackBarAction? action,
  }) {
    // ── Only display for actual errors ─────────────────────────────────────
    if (!isError) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          duration: const Duration(seconds: 5),
          content: _ErrorSnackBarContent(message: message, action: action),
        ),
      );
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatPrice(double price) {
    return '₹${price.toStringAsFixed(0)}';
  }

  static int calculateDays(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  static double calculateTotalPrice(double pricePerDay, int days) {
    return pricePerDay * days;
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'confirmed':
        return AppColors.confirmed;
      case 'cancelled':
        return AppColors.cancelled;
      case 'completed':
        return AppColors.completed;
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.verified;
      default:
        return Icons.info;
    }
  }

  static String getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return '💳';
      case 'card':
        return '💳';
      case 'cash':
        return '💵';
      default:
        return '💰';
    }
  }
}

// ── Premium Error Snackbar UI ──────────────────────────────────────────────

class _ErrorSnackBarContent extends StatelessWidget {
  final String message;
  final SnackBarAction? action;

  const _ErrorSnackBarContent({required this.message, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // Deep dark background
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3B30).withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Red accent bar on the left
              Container(width: 4, color: const Color(0xFFFF3B30)),
              const SizedBox(width: 14),
              // Error icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_rounded,
                  color: Color(0xFFFF3B30),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Message
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Error',
                        style: TextStyle(
                          color: Color(0xFFFF3B30),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFFEAEAEA),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Dismiss button
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(
                    Icons.close_rounded,
                    color: Color(0xFF636366),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
