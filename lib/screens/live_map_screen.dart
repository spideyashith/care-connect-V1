import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/caregiver_service.dart';
import '../services/home_location_service.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final CaregiverService caregiverService = CaregiverService();
  final HomeLocationService homeService = HomeLocationService();

  LatLng? patientLocation;
  LatLng? homeLocation;

  bool isLoading = true;

  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    loadLocations();
  }

  Future<void> loadLocations() async {
    final patient = await caregiverService.getLatestLocation();
    final home = await homeService.getHomeLocation();

    if (patient != null) {
      patientLocation = LatLng(patient['latitude'], patient['longitude']);
    }

    if (home != null) {
      homeLocation = LatLng(home['latitude'], home['longitude']);
    }

    setState(() {
      isLoading = false;
    });

    if (patientLocation != null) {
      mapController.move(patientLocation!, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (patientLocation == null) {
      return const Scaffold(
        body: Center(child: Text("No Patient Location Found")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Live Patient Map")),

      floatingActionButton: FloatingActionButton(
        onPressed: loadLocations,
        child: const Icon(Icons.refresh),
      ),

      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(initialCenter: patientLocation!, initialZoom: 16),

        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.careconnect",
          ),

          CircleLayer(
            circles: [
              if (homeLocation != null)
                CircleMarker(
                  point: homeLocation!,
                  radius: 500,
                  useRadiusInMeter: true,
                  color: Colors.green.withOpacity(.2),
                  borderColor: Colors.green,
                  borderStrokeWidth: 2,
                ),
            ],
          ),

          MarkerLayer(
            markers: [
              if (homeLocation != null)
                Marker(
                  point: homeLocation!,
                  width: 50,
                  height: 50,
                  child: const Icon(Icons.home, color: Colors.green, size: 40),
                ),

              Marker(
                point: patientLocation!,
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.red,
                  size: 45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
