import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/emergency_service.dart';
import '../services/home_location_service.dart';
import '../services/location_service.dart';

class LocationTestScreen extends StatefulWidget {
  const LocationTestScreen({super.key});

  @override
  State<LocationTestScreen> createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends State<LocationTestScreen> {
  final LocationService locationService = LocationService();
  final HomeLocationService homeService = HomeLocationService();
  final EmergencyService emergencyService = EmergencyService();

  Position? position;

  bool isLoading = false;

  Future<void> getLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await locationService.getCurrentLocation();

      if (result != null) {
        // Save current GPS location
        await locationService.saveLocation(
          patientId: "patient_001",
          latitude: result.latitude,
          longitude: result.longitude,
        );

        // Check Safe Zone
        final outside = await homeService.isOutsideSafeZone(
          currentLatitude: result.latitude,
          currentLongitude: result.longitude,
        );

        // If outside safe zone, automatically create an emergency alert
        if (outside) {
          await emergencyService.sendSafeZoneAlert(patientId: "patient_001");
        }

        setState(() {
          position = result;
        });

        if (outside) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "🚨 Patient Left Safe Zone!\nEmergency Alert Created",
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("✅ Patient Inside Safe Zone"),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Unable to get location")));
      }
    } catch (e) {
      debugPrint(e.toString());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GPS Test")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (position != null) ...[
                const Icon(Icons.location_on, size: 70, color: Colors.blue),

                const SizedBox(height: 20),

                Text(
                  "Latitude\n${position!.latitude}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Longitude\n${position!.longitude}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),
              ],

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : getLocation,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Get My Location"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
