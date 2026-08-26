import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  factory NotificationService() => instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();

    try {
      final timezone = await FlutterTimezone.getLocalTimezone();

      var timezoneName = timezone.identifier;

      // Some Android devices report the old
      // India timezone name.
      if (timezoneName == 'Asia/Calcutta') {
        timezoneName = 'Asia/Kolkata';
      }

      tz.setLocalLocation(tz.getLocation(timezoneName));

      debugPrint('Notification timezone: $timezoneName');
    } catch (e) {
      debugPrint('Timezone setup failed: $e');

      // Safe fallback for India.
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      } catch (fallbackError) {
        debugPrint('Timezone fallback failed: $fallbackError');
      }
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await plugin.initialize(settings: initializationSettings);

    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final notificationPermission = await androidPlugin
        ?.requestNotificationsPermission();

    debugPrint(
      'Notification permission: '
      '$notificationPermission',
    );

    final exactAlarmPermission = await androidPlugin
        ?.requestExactAlarmsPermission();

    debugPrint(
      'Exact alarm permission: '
      '$exactAlarmPermission',
    );

    const channel = AndroidNotificationChannel(
      'careconnect_tasks',
      'CareConnect Tasks',
      description: 'Notifications for patient daily activities.',
      importance: Importance.max,
      playSound: true,
    );

    await androidPlugin?.createNotificationChannel(channel);

    _initialized = true;

    debugPrint('Notification service initialized.');
  }

  // ============================================================
  // TEST NOTIFICATION
  // ============================================================

  Future<void> showTestNotification() async {
    await initialize();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'careconnect_tasks',
        'CareConnect Tasks',
        channelDescription: 'Notifications for patient daily activities.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await plugin.show(
      id: 999999,
      title: 'CareConnect Test',
      body: 'CareConnect notifications are working.',
      notificationDetails: details,
    );

    debugPrint('Test notification requested.');
  }

  // ============================================================
  // SCHEDULE ACTIVITY REMINDER
  // ============================================================

  Future<void> scheduleActivityReminder({
    required int notificationId,
    required String activityName,
    required String activityTime,
  }) async {
    await initialize();

    final parsedTime = _parseTime(activityTime);

    if (parsedTime == null) {
      debugPrint('Invalid activity time: $activityTime');
      return;
    }

    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      parsedTime.hour,
      parsedTime.minute,
    );

    // If today's scheduled time has already passed,
    // schedule the next daily occurrence.
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'careconnect_tasks',
        'CareConnect Tasks',
        channelDescription: 'Notifications for patient daily activities.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    debugPrint(
      'Scheduling reminder: '
      '$activityName at $scheduled',
    );

    await plugin.zonedSchedule(
      id: notificationId,
      title: 'CareConnect Reminder',
      body: 'Time for: $activityName',
      scheduledDate: scheduled,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: activityName,
    );

    debugPrint('Reminder scheduled successfully.');
  }

  // ============================================================
  // CANCEL ONE REMINDER
  // ============================================================

  Future<void> cancelReminder(int notificationId) async {
    await plugin.cancel(id: notificationId);
  }

  // ============================================================
  // CANCEL ALL REMINDERS
  // ============================================================

  Future<void> cancelAll() async {
    await plugin.cancelAll();
  }

  // ============================================================
  // PARSE TIME
  // Example:
  // 8:30 PM
  // 07:05 AM
  // ============================================================

  TimeOfDayValue? _parseTime(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));

    if (parts.length != 2) {
      return null;
    }

    final hm = parts[0].split(':');

    if (hm.length != 2) {
      return null;
    }

    int? hour = int.tryParse(hm[0]);

    final minute = int.tryParse(hm[1]);

    if (hour == null || minute == null) {
      return null;
    }

    final period = parts[1].toUpperCase();

    if (period != 'AM' && period != 'PM') {
      return null;
    }

    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return TimeOfDayValue(hour: hour, minute: minute);
  }
}

class TimeOfDayValue {
  final int hour;
  final int minute;

  const TimeOfDayValue({required this.hour, required this.minute});
}
