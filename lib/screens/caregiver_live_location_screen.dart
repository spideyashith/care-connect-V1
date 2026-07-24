import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Map<String, dynamic>? location;

  bool isLoading = true;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    loadLocation();

    timer = Timer.periodic(const Duration(seconds: 30), (_) {
      loadLocation();
    });
  }

  Future<void> loadLocation() async {
    try {
      final result = await locationService.getLatestLocation();

      if (!mounted) return;

      setState(() {
        location = result;
        isLoading = false;
      });
    } catch (e) {
      print(e);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openGoogleMaps() async {
    if (location == null) return;

    final latitude = location!['latitude'];
    final longitude = location!['longitude'];

    final Uri googleMaps = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
    );

    try {
      await launchUrl(googleMaps, mode: LaunchMode.externalApplication);
    } catch (e) {
      print(e);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
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

    return Scaffold(
      appBar: AppBar(title: const Text("Live Patient Location")),

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
                  "Patient",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),

                const SizedBox(height: 8),

                const Text(
                  "John Doe",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const Divider(),

                const SizedBox(height: 10),

                Text(
                  "Latitude\n${location?['latitude']}",
                  style: const TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 20),

                Text(
                  "Longitude\n${location?['longitude']}",
                  style: const TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 20),

                Text(
                  "Last Updated\n${location?['created_at']}",
                  style: const TextStyle(fontSize: 18),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: openGoogleMaps,

                    icon: const Icon(Icons.map),

                    label: const Text("Open Google Maps"),
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
