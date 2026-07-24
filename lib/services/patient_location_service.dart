import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'location_service.dart';

class PatientLocationService {
  final LocationService locationService = LocationService();

  Timer? _timer;

  void startTracking() {
    stopTracking();

    _uploadLocation();

    _timer = Timer.periodic(
      const Duration(seconds: 30),
          (timer) {
        _uploadLocation();
      },
    );
  }

  void stopTracking() {
    _timer?.cancel();
  }

  Future<void> _uploadLocation() async {
    Position? position =
    await locationService.getCurrentLocation();

    if (position == null) return;

    await locationService.saveLocation(
      patientId: "patient_001",
      latitude: position.latitude,
      longitude: position.longitude,
    );

    print(
      "Location Uploaded : "
          "${position.latitude}, "
          "${position.longitude}",
    );
  }
}