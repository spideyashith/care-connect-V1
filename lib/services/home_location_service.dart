import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeLocationService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String?> getCurrentPatientId() async {
    return supabase.auth.currentUser?.id;
  }

  Future<void> saveHomeLocation({
    required double latitude,
    required double longitude,
  }) async {
    final patientId = await getCurrentPatientId();

    if (patientId == null) {
      throw Exception('Patient is not logged in.');
    }

    // Keep only the latest home location.
    await supabase.from('patient_home').delete().eq('patient_id', patientId);

    await supabase.from('patient_home').insert({
      'patient_id': patientId,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<Map<String, dynamic>?> getHomeLocation([String? patientId]) async {
    final id = patientId ?? await getCurrentPatientId();

    if (id == null) {
      return null;
    }

    return await supabase
        .from('patient_home')
        .select()
        .eq('patient_id', id)
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  Future<bool> isOutsideSafeZone({
    required double currentLatitude,
    required double currentLongitude,
  }) async {
    final patientId = await getCurrentPatientId();

    if (patientId == null) {
      return false;
    }

    final safeZone = await supabase
        .from('safe_zones')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (safeZone == null) {
      return false;
    }

    final latitude = (safeZone['latitude'] as num).toDouble();

    final longitude = (safeZone['longitude'] as num).toDouble();

    final radius = (safeZone['radius'] as num).toDouble();

    final distance = Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      latitude,
      longitude,
    );

    return distance > radius;
  }

  Future<double?> getDistanceFromHome({
    required double currentLatitude,
    required double currentLongitude,
  }) async {
    final home = await getHomeLocation();

    if (home == null) {
      return null;
    }

    final homeLatitude = (home['latitude'] as num).toDouble();

    final homeLongitude = (home['longitude'] as num).toDouble();

    return Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      homeLatitude,
      homeLongitude,
    );
  }
}
