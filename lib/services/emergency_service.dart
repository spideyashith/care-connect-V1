import 'package:supabase_flutter/supabase_flutter.dart';

class EmergencyService {
  final supabase = Supabase.instance.client;

  Future<void> sendEmergencyAlert({
    required String patientId,
    String message = "Emergency button pressed",
    double? latitude,
    double? longitude,
  }) async {
    try {
      await supabase.from('emergency_alerts').insert({
        'patient_id': patientId,
        'alert_status': 'triggered',
        'alert_time': DateTime.now().toIso8601String(),
        'message': message,
        'latitude': latitude,
        'longitude': longitude,
      });

      print("✅ Emergency Saved");
    } catch (e) {
      print("❌ Emergency Error");
      print(e);
    }
  }


  Future<List<dynamic>> getAlerts() async {
    return await supabase
        .from('emergency_alerts')
        .select()
        .order('created_at', ascending: false);
  }
}