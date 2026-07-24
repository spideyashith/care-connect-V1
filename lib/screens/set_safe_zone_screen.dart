import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';
import '../services/safe_zone_service.dart';

class SetSafeZoneScreen extends StatefulWidget {
  const SetSafeZoneScreen({super.key});

  @override
  State<SetSafeZoneScreen> createState() => _SetSafeZoneScreenState();
}

class _SetSafeZoneScreenState extends State<SetSafeZoneScreen> {
  final LocationService locationService = LocationService();

  final SafeZoneService safeZoneService = SafeZoneService();

  bool loading = false;

  Future<void> saveHome() async {
    try {
      print("========== SAFE ZONE ==========");
      print("STEP 1 : Button Pressed");

      setState(() {
        loading = true;
      });

      print("STEP 2 : Getting Current Location");

      Position? position = await locationService.getCurrentLocation();

      print("STEP 3 : Location Received");

      if (position == null) {
        print("❌ Location is NULL");

        setState(() {
          loading = false;
        });

        return;
      }

      print("Latitude : ${position.latitude}");
      print("Longitude : ${position.longitude}");

      print("STEP 4 : Saving Safe Zone");

      await safeZoneService.saveHomeLocation(
        patientId: "patient_001",
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 200,
      );

      print("STEP 5 : Saved Successfully");

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Safe Zone Saved Successfully")),
      );
    } catch (e, stackTrace) {
      print("❌ SAFE ZONE ERROR");
      print(e);
      print(stackTrace);

      if (mounted) {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Safe Zone")),

      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: saveHome,
                icon: const Icon(Icons.home),
                label: const Text("Set Current Location as Home"),
              ),
      ),
    );
  }
}
