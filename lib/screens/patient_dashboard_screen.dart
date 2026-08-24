import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/activity_notification_sync_service.dart';
import '../services/patient_location_service.dart';
import '../widgets/emergency_hold_button.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final PatientLocationService trackingService = PatientLocationService();

  final ActivityNotificationSyncService notificationSyncService =
      ActivityNotificationSyncService();

  final SupabaseClient supabase = Supabase.instance.client;

  String patientName = 'Patient';
  String careCode = 'Loading...';

  @override
  void initState() {
    super.initState();

    trackingService.startTracking();
    notificationSyncService.start();

    loadPatientProfile();
  }

  Future<void> loadPatientProfile() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        return;
      }

      final profile = await supabase
          .from('profiles')
          .select('full_name, role, care_code')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted || profile == null) {
        return;
      }

      setState(() {
        patientName = profile['full_name'] ?? 'Patient';

        careCode = profile['care_code'] ?? 'Not available';
      });
    } catch (e) {
      debugPrint('Profile error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  @override
  void dispose() {
    trackingService.stopTracking();
    notificationSyncService.stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),

        title: const Text(
          'Patient Dashboard',
          style: TextStyle(color: Colors.white),
        ),

        actions: [
          IconButton(
            onPressed: logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Welcome, $patientName',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // CARE CODE
            // ====================================================
            Card(
              elevation: 4,

              child: ListTile(
                leading: const Icon(Icons.link, color: Colors.blue, size: 38),

                title: const Text(
                  'Your Care Code',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Text(
                  careCode,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Give this code to your caregiver to connect your accounts.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // PATIENT BOARD
            // ====================================================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/anchor');
                },

                icon: const Icon(Icons.dashboard),

                label: const Text('Patient Board'),
              ),
            ),

            const SizedBox(height: 15),

            // ====================================================
            // ACTIVITIES
            // ====================================================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/activities');
                },

                icon: const Icon(Icons.task_alt),

                label: const Text("Today's Activities"),
              ),
            ),

            const SizedBox(height: 15),

            // ====================================================
            // GPS
            // ====================================================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/location');
                },

                icon: const Icon(Icons.location_on),

                label: const Text('GPS & Safety'),
              ),
            ),

            const SizedBox(height: 15),

            // ====================================================
            // TAKE ME HOME
            // ====================================================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/take-home');
                },

                icon: const Icon(Icons.home),

                label: const Text('Take Me Home'),
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // SAFETY STATUS
            // ====================================================
            Card(
              elevation: 4,

              child: const ListTile(
                leading: Icon(
                  Icons.health_and_safety,
                  color: Colors.green,
                  size: 40,
                ),

                title: Text('Current Safety Status'),

                subtitle: Text(
                  'Monitoring Active',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // ACTIVITY CARD
            // ====================================================
            Card(
              elevation: 4,

              child: ListTile(
                leading: const Icon(
                  Icons.psychology,
                  color: Color(0xFF1565C0),
                  size: 40,
                ),

                title: const Text("Today's Activities"),

                subtitle: const Text(
                  'View your assigned activities and reminders.',
                ),

                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/activities');
                  },

                  child: const Text('VIEW'),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // HISTORY
            // ====================================================
            Card(
              elevation: 4,

              child: const ListTile(
                leading: Icon(Icons.history, color: Colors.orange, size: 40),

                title: Text('Activity History'),

                subtitle: Text('View completed activities.'),
              ),
            ),

            const SizedBox(height: 30),

            // ====================================================
            // EMERGENCY
            // ====================================================
            const Center(child: EmergencyHoldButton()),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
