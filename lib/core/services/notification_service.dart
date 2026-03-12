import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Handles initialization, immediate, and scheduled local notifications.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'driveasy_reminders';
  static const _channelName = 'DriveEasy Reminders';
  static const _channelDesc = 'Booking and task reminders from DriveEasy';

  // ── Initialization ──────────────────────────────────────────────────────

  static Future<void> initialize() async {
    // flutter_local_notifications is not supported on web
    if (kIsWeb) return;

    // Initialize timezone database
    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Request Android 13+ POST_NOTIFICATIONS permission at runtime
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // ── Notification details ─────────────────────────────────────────────────

  static NotificationDetails get _details => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  // ── Public API ───────────────────────────────────────────────────────────

  /// Shows an immediate local notification.
  static Future<void> showImmediate({
    int id = 0,
    String title = 'DriveEasy',
    String body = 'You have a new update!',
  }) async {
    if (kIsWeb) return; // not supported on web
    await _plugin.show(id, title, body, _details);
  }

  /// Shows a notification after [delaySeconds] seconds.
  static Future<void> scheduleReminder({
    int id = 1,
    String title = 'DriveEasy Reminder',
    String body = 'Check your car booking! 🚗',
    int delaySeconds = 5,
  }) async {
    if (kIsWeb) return; // not supported on web
    final scheduledTime = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(seconds: delaySeconds));

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancels all scheduled notifications.
  static Future<void> cancelAll() => _plugin.cancelAll();
}
