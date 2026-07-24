import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SafeZoneService {
  final supabase = Supabase.instance.client;

  Future<void> saveHomeLocation({
    required String patientId,
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    try {
      print("Deleting old safe zone...");

      await supabase.from('safe_zones').delete().eq('patient_id', patientId);

      print("Saving new safe zone...");

      await supabase.from('safe_zones').insert({
        'patient_id': patientId,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      });

      print("✅ Safe Zone Saved");
    } catch (e) {
      print("❌ ERROR");
      print(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getSafeZone(String patientId) async {
    try {
      final response = await supabase
          .from('safe_zones')
          .select()
          .eq('patient_id', patientId)
          .single();

      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }

  bool isOutsideSafeZone({
    required double patientLat,
    required double patientLng,
    required double homeLat,
    required double homeLng,
    required int radius,
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
