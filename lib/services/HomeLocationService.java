import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeLocationService {
  final SupabaseClient supabase =
      Supabase.instance.client;

  Future<void> saveHomeLocation({
    required String patientId,
    required double latitude,
    required double longitude,
  }) async {
    // Remove previous home location for this patient.
    await supabase
        .from('patient_home')
        .delete()
        .eq('patient_id', patientId);

    // Save new home location.
    await supabase.from('patient_home').insert({
      'patient_id': patientId,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<Map<String, dynamic>?> getHomeLocation(
    String patientId,
  ) async {
    return await supabase
        .from('patient_home')
        .select()
        .eq('patient_id', patientId)
        .order(
          'id',
          ascending: false,
        )
        .limit(1)
        .maybeSingle();
  }

  Future<bool> isOutsideSafeZone({
    required String patientId,
    required double currentLatitude,
    required double currentLongitude,
    double radius = 500,
  }) async {
    final home =
        await getHomeLocation(patientId);

    if (home == null) {
      return false;
    }

    final homeLatitude =
        (home['latitude'] as num).toDouble();

    final homeLongitude =
        (home['longitude'] as num).toDouble();

    final distance =
        Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      homeLatitude,
      homeLongitude,
    );

    return distance > radius;
  }

  Future<double?> getDistanceFromHome({
    required String patientId,
    required double currentLatitude,
    required double currentLongitude,
  }) async {
    final home =
        await getHomeLocation(patientId);

    if (home == null) {
      return null;
    }

    final homeLatitude =
        (home['latitude'] as num).toDouble();

    final homeLongitude =
        (home['longitude'] as num).toDouble();

    return Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      homeLatitude,
      homeLongitude,
    );
  }
}