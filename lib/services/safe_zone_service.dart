import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SafeZoneService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> saveSafeZone({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    final patientId = supabase.auth.currentUser?.id;

    if (patientId == null) {
      throw Exception('Patient is not logged in.');
    }

    await supabase.from('safe_zones').delete().eq('patient_id', patientId);

    await supabase.from('safe_zones').insert({
      'patient_id': patientId,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    });
  }

  Future<Map<String, dynamic>?> getSafeZone(String patientId) async {
    return await supabase
        .from('safe_zones')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  bool isOutsideSafeZone({
    required double patientLat,
    required double patientLng,
    required double homeLat,
    required double homeLng,
    required double radius,
  }) {
    final distance = Geolocator.distanceBetween(
      homeLat,
      homeLng,
      patientLat,
      patientLng,
    );

    return distance > radius;
  }
}
