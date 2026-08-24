import 'package:supabase_flutter/supabase_flutter.dart';

class CaregiverPatientService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ============================================================
  // GET CURRENT CAREGIVER ID
  // ============================================================

  String? getCurrentCaregiverId() {
    return supabase.auth.currentUser?.id;
  }

  // ============================================================
  // GET ASSIGNED PATIENT ID
  // ============================================================

  Future<String?> getAssignedPatientId() async {
    final caregiverId = getCurrentCaregiverId();

    if (caregiverId == null) {
      return null;
    }

    final rows = await supabase
        .from('caregiver_patients')
        .select('patient_id')
        .eq('caregiver_id', caregiverId)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final patientId = rows.first['patient_id'];

    if (patientId == null) {
      return null;
    }

    return patientId.toString();
  }

  // ============================================================
  // GET ASSIGNED PATIENT
  // ============================================================

  Future<Map<String, dynamic>?> getAssignedPatient() async {
    final patientId = await getAssignedPatientId();

    if (patientId == null) {
      return null;
    }

    return await supabase
        .from('profiles')
        .select('id, full_name, role, care_code')
        .eq('id', patientId)
        .eq('role', 'patient')
        .maybeSingle();
  }

  // ============================================================
  // GET CONNECTED PATIENT
  //
  // Kept as an alias because some of your current screens
  // already use getConnectedPatient().
  // ============================================================

  Future<Map<String, dynamic>?> getConnectedPatient() async {
    return getAssignedPatient();
  }

  // ============================================================
  // CHECK WHETHER CAREGIVER HAS A PATIENT
  // ============================================================

  Future<bool> hasAssignedPatient() async {
    final patientId = await getAssignedPatientId();

    return patientId != null;
  }
}
