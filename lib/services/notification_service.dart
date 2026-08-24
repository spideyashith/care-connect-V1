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

      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (e) {
      debugPrint('Timezone setup failed: $e');
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

    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.requestExactAlarmsPermission();

    const channel = AndroidNotificationChannel(
      'careconnect_tasks',
      'CareConnect Tasks',
      description: 'Notifications for patient daily activities.',
      importance: Importance.max,
    );

    await androidPlugin?.createNotificationChannel(channel);

    _initialized = true;
  }

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

    // If today's time has passed,
    // schedule the next occurrence tomorrow.
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'careconnect_tasks',
        'CareConnect Tasks',
        channelDescription: 'Patient activity reminders.',
        importance: Importance.max,
        priority: Priority.high,
      ),
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

    debugPrint(
      'Reminder scheduled: '
      '$activityName at $scheduled',
    );
  }

  Future<void> cancelReminder(int notificationId) async {
    await plugin.cancel(id: notificationId);
  }

  Future<void> cancelAll() async {
    await plugin.cancelAll();
  }

  TimeOfDayValue? _parseTime(String value) {
    final parts = value.trim().split(' ');

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
