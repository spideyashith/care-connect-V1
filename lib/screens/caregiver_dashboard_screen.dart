import 'package:flutter/material.dart';

import '../services/caregiver_service.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  final CaregiverService caregiverService = CaregiverService();

  Map<String, dynamic>? latestLocation;
  Map<String, dynamic>? latestAlert;
  List<dynamic> activities = [];

  bool isLoading = true;

  Future<void> loadDashboard() async {
    final location = await caregiverService.getLatestLocation();
    final alert = await caregiverService.getLatestAlert();
    final activityList = await caregiverService.getActivities();

    setState(() {
      latestLocation = location;
      latestAlert = alert;
      activities = activityList;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Caregiver Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: "Live Map",
            onPressed: () {
              Navigator.pushNamed(context, "/liveMap");
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: loadDashboard,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Patient"),
                  subtitle: const Text("John Doe"),
                ),
              ),

              const SizedBox(height: 15),

              Card(
                child: ListTile(
                  leading: Icon(
                    latestAlert == null ? Icons.check_circle : Icons.warning,
                    color: latestAlert == null ? Colors.green : Colors.red,
                  ),
                  title: const Text("Patient Status"),
                  subtitle: Text(
                    latestAlert == null ? "SAFE" : "OUTSIDE SAFE ZONE",
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: const Text("Current Location"),
                  subtitle: Text(
                    latestLocation == null
                        ? "No Location"
                        : "Lat: ${latestLocation!['latitude']}\nLng: ${latestLocation!['longitude']}",
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: const Text("Latest Alert"),
                  subtitle: Text(
                    latestAlert == null
                        ? "No Active Alerts"
                        : latestAlert!['message'],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Today's Activities",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...activities.map((activity) {
                return Card(
                  child: ListTile(
                    leading: Icon(
                      activity['status'] == 'completed'
                          ? Icons.check_circle
                          : Icons.schedule,
                      color: activity['status'] == 'completed'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    title: Text(activity['activity_name']),
                    subtitle: Text(activity['activity_time']),
                    trailing: Text(activity['status']),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
