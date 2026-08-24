import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ============================================================
  // GET CURRENT GPS LOCATION
  // ============================================================

  Future<Position?> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  // ============================================================
  // SAVE CURRENT LOGGED-IN USER LOCATION
  // ============================================================

  Future<void> saveCurrentUserLocation({
    required double latitude,
    required double longitude,
  }) async {
    final patientId = supabase.auth.currentUser?.id;

    if (patientId == null) {
      throw Exception('No authenticated patient found.');
    }

    await saveLocation(
      patientId: patientId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // ============================================================
  // SAVE LOCATION
  // ============================================================

  Future<void> saveLocation({
    required String patientId,
    required double latitude,
    required double longitude,
  }) async {
    if (patientId.trim().isEmpty) {
      throw Exception('Patient ID is required.');
    }

    await supabase.from('patient_locations').insert({
      'patient_id': patientId,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  // ============================================================
  // GET LATEST LOCATION FOR SPECIFIC PATIENT
  // ============================================================

  Future<Map<String, dynamic>?> getLatestLocation(String patientId) async {
    if (patientId.trim().isEmpty) {
      return null;
    }

    return await supabase
        .from('patient_locations')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  // ============================================================
  // GET CURRENT USER'S LATEST LOCATION
  // ============================================================

  Future<Map<String, dynamic>?> getMyLatestLocation() async {
    final patientId = supabase.auth.currentUser?.id;

    if (patientId == null) {
      return null;
    }

    return getLatestLocation(patientId);
  }
}
