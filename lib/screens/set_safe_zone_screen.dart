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

  Position? position;

  int radius = 500;

  bool isLoading = false;
  bool isSaving = false;

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await locationService.getCurrentLocation();

      if (result == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get current location.')),
        );

        return;
      }

      if (!mounted) return;

      setState(() {
        position = result;
      });
    } catch (e) {
      debugPrint('Get safe zone location error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to get location.')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> saveSafeZone() async {
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Get your current location first.')),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await safeZoneService.saveSafeZone(
        latitude: position!.latitude,
        longitude: position!.longitude,
        radius: radius,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Safe zone saved successfully.'),
        ),
      );
    } catch (e) {
      debugPrint('Save safe zone error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Unable to save safe zone: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Safe Zone')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Icon(Icons.shield, size: 90, color: Colors.green),

            const SizedBox(height: 20),

            const Text(
              'Patient Safe Zone',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'Set the current location as the center of the patient safety area.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            if (position != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    children: [
                      const Text(
                        'Safe Zone Center',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text('Latitude: ${position!.latitude}'),

                      const SizedBox(height: 8),

                      Text('Longitude: ${position!.longitude}'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 25),

            DropdownButtonFormField<int>(
              initialValue: radius,

              decoration: const InputDecoration(
                labelText: 'Safe Zone Radius',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.radar),
              ),

              items: const [
                DropdownMenuItem(value: 100, child: Text('100 meters')),
                DropdownMenuItem(value: 250, child: Text('250 meters')),
                DropdownMenuItem(value: 500, child: Text('500 meters')),
                DropdownMenuItem(value: 750, child: Text('750 meters')),
                DropdownMenuItem(value: 1000, child: Text('1 kilometer')),
              ],

              onChanged: isSaving
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        radius = value;
                      });
                    },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed: isLoading ? null : getCurrentLocation,

                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.location_on),

                label: Text(
                  isLoading ? 'GETTING LOCATION...' : 'GET MY LOCATION',
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed: position == null || isSaving ? null : saveSafeZone,

                icon: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),

                label: Text(isSaving ? 'SAVING...' : 'SAVE SAFE ZONE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
