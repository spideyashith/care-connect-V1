import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/home_location_service.dart';
import '../services/location_service.dart';

class HomeSetupScreen extends StatefulWidget {
  const HomeSetupScreen({super.key});

  @override
  State<HomeSetupScreen> createState() => _HomeSetupScreenState();
}

class _HomeSetupScreenState extends State<HomeSetupScreen> {
  final LocationService locationService = LocationService();
  final HomeLocationService homeService = HomeLocationService();

  bool isLoading = false;

  Position? position;

  Future<void> saveHome() async {
    setState(() {
      isLoading = true;
    });

    final current = await locationService.getCurrentLocation();

    if (current != null) {
      position = current;

      await homeService.saveHomeLocation(
        patientId: "patient_001",
        latitude: current.latitude,
        longitude: current.longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Home Location Saved")));
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Setup")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Stand at the patient's house and press the button below.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : saveHome,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Save Home Location"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
