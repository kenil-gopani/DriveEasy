import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/notification_service.dart';

/// Demonstrates local notifications: immediate and scheduled (5-second delay).
class NotificationsDemoScreen extends StatefulWidget {
  const NotificationsDemoScreen({super.key});

  @override
  State<NotificationsDemoScreen> createState() =>
      _NotificationsDemoScreenState();
}

class _NotificationsDemoScreenState extends State<NotificationsDemoScreen> {
  bool _scheduledPending = false;
  int _scheduledCountdown = 5;

  // ── Countdown timer for visual feedback ─────────────────────────────────
  void _startCountdown() {
    setState(() {
      _scheduledPending = true;
      _scheduledCountdown = 5;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _scheduledCountdown--);
      if (_scheduledCountdown <= 0) {
        setState(() => _scheduledPending = false);
        return false;
      }
      return true;
    });
  }

  Future<void> _sendNow() async {
    await NotificationService.showImmediate(
      id: 10,
      title: '🚗 DriveEasy',
      body: 'Your booking is confirmed! Enjoy your ride.',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text('Notification sent!'),
          ],
        ),
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _scheduleIn5s() async {
    await NotificationService.scheduleReminder(
      id: 11,
      title: '⏰ DriveEasy Reminder',
      body: 'Check your tasks! Your rental starts soon. 🚗',
      delaySeconds: 5,
    );
    _startCountdown();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Reminder scheduled for 5 seconds — try backgrounding the app!',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Notification Demo')),
      body: kIsWeb ? _buildWebNotSupported() : _buildContent(),
    );
  }

  // ── Web not-supported screen ─────────────────────────────────────────────
  Widget _buildWebNotSupported() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone_android_rounded,
                size: 56,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mobile Only Feature',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Local notifications are not supported on the web.\n'
              'Run the app on an Android or iOS device to test this feature.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All notification code (service, permissions, scheduling) '
                      'is fully implemented and will work on a physical device.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main notification demo content ─────────────────────────────────────────────
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Info card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Local Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Send instant or scheduled reminders even when the app is in the background.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          _buildSectionLabel('Immediate Notification'),
          const SizedBox(height: 12),

          // ── Send Now ──────────────────────────────────────
          _buildActionCard(
            icon: Icons.send_rounded,
            iconColor: AppColors.primary,
            title: 'Send Now',
            subtitle: 'Fires a notification right away',
            onTap: _sendNow,
            buttonLabel: 'Send Notification',
            buttonColor: AppColors.primary,
          ),

          const SizedBox(height: 24),
          _buildSectionLabel('Scheduled Notification'),
          const SizedBox(height: 12),

          // ── Schedule in 5s ────────────────────────────────
          _buildActionCard(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.accent,
            title: 'Schedule in 5 Seconds',
            subtitle: _scheduledPending
                ? 'Firing in $_scheduledCountdown second${_scheduledCountdown == 1 ? '' : 's'}…'
                : 'Background the app after scheduling to see it arrive',
            onTap: _scheduledPending ? null : _scheduleIn5s,
            buttonLabel: _scheduledPending
                ? 'Pending… ($_scheduledCountdown s)'
                : 'Schedule Reminder',
            buttonColor: AppColors.accent,
            isLoading: _scheduledPending,
          ),

          const SizedBox(height: 32),

          // ── Tips ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTip(
                  'Background the app after scheduling to test background delivery',
                ),
                _buildTip('Allow notification permission when prompted'),
                _buildTip('On Android 13+, grant POST_NOTIFICATIONS if asked'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required String buttonLabel,
    required Color buttonColor,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: buttonColor.withValues(alpha: 0.5),
              ),
              child: isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          buttonLabel,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  : Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
