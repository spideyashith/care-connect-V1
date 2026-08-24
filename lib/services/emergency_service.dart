import 'package:supabase_flutter/supabase_flutter.dart';

class EmergencyService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ============================================================
  // SEND EMERGENCY ALERT
  // ============================================================

  Future<void> sendEmergencyAlert({
    required String patientId,
    String message = 'Emergency button pressed',
    double? latitude,
    double? longitude,
  }) async {
    await supabase.from('emergency_alerts').insert({
      'patient_id': patientId,
      'alert_status': 'triggered',
      'alert_time': DateTime.now().toIso8601String(),
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  // ============================================================
  // SEND SOS FOR CURRENT LOGGED-IN PATIENT
  // ============================================================

  Future<void> sendCurrentUserEmergencyAlert({
    String message = 'Emergency button pressed by patient.',
    double? latitude,
    double? longitude,
  }) async {
    final patientId = supabase.auth.currentUser?.id;

    if (patientId == null) {
      throw Exception('No authenticated patient found.');
    }

    await sendEmergencyAlert(
      patientId: patientId,
      message: message,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // ============================================================
  // SAFE ZONE ALERT
  // ============================================================

  Future<void> sendSafeZoneAlert({
    required String patientId,
    double? latitude,
    double? longitude,
  }) async {
    await sendEmergencyAlert(
      patientId: patientId,
      message: 'Patient left the safe zone.',
      latitude: latitude,
      longitude: longitude,
    );
  }

  // ============================================================
  // GET PATIENT ALERTS
  // ============================================================

  Future<List<dynamic>> getAlertsForPatient(String patientId) async {
    return await supabase
        .from('emergency_alerts')
        .select()
        .eq('patient_id', patientId)
        .order('alert_time', ascending: false);
  }
}
