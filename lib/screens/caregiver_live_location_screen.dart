import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/caregiver_patient_service.dart';
import '../services/location_service.dart';

class CaregiverLiveLocationScreen extends StatefulWidget {
  const CaregiverLiveLocationScreen({super.key});

  @override
  State<CaregiverLiveLocationScreen> createState() =>
      _CaregiverLiveLocationScreenState();
}

class _CaregiverLiveLocationScreenState
    extends State<CaregiverLiveLocationScreen> {
  final LocationService locationService = LocationService();

  final CaregiverPatientService caregiverPatientService =
      CaregiverPatientService();

  Map<String, dynamic>? location;

  String? patientName;

  bool isLoading = true;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    loadLocation();

    timer = Timer.periodic(const Duration(seconds: 10), (_) => loadLocation());
  }

  Future<void> loadLocation() async {
    try {
      final patient = await caregiverPatientService.getAssignedPatient();

      if (patient == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          patientName = null;
          location = null;
        });

        return;
      }

      final patientId = patient['id'] as String;

      final result = await locationService.getLatestLocation(patientId);

      if (!mounted) return;

      setState(() {
        patientName = patient['full_name'];

        location = result;

        isLoading = false;
      });
    } catch (e) {
      debugPrint('Caregiver location error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openGoogleMaps() async {
    if (location == null) {
      return;
    }

    final latitude = (location!['latitude'] as num).toDouble();

    final longitude = (location!['longitude'] as num).toDouble();

    final Uri mapsUrl = Uri.parse(
      'https://www.google.com/maps/search/'
      '?api=1&query=$latitude,$longitude',
    );

    try {
      final launched = await launchUrl(
        mapsUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not launch maps.');
      }
    } catch (e) {
      debugPrint('Maps error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (location == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Patient Location')),

        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const Icon(Icons.location_off, size: 70, color: Colors.grey),

                const SizedBox(height: 20),

                Text(
                  patientName == null
                      ? 'No patient assigned.'
                      : 'No location available for '
                            '$patientName.',
                  textAlign: TextAlign.center,

                  style: const TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: loadLocation,

                  icon: const Icon(Icons.refresh),

                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final latitude = (location!['latitude'] as num).toDouble();

    final longitude = (location!['longitude'] as num).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Patient Location'),

        actions: [
          IconButton(onPressed: loadLocation, icon: const Icon(Icons.refresh)),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Card(
          elevation: 5,

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Patient',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),

                const SizedBox(height: 8),

                Text(
                  patientName ?? 'Patient',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Divider(),

                const SizedBox(height: 10),

                const Text('Latitude', style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 5),

                Text('$latitude', style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 20),

                const Text('Longitude', style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 5),

                Text('$longitude', style: const TextStyle(fontSize: 20)),

                const SizedBox(height: 20),

                const Text(
                  'Last Updated',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 5),

                Text(
                  '${location!['created_at']}',
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: openGoogleMaps,

                    icon: const Icon(Icons.map),

                    label: const Text('Open Google Maps'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
