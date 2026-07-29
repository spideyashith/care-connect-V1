import 'package:geolocator/geolocator.dart';

class GeofenceService {
  bool isInsideSafeZone({
    required double currentLatitude,
    required double currentLongitude,
    required double homeLatitude,
    required double homeLongitude,
    double radius = 500,
  }) {
    final distance = Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      homeLatitude,
      homeLongitude,
    );

    return distance <= radius;
  }

  double distanceFromHome({
    required double currentLatitude,
    required double currentLongitude,
    required double homeLatitude,
    required double homeLongitude,
  }) {
    return Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      homeLatitude,
      homeLongitude,
    );
  }
}
