import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<dynamic>> getPatients() async {
    return await supabase
        .from('profiles')
        .select('id, full_name, role, care_code, created_at')
        .eq('role', 'patient')
        .order('full_name', ascending: true);
  }

  Future<Map<String, dynamic>?> getPatient(String patientId) async {
    return await supabase
        .from('profiles')
        .select('id, full_name, role, care_code, created_at')
        .eq('id', patientId)
        .eq('role', 'patient')
        .maybeSingle();
  }

  Future<List<dynamic>> getPatientActivities(String patientId) async {
    return await supabase
        .from('activities')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false);
  }

  Future<List<dynamic>> getPatientAlerts(String patientId) async {
    return await supabase
        .from('emergency_alerts')
        .select()
        .eq('patient_id', patientId)
        .order('alert_time', ascending: false);
  }

  Future<Map<String, dynamic>?> getLatestLocation(String patientId) async {
    return await supabase
        .from('patient_locations')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> getPatientHome(String patientId) async {
    return await supabase
        .from('patient_home')
        .select()
        .eq('patient_id', patientId)
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> getPatientSafeZone(String patientId) async {
    return await supabase
        .from('safe_zones')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }
}
