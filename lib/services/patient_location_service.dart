import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'emergency_service.dart';
import 'home_location_service.dart';
import 'location_service.dart';
import 'safe_zone_service.dart';

class PatientLocationService {
  final LocationService locationService = LocationService();

  final HomeLocationService homeLocationService = HomeLocationService();

  final SafeZoneService safeZoneService = SafeZoneService();

  final EmergencyService emergencyService = EmergencyService();

  final SupabaseClient supabase = Supabase.instance.client;

  Timer? _timer;

  bool _isUploading = false;

  // Prevent repeated alerts while patient
  // remains outside the safe zone.
  bool _currentlyOutsideSafeZone = false;

  void startTracking() {
    stopTracking();

    _uploadLocation();

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _uploadLocation();
    });
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _uploadLocation() async {
    if (_isUploading) {
      return;
    }

    final patientId = supabase.auth.currentUser?.id;

    if (patientId == null) {
      debugPrint('GPS tracking stopped: no authenticated patient.');
      return;
    }

    _isUploading = true;

    try {
      final position = await locationService.getCurrentLocation();

      if (position == null) {
        debugPrint('Unable to get patient location.');
        return;
      }

      // ----------------------------------------------------------
      // SAVE GPS LOCATION
      // ----------------------------------------------------------

      await locationService.saveLocation(
        patientId: patientId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      debugPrint(
        'Location uploaded: '
        '${position.latitude}, '
        '${position.longitude}',
      );

      // ----------------------------------------------------------
      // GET SAFE ZONE
      // ----------------------------------------------------------

      final safeZone = await safeZoneService.getSafeZone(patientId);

      if (safeZone == null) {
        debugPrint('No safe zone configured.');

        return;
      }

      final safeZoneLatitude = (safeZone['latitude'] as num).toDouble();

      final safeZoneLongitude = (safeZone['longitude'] as num).toDouble();

      final radius = (safeZone['radius'] as num).toDouble();

      // ----------------------------------------------------------
      // CHECK DISTANCE
      // ----------------------------------------------------------

      final outside = safeZoneService.isOutsideSafeZone(
        patientLat: position.latitude,
        patientLng: position.longitude,
        homeLat: safeZoneLatitude,
        homeLng: safeZoneLongitude,
        radius: radius,
      );

      // ----------------------------------------------------------
      // PATIENT LEFT SAFE ZONE
      // ----------------------------------------------------------

      if (outside && !_currentlyOutsideSafeZone) {
        _currentlyOutsideSafeZone = true;

        debugPrint('🚨 Patient left safe zone.');

        await emergencyService.sendSafeZoneAlert(
          patientId: patientId,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      // ----------------------------------------------------------
      // PATIENT RETURNED HOME
      // ----------------------------------------------------------

      if (!outside && _currentlyOutsideSafeZone) {
        _currentlyOutsideSafeZone = false;

        debugPrint('✅ Patient returned inside safe zone.');
      }
    } catch (e) {
      debugPrint('Patient location tracking error: $e');
    } finally {
      _isUploading = false;
    }
  }
}
