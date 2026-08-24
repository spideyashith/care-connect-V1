import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ============================================================
  // CURRENT USER
  // ============================================================

  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  String? getCurrentPatientId() {
    return getCurrentUserId();
  }

  // ============================================================
  // SAVE ACTIVITY
  // ============================================================

  Future<void> saveActivity({
    required String patientId,
    required String activityName,
    required String activityTime,
  }) async {
    if (patientId.trim().isEmpty) {
      throw Exception('Patient ID is required.');
    }

    if (activityName.trim().isEmpty) {
      throw Exception('Activity name is required.');
    }

    if (activityTime.trim().isEmpty) {
      throw Exception('Activity time is required.');
    }

    await supabase.from('activities').insert({
      'patient_id': patientId,
      'activity_name': activityName.trim(),
      'activity_time': activityTime.trim(),
      'status': 'pending',
    });
  }

  // ============================================================
  // GET ALL ACTIVITIES FOR SPECIFIC PATIENT
  // ============================================================

  Future<List<dynamic>> getActivitiesForPatient(String patientId) async {
    if (patientId.trim().isEmpty) {
      return [];
    }

    final result = await supabase
        .from('activities')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false);

    return result;
  }

  // ============================================================
  // GET CURRENT PATIENT ACTIVITIES
  // ============================================================

  Future<List<dynamic>> getAllActivities() async {
    final patientId = getCurrentPatientId();

    if (patientId == null) {
      return [];
    }

    return getActivitiesForPatient(patientId);
  }

  // ============================================================
  // GET LATEST ACTIVITY
  // ============================================================

  Future<Map<String, dynamic>?> getLatestActivity() async {
    final patientId = getCurrentPatientId();

    if (patientId == null) {
      return null;
    }

    return await supabase
        .from('activities')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  // ============================================================
  // MARK ACTIVITY COMPLETED
  // ============================================================

  Future<void> markActivityCompleted(dynamic activityId) async {
    final patientId = getCurrentPatientId();

    if (patientId == null) {
      throw Exception('Patient is not logged in.');
    }

    await supabase
        .from('activities')
        .update({
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', activityId)
        .eq('patient_id', patientId);
  }

  // ============================================================
  // GET ACTIVITIES FOR CAREGIVER / OTHER PATIENT
  // ============================================================

  Future<List<dynamic>> getActivitiesForSpecificPatient(
    String patientId,
  ) async {
    return getActivitiesForPatient(patientId);
  }

  // ============================================================
  // GET PENDING ACTIVITIES
  // ============================================================

  Future<List<dynamic>> getPendingActivitiesForPatient(String patientId) async {
    if (patientId.trim().isEmpty) {
      return [];
    }

    return await supabase
        .from('activities')
        .select()
        .eq('patient_id', patientId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);
  }
}
