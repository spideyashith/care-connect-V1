import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationTestScreen extends StatefulWidget {
  const LocationTestScreen({super.key});

  @override
  State<LocationTestScreen> createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends State<LocationTestScreen> {
  final LocationService locationService = LocationService();

  Position? position;

  bool isLoading = false;

  Future<void> getLocation() async {
    setState(() {
      isLoading = true;
    });

    final result = await locationService.getCurrentLocation();

    if (result != null) {
      await locationService.saveLocation(
        patientId: "patient_001",
        latitude: result.latitude,
        longitude: result.longitude,
      );

      setState(() {
        position = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location Saved Successfully"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to get location"),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GPS Test"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (position != null) ...[
                Text(
                  "Latitude\n${position!.latitude}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Text(
                  "Longitude\n${position!.longitude}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 30),
              ],
              ElevatedButton(
                onPressed: isLoading ? null : getLocation,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Get My Location"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}