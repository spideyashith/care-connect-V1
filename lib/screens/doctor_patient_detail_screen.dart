import 'package:flutter/material.dart';

import '../services/doctor_service.dart';

class DoctorPatientDetailScreen extends StatefulWidget {
  final String patientId;

  const DoctorPatientDetailScreen({super.key, required this.patientId});

  @override
  State<DoctorPatientDetailScreen> createState() =>
      _DoctorPatientDetailScreenState();
}

class _DoctorPatientDetailScreenState extends State<DoctorPatientDetailScreen> {
  final DoctorService doctorService = DoctorService();

  Map<String, dynamic>? patient;

  List<dynamic> activities = [];
  List<dynamic> alerts = [];

  Map<String, dynamic>? location;

  Map<String, dynamic>? home;

  Map<String, dynamic>? safeZone;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPatient();
  }

  Future<void> loadPatient() async {
    try {
      final results = await Future.wait([
        doctorService.getPatient(widget.patientId),
        doctorService.getPatientActivities(widget.patientId),
        doctorService.getPatientAlerts(widget.patientId),
        doctorService.getLatestLocation(widget.patientId),
        doctorService.getPatientHome(widget.patientId),
        doctorService.getPatientSafeZone(widget.patientId),
      ]);

      if (!mounted) return;

      setState(() {
        patient = results[0] as Map<String, dynamic>?;

        activities = results[1] as List<dynamic>;

        alerts = results[2] as List<dynamic>;

        location = results[3] as Map<String, dynamic>?;

        home = results[4] as Map<String, dynamic>?;

        safeZone = results[5] as Map<String, dynamic>?;

        isLoading = false;
      });
    } catch (e) {
      debugPrint('Doctor patient error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient Details')),
        body: const Center(child: Text('Patient not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(patient!['full_name'] ?? 'Patient'),
        actions: [
          IconButton(onPressed: loadPatient, icon: const Icon(Icons.refresh)),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadPatient,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _patientProfileCard(),

            const SizedBox(height: 16),

            _safetyCard(),

            const SizedBox(height: 16),

            _locationCard(),

            const SizedBox(height: 16),

            _activitiesCard(),

            const SizedBox(height: 16),

            _alertsCard(),
          ],
        ),
      ),
    );
  }

  Widget _patientProfileCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Information',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person, size: 36),
              title: const Text('Name'),
              subtitle: Text(patient!['full_name'] ?? '--'),
            ),
            ListTile(
              leading: const Icon(Icons.key),
              title: const Text('Care Code'),
              subtitle: Text(patient!['care_code'] ?? '--'),
            ),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Role'),
              subtitle: Text(patient!['role'] ?? 'patient'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _safetyCard() {
    final hasAlerts = alerts.isNotEmpty;

    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(
          hasAlerts ? Icons.warning : Icons.check_circle,
          color: hasAlerts ? Colors.red : Colors.green,
          size: 38,
        ),
        title: const Text('Safety Status'),
        subtitle: Text(
          hasAlerts ? 'Safety events recorded' : 'No safety alerts recorded',
        ),
      ),
    );
  }

  Widget _locationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Latest Location',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (location == null)
              const Text('No location available.')
            else ...[
              Text('Latitude: ${location!['latitude']}'),
              const SizedBox(height: 8),
              Text('Longitude: ${location!['longitude']}'),
              const SizedBox(height: 8),
              Text('Updated: ${location!['created_at']}'),
            ],
            const SizedBox(height: 12),
            Text(
              home == null
                  ? 'Home location: Not set'
                  : 'Home location: Configured',
              style: TextStyle(
                color: home == null ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              safeZone == null
                  ? 'Safe zone: Not configured'
                  : 'Safe zone: ${safeZone!['radius']} m',
            ),
          ],
        ),
      ),
    );
  }

  Widget _activitiesCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (activities.isEmpty)
              const Text('No activities recorded.')
            else
              ...activities.take(10).map((activity) {
                final completed = activity['status'] == 'completed';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    completed ? Icons.check_circle : Icons.schedule,
                    color: completed ? Colors.green : Colors.orange,
                  ),
                  title: Text(activity['activity_name'] ?? 'Activity'),
                  subtitle: Text(activity['activity_time'] ?? '--'),
                  trailing: Text(completed ? 'Completed' : 'Pending'),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _alertsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Safety / Emergency History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (alerts.isEmpty)
              const Text('No emergency alerts recorded.')
            else
              ...alerts.take(10).map((alert) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text(alert['message'] ?? 'Emergency alert'),
                  subtitle: Text(alert['alert_time'] ?? '--'),
                );
              }),
          ],
        ),
      ),
    );
  }
}
