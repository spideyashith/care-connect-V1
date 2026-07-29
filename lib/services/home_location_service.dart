import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeLocationService {
  final supabase = Supabase.instance.client;

  Future<void> saveHomeLocation({
    required String patientId,
    required double latitude,
    required double longitude,
  }) async {
    await supabase.from('patient_home').insert({
      'patient_id': patientId,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<Map<String, dynamic>?> getHomeLocation() async {
    final result = await supabase
        .from('patient_home')
        .select()
        .order('id', ascending: false)
        .limit(1)
        .single();

    return result;
  }

  Future<bool> isOutsideSafeZone({
    required double currentLatitude,
    required double currentLongitude,
  }) async {
    final home = await getHomeLocation();

    if (home == null) return false;

    final distance = Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      home['latitude'],
      home['longitude'],
    );

    return distance > 500;
  }
}
