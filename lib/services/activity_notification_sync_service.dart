import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';

class ActivityNotificationSyncService {
  final SupabaseClient supabase = Supabase.instance.client;

  final NotificationService notificationService = NotificationService();

  RealtimeChannel? _channel;
  Timer? _pollTimer;

  bool _started = false;

  Future<void> start() async {
    if (_started) {
      return;
    }

    final patientId = supabase.auth.currentUser?.id;

    if (patientId == null) {
      debugPrint('Notification sync not started: patient not logged in.');
      return;
    }

    _started = true;

    await notificationService.initialize();

    // Schedule activities that already exist.
    await syncPendingActivities(patientId);

    // Listen for newly-created activities.
    _channel = supabase
        .channel('patient-activity-sync-$patientId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'activities',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'patient_id',
            value: patientId,
          ),
          callback: (payload) async {
            try {
              final activity = payload.newRecord;

              await scheduleActivity(activity);
            } catch (e) {
              debugPrint('Realtime activity scheduling error: $e');
            }
          },
        )
        .subscribe();

    // Fallback polling.
    //
    // This helps when Realtime isn't connected
    // or is temporarily unavailable.
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      try {
        await syncPendingActivities(patientId);
      } catch (e) {
        debugPrint('Activity sync error: $e');
      }
    });
  }

  Future<void> syncPendingActivities(String patientId) async {
    final activities = await supabase
        .from('activities')
        .select()
        .eq('patient_id', patientId)
        .eq('status', 'pending');

    for (final activity in activities) {
      await scheduleActivity(Map<String, dynamic>.from(activity));
    }
  }

  Future<void> scheduleActivity(Map<String, dynamic> activity) async {
    final id = activity['id'];

    final activityName = activity['activity_name'];

    final activityTime = activity['activity_time'];

    final status = activity['status'];

    if (id == null || activityName == null || activityTime == null) {
      return;
    }

    if (status == 'completed') {
      return;
    }

    final notificationId = _notificationId(id);

    await notificationService.scheduleActivityReminder(
      notificationId: notificationId,
      activityName: activityName.toString(),
      activityTime: activityTime.toString(),
    );

    debugPrint(
      'Reminder scheduled: '
      '$activityName at $activityTime',
    );
  }

  Future<void> cancelActivity(dynamic activityId) async {
    await notificationService.cancelReminder(_notificationId(activityId));
  }

  int _notificationId(dynamic activityId) {
    if (activityId is int) {
      return activityId;
    }

    return activityId.toString().hashCode.abs();
  }

  Future<void> stop() async {
    _pollTimer?.cancel();
    _pollTimer = null;

    if (_channel != null) {
      await supabase.removeChannel(_channel!);
      _channel = null;
    }

    _started = false;
  }
}
