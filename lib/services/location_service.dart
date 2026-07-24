import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  final supabase = Supabase.instance.client;

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> saveLocation({
    required String patientId,
    required double latitude,
    required double longitude,
  }) async {
    await supabase.from('patient_locations').insert({
      'patient_id': patientId,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<Map<String, dynamic>?> getLatestLocation() async {
    final response = await supabase
        .from('patient_locations')
        .select()
        .order('created_at', ascending: false)
        .limit(1)
        .single();

    return response;
  }
}
