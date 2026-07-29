import 'package:supabase_flutter/supabase_flutter.dart';

class CaregiverService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getLatestLocation() async {
    return await supabase
        .from('patient_locations')
        .select()
        .order('id', ascending: false)
        .limit(1)
        .single();
  }

  Future<Map<String, dynamic>?> getLatestAlert() async {
    try {
      return await supabase
          .from('emergency_alerts')
          .select()
          .order('id', ascending: false)
          .limit(1)
          .single();
    } catch (_) {
      return null;
    }
  }

  Future<List<dynamic>> getActivities() async {
    return await supabase
        .from('activities')
        .select()
        .order('id', ascending: false);
  }
}
