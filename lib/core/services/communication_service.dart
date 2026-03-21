import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/helpers.dart';

/// A utility service for launching native device communication features:
/// phone calls, SMS, and email.
class CommunicationService {
  CommunicationService._(); // Prevent instantiation

  // ─── Contact details (replace with real data as needed) ──────────────────
  static const String supportPhone = '+919876543210';
  static const String supportEmail = 'support@driveasy.com';

  // ─── Phone Call ──────────────────────────────────────────────────────────

  /// Launches the native phone dialer with [phoneNumber] pre-filled.
  static Future<void> launchCall(
    BuildContext context,
    String phoneNumber,
  ) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    final canLaunch = await canLaunchUrl(uri);
    if (!context.mounted) return;
    if (canLaunch) {
      await launchUrl(uri);
    } else {
      _showError(context, 'Could not open the phone dialer.');
    }
  }

  // ─── SMS ─────────────────────────────────────────────────────────────────

  /// Launches the native SMS app addressed to [phoneNumber].
  /// Optionally pre-fills [body] as the message text.
  static Future<void> launchSms(
    BuildContext context,
    String phoneNumber, {
    String body = '',
  }) async {
    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: body.isNotEmpty ? {'body': body} : null,
    );
    final canLaunch = await canLaunchUrl(uri);
    if (!context.mounted) return;
    if (canLaunch) {
      await launchUrl(uri);
    } else {
      _showError(context, 'Could not open the SMS app.');
    }
  }

  // ─── Email ───────────────────────────────────────────────────────────────

  /// Launches the default email client with [to], [subject], and [body].
  static Future<void> launchEmail(
    BuildContext context, {
    required String to,
    String subject = '',
    String body = '',
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        if (subject.isNotEmpty) 'subject': subject,
        if (body.isNotEmpty) 'body': body,
      },
    );
    final canLaunch = await canLaunchUrl(uri);
    if (!context.mounted) return;
    if (canLaunch) {
      await launchUrl(uri);
    } else {
      _showError(context, 'Could not open the email client.');
    }
  }

  // ─── Helper ──────────────────────────────────────────────────────────────

  static void _showError(BuildContext context, String message) {
    Helpers.showSnackBar(context, message, isError: true);
  }
}
