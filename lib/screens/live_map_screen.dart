import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/caregiver_service.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final CaregiverService caregiverService = CaregiverService();

  final MapController mapController = MapController();

  LatLng? patientLocation;
  LatLng? homeLocation;

  double safeZoneRadius = 500;

  String patientName = 'Patient';

  String safetyStatus = 'Unknown';

  bool isLoading = true;

  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();

    loadMapData();

    // Refresh every 10 seconds.
    refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => loadMapData(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadMapData() async {
    try {
      final patient = await caregiverService.getConnectedPatient();

      if (patient == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      final results = await Future.wait([
        caregiverService.getLatestLocation(),
        caregiverService.getHomeLocation(),
        caregiverService.getSafeZone(),
        caregiverService.getLatestAlert(),
      ]);

      final location = results[0] as Map<String, dynamic>?;

      final home = results[1] as Map<String, dynamic>?;

      final safeZone = results[2] as Map<String, dynamic>?;

      final alert = results[3] as Map<String, dynamic>?;

      LatLng? newPatientLocation;
      LatLng? newHomeLocation;

      double newRadius = 500;

      if (location != null) {
        newPatientLocation = LatLng(
          (location['latitude'] as num).toDouble(),
          (location['longitude'] as num).toDouble(),
        );
      }

      if (home != null) {
        newHomeLocation = LatLng(
          (home['latitude'] as num).toDouble(),
          (home['longitude'] as num).toDouble(),
        );
      }

      // Prefer radius from safe_zones.
      if (safeZone != null && safeZone['radius'] != null) {
        newRadius = (safeZone['radius'] as num).toDouble();
      }

      String newSafetyStatus = 'Unknown';

      if (alert != null) {
        newSafetyStatus = 'ALERT';
      } else if (newPatientLocation != null && newHomeLocation != null) {
        // Simple local distance check.
        const distance = Distance();

        final metres = distance.as(
          LengthUnit.Meter,
          newPatientLocation,
          newHomeLocation,
        );

        newSafetyStatus = metres > newRadius ? 'OUTSIDE SAFE ZONE' : 'SAFE';
      }

      if (!mounted) return;

      setState(() {
        patientName = patient['full_name'] ?? 'Patient';

        patientLocation = newPatientLocation;

        homeLocation = newHomeLocation;

        safeZoneRadius = newRadius;

        safetyStatus = newSafetyStatus;

        isLoading = false;
      });

      if (newPatientLocation != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          try {
            mapController.move(newPatientLocation!, 16);
          } catch (_) {}
        });
      }
    } catch (e) {
      debugPrint('Live map error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void centerOnPatient() {
    if (patientLocation == null) {
      return;
    }

    try {
      mapController.move(patientLocation!, 17);
    } catch (e) {
      debugPrint('Center map error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (patientLocation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Patient Map')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 70, color: Colors.grey),
                const SizedBox(height: 20),
                Text(
                  'No location available for $patientName.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: loadMapData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('$patientName - Live Map')),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'refresh_map',
            onPressed: loadMapData,
            child: const Icon(Icons.refresh),
          ),

          const SizedBox(height: 12),

          FloatingActionButton(
            heroTag: 'center_patient',
            onPressed: centerOnPatient,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),

      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,

            options: MapOptions(
              initialCenter: patientLocation!,
              initialZoom: 16,
            ),

            children: [
              // ==================================================
              // MAP TILES
              // ==================================================
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                userAgentPackageName: 'com.example.careconnect',
              ),

              // ==================================================
              // SAFE ZONE CIRCLE
              // ==================================================
              if (homeLocation != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: homeLocation!,

                      radius: safeZoneRadius,

                      useRadiusInMeter: true,

                      color: Colors.green.withValues(alpha: 0.20),

                      borderColor: Colors.green,

                      borderStrokeWidth: 2,
                    ),
                  ],
                ),

              // ==================================================
              // MARKERS
              // ==================================================
              MarkerLayer(
                markers: [
                  if (homeLocation != null)
                    Marker(
                      point: homeLocation!,

                      width: 55,
                      height: 55,

                      child: const Icon(
                        Icons.home,
                        color: Colors.green,
                        size: 42,
                      ),
                    ),

                  Marker(
                    point: patientLocation!,

                    width: 55,
                    height: 55,

                    child: const Icon(
                      Icons.person_pin_circle,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ======================================================
          // STATUS PANEL
          // ======================================================
          Positioned(
            top: 16,
            left: 16,
            right: 16,

            child: Card(
              elevation: 5,

              child: Padding(
                padding: const EdgeInsets.all(14),

                child: Row(
                  children: [
                    Icon(
                      safetyStatus == 'SAFE'
                          ? Icons.check_circle
                          : Icons.warning,
                      color: safetyStatus == 'SAFE' ? Colors.green : Colors.red,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),

                          Text(
                            safetyStatus,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: safetyStatus == 'SAFE'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '${safeZoneRadius.round()} m',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
