import 'package:supabase_flutter/supabase_flutter.dart';

class CaregiverConnectionService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> connectPatient(String careCode) async {
    final code = careCode.trim();

    if (code.isEmpty) {
      throw Exception('Enter patient care code.');
    }

    final result = await supabase.rpc(
      'connect_caregiver_to_patient',
      params: {'patient_care_code': code},
    );

    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }

    throw Exception('Unable to connect patient.');
  }

  Future<Map<String, dynamic>?> getConnectedPatient() async {
    final caregiverId = supabase.auth.currentUser?.id;

    if (caregiverId == null) {
      return null;
    }

    final result = await supabase
        .from('caregiver_patients')
        .select('patient_id')
        .eq('caregiver_id', caregiverId)
        .limit(1)
        .maybeSingle();

    if (result == null) {
      return null;
    }

    final patientId = result['patient_id'];

    return await supabase
        .from('profiles')
        .select('id, full_name, role, care_code')
        .eq('id', patientId)
        .maybeSingle();
  }
}
