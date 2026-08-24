import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/home_location_service.dart';
import '../services/location_service.dart';

class TakeMeHomeScreen extends StatefulWidget {
  const TakeMeHomeScreen({super.key});

  @override
  State<TakeMeHomeScreen> createState() => _TakeMeHomeScreenState();
}

class _TakeMeHomeScreenState extends State<TakeMeHomeScreen> {
  final LocationService locationService = LocationService();

  final HomeLocationService homeService = HomeLocationService();

  Position? currentPosition;

  double? distanceFromHome;

  bool isLoading = true;
  bool isRefreshing = false;

  String statusText = 'Checking location...';

  Color statusColor = Colors.blue;

  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();

    loadStatus();

    refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => loadStatus(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadStatus() async {
    if (isRefreshing) {
      return;
    }

    isRefreshing = true;

    try {
      final patientId = homeService.supabase.auth.currentUser?.id;

      if (patientId == null) {
        throw Exception('Patient is not logged in.');
      }

      final home = await homeService.getHomeLocation(patientId);

      if (home == null) {
        if (!mounted) return;

        setState(() {
          statusText = 'Home location is not set.';
          statusColor = Colors.orange;
          isLoading = false;
        });

        return;
      }

      final position = await locationService.getCurrentLocation();

      if (position == null) {
        throw Exception('Unable to get current location.');
      }

      final homeLatitude = (home['latitude'] as num).toDouble();

      final homeLongitude = (home['longitude'] as num).toDouble();

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        homeLatitude,
        homeLongitude,
      );

      final safeRadius = 500.0;

      final outside = distance > safeRadius;

      if (!mounted) return;

      setState(() {
        currentPosition = position;
        distanceFromHome = distance;

        statusText = outside
            ? 'You are outside your safe area.'
            : 'You are inside your safe area.';

        statusColor = outside ? Colors.red : Colors.green;

        isLoading = false;
      });
    } catch (e) {
      debugPrint('Take Me Home error: $e');

      if (!mounted) return;

      setState(() {
        statusText = 'Unable to check your location.';
        statusColor = Colors.orange;
        isLoading = false;
      });
    } finally {
      isRefreshing = false;
    }
  }

  String distanceText() {
    if (distanceFromHome == null) {
      return '--';
    }

    final distance = distanceFromHome!;

    if (distance < 1000) {
      return '${distance.round()} m';
    }

    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final outside = distanceFromHome != null && distanceFromHome! > 500;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),

        title: const Text(
          'Take Me Home',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: loadStatus,

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(20),

          children: [
            const SizedBox(height: 20),

            Icon(
              outside ? Icons.warning_rounded : Icons.home_rounded,

              size: 100,

              color: outside ? Colors.red : Colors.green,
            ),

            const SizedBox(height: 25),

            Text(
              statusText,

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 4,

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    const Text(
                      'Distance from Home',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      distanceText(),

                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Safe area: 500 m',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (outside)
              SizedBox(
                width: double.infinity,
                height: 70,

                child: ElevatedButton.icon(
                  onPressed: loadStatus,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  icon: const Icon(Icons.home, size: 32),

                  label: const Text(
                    'TAKE ME HOME',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            if (!outside)
              Card(
                color: Colors.green.shade50,

                child: const Padding(
                  padding: EdgeInsets.all(20),

                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 50),

                      SizedBox(height: 10),

                      Text(
                        'You are home.',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 25),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),

                child: Text(
                  'If you feel lost or unsafe, use the emergency button on your dashboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
