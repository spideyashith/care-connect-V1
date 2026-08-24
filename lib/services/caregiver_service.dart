import 'package:supabase_flutter/supabase_flutter.dart';

import 'caregiver_connection_service.dart';

class CaregiverService {
  final SupabaseClient supabase = Supabase.instance.client;

  final CaregiverConnectionService connectionService =
      CaregiverConnectionService();

  // ============================================================
  // CONNECTED PATIENT
  // ============================================================

  Future<Map<String, dynamic>?> getConnectedPatient() async {
    return await connectionService.getConnectedPatient();
  }

  Future<String?> getPatientId() async {
    final patient = await connectionService.getConnectedPatient();

    return patient?['id']?.toString();
  }

  // ============================================================
  // PATIENT LOCATION
  // ============================================================

  Future<Map<String, dynamic>?> getLatestLocation() async {
    final patientId = await getPatientId();

    if (patientId == null) {
      return null;
    }

    return await supabase
        .from('patient_locations')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  // ============================================================
  // PATIENT HOME
  // ============================================================

  Future<Map<String, dynamic>?> getHomeLocation() async {
    final patientId = await getPatientId();

    if (patientId == null) {
      return null;
    }

    return await supabase
        .from('patient_home')
        .select()
        .eq('patient_id', patientId)
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  // ============================================================
  // SAFE ZONE
  // ============================================================

  Future<Map<String, dynamic>?> getSafeZone() async {
    final patientId = await getPatientId();

    if (patientId == null) {
      return null;
    }

    return await supabase
        .from('safe_zones')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  // ============================================================
  // LATEST ALERT
  // ============================================================

  Future<Map<String, dynamic>?> getLatestAlert() async {
    final patientId = await getPatientId();

    if (patientId == null) {
      return null;
    }

    return await supabase
        .from('emergency_alerts')
        .select()
        .eq('patient_id', patientId)
        .order('alert_time', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  // ============================================================
  // ACTIVITIES
  // ============================================================

  Future<List<dynamic>> getActivities() async {
    final patientId = await getPatientId();

    if (patientId == null) {
      return [];
    }

    return await supabase
        .from('activities')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false);
  }

  // ============================================================
  // PATIENT PROFILE
  // ============================================================

  Future<Map<String, dynamic>?> getPatientProfile() async {
    return await connectionService.getConnectedPatient();
  }

  // ============================================================
  // REALTIME EMERGENCY ALERTS
  // ============================================================

  RealtimeChannel? subscribeToEmergencyAlerts({
    required String patientId,
    required void Function(Map<String, dynamic> alert) onAlert,
  }) {
    final channel = supabase
        .channel('caregiver-alerts-$patientId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'emergency_alerts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'patient_id',
            value: patientId,
          ),
          callback: (payload) {
            final alert = Map<String, dynamic>.from(payload.newRecord);

            onAlert(alert);
          },
        )
        .subscribe();

    return channel;
  }

  Future<void> unsubscribe(RealtimeChannel? channel) async {
    if (channel != null) {
      await supabase.removeChannel(channel);
    }
  }
}
