import 'package:flutter/material.dart';

import '../services/patient_location_service.dart';
import '../widgets/emergency_hold_button.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final PatientLocationService trackingService = PatientLocationService();

  @override
  void initState() {
    super.initState();

    // Start automatic GPS tracking
    trackingService.startTracking();
  }

  @override
  void dispose() {
    // Stop tracking when screen is closed
    trackingService.stopTracking();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          "Patient Dashboard",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Welcome, Patient",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // Patient Board
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/anchor');
                },
                child: const Text("Patient Board"),
              ),
            ),

            const SizedBox(height: 20),

            // Today's Activities
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/activities');
                },
                child: const Text("Today's Activities"),
              ),
            ),

            const SizedBox(height: 20),

            // GPS Test
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/location');
                },
                child: const Text("GPS Test"),
              ),
            ),

            const SizedBox(height: 20),

            _statusCard(),

            const SizedBox(height: 20),

            _activityCard(),

            const SizedBox(height: 20),

            _historyCard(),

            const SizedBox(height: 30),

            const Center(child: EmergencyHoldButton()),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    return Card(
      elevation: 4,
      child: const ListTile(
        leading: Icon(Icons.health_and_safety, color: Colors.green, size: 40),
        title: Text("Current Cognitive Status"),
        subtitle: Text(
          "Normal",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _activityCard() {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: const Icon(
          Icons.psychology,
          color: Color(0xFF1565C0),
          size: 40,
        ),
        title: const Text("Today's Cognitive Activity"),
        subtitle: const Text("Complete your memory activity"),
        trailing: ElevatedButton(onPressed: () {}, child: const Text("Start")),
      ),
    );
  }

  Widget _historyCard() {
    return Card(
      elevation: 4,
      child: const ListTile(
        leading: Icon(Icons.history, color: Colors.orange, size: 40),
        title: Text("Last Activity"),
        subtitle: Text("Yesterday - Normal"),
      ),
    );
  }
}
