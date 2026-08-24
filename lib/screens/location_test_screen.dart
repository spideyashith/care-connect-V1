import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final SupabaseClient supabase = Supabase.instance.client;

  Position? position;

  bool isLoading = false;

  bool? outsideSafeZone;

  Future<void> getLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      final patientId = supabase.auth.currentUser?.id;

      if (patientId == null) {
        throw Exception('Patient is not logged in.');
      }

      final result = await locationService.getCurrentLocation();

      if (result == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get location.')),
        );

        return;
      }

      // Save REAL authenticated patient location.
      await locationService.saveLocation(
        patientId: patientId,
        latitude: result.latitude,
        longitude: result.longitude,
      );

      // Check this patient's safe zone.
      final outside = await homeService.isOutsideSafeZone(
        currentLatitude: result.latitude,
        currentLongitude: result.longitude,
      );

      // Create a safety alert only when outside.
      if (outside) {
        await emergencyService.sendSafeZoneAlert(
          patientId: patientId,
          latitude: result.latitude,
          longitude: result.longitude,
        );
      }

      if (!mounted) return;

      setState(() {
        position = result;
        outsideSafeZone = outside;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: outside ? Colors.red : Colors.green,
          content: Text(
            outside
                ? '🚨 Patient is outside the safe zone.'
                : '✅ Patient is inside the safe zone.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('GPS test error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeText = outsideSafeZone == null
        ? 'Not checked'
        : outsideSafeZone!
        ? 'OUTSIDE SAFE ZONE'
        : 'INSIDE SAFE ZONE';

    final safeColor = outsideSafeZone == null
        ? Colors.grey
        : outsideSafeZone!
        ? Colors.red
        : Colors.green;

    return Scaffold(
      appBar: AppBar(title: const Text('GPS & Safety')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            Icon(
              outsideSafeZone == true ? Icons.warning : Icons.location_on,
              size: 80,
              color: safeColor,
            ),

            const SizedBox(height: 20),

            Text(
              safeText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: safeColor,
              ),
            ),

            const SizedBox(height: 30),

            if (position != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Text(
                        'Current GPS Location',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        'Latitude\n${position!.latitude}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        'Longitude\n${position!.longitude}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: isLoading ? null : getLocation,

                icon: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.my_location),

                label: Text(isLoading ? 'CHECKING...' : 'GET MY LOCATION'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
