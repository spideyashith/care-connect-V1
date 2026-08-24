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

  Position? position;

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
      debugPrint('Get location error: $e');

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

  Future<void> saveHome() async {
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
      await homeService.saveHomeLocation(
        latitude: position!.latitude,
        longitude: position!.longitude,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Home location saved successfully.'),
        ),
      );
    } catch (e) {
      debugPrint('Save home error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Unable to save home location: $e'),
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
      appBar: AppBar(title: const Text('Set Home Location')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Icon(Icons.home, size: 90, color: Colors.green),

            const SizedBox(height: 20),

            const Text(
              'Set Patient Home',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'The current location will be saved as the patient home location.',
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
                        'Current Location',
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
                onPressed: position == null || isSaving ? null : saveHome,

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

                label: Text(isSaving ? 'SAVING...' : 'SAVE HOME LOCATION'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
