import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/caregiver_connection_service.dart';
import '../services/caregiver_service.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  final CaregiverService caregiverService = CaregiverService();

  final CaregiverConnectionService connectionService =
      CaregiverConnectionService();

  final TextEditingController careCodeController = TextEditingController();

  Map<String, dynamic>? assignedPatient;
  Map<String, dynamic>? latestLocation;
  Map<String, dynamic>? latestAlert;

  List<dynamic> activities = [];

  bool isLoading = true;
  bool isConnecting = false;

  RealtimeChannel? emergencyChannel;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  @override
  void dispose() {
    careCodeController.dispose();

    if (emergencyChannel != null) {
      caregiverService.unsubscribe(emergencyChannel);
    }

    super.dispose();
  }

  Future<void> loadDashboard() async {
    try {
      final patient = await connectionService.getConnectedPatient();

      if (patient == null) {
        if (!mounted) return;

        setState(() {
          assignedPatient = null;
          latestLocation = null;
          latestAlert = null;
          activities = [];
          isLoading = false;
        });

        return;
      }

      final location = await caregiverService.getLatestLocation();
      final alert = await caregiverService.getLatestAlert();
      final activityList = await caregiverService.getActivities();

      if (!mounted) return;

      setState(() {
        assignedPatient = patient;
        latestLocation = location;
        latestAlert = alert;
        activities = activityList;
        isLoading = false;
      });

      await startEmergencyListener();
    } catch (e) {
      debugPrint('Caregiver dashboard error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('Unable to load caregiver dashboard.', isError: true);
    }
  }

  Future<void> startEmergencyListener() async {
    try {
      final patientId = await caregiverService.getPatientId();

      if (patientId == null) return;

      if (emergencyChannel != null) {
        await caregiverService.unsubscribe(emergencyChannel);
        emergencyChannel = null;
      }

      emergencyChannel = caregiverService.subscribeToEmergencyAlerts(
        patientId: patientId,
        onAlert: (alert) {
          if (!mounted) return;

          setState(() {
            latestAlert = alert;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              duration: Duration(seconds: 8),
              content: Text(
                '🚨 EMERGENCY ALERT FROM PATIENT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Emergency listener error: $e');
    }
  }

  Future<void> connectPatient() async {
    final code = careCodeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      showMessage('Enter the patient care code.', isError: true);
      return;
    }

    setState(() {
      isConnecting = true;
    });

    try {
      final result = await connectionService.connectPatient(code);

      final patientName = result['patient_name']?.toString() ?? 'Patient';

      careCodeController.clear();

      await loadDashboard();

      if (!mounted) return;

      showMessage('$patientName connected successfully.');
    } catch (e) {
      debugPrint('Connect patient error: $e');

      if (!mounted) return;

      showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isConnecting = false;
        });
      }
    }
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      debugPrint('Logout error: $e');

      if (!mounted) return;

      showMessage('Unable to logout.', isError: true);
    }
  }

  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : Colors.green,
        content: Text(message),
      ),
    );
  }

  Widget actionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    Color color = Colors.blue,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 3,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: onPressed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
        actions: [
          IconButton(
            onPressed: loadDashboard,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
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
              // ==================================================
              // CONNECT PATIENT
              // ==================================================
              if (assignedPatient == null) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connect Patient',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter the Care Code shown on the patient dashboard.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: careCodeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Patient Care Code',
                            hintText: 'CARE-XXXXXXXX',
                            prefixIcon: Icon(Icons.link),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: isConnecting ? null : connectPatient,
                            icon: isConnecting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.person_add),
                            label: Text(
                              isConnecting
                                  ? 'CONNECTING...'
                                  : 'CONNECT PATIENT',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // ==================================================
              // CONNECTED PATIENT
              // ==================================================
              if (assignedPatient != null) ...[
                Card(
                  elevation: 4,
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(assignedPatient!['full_name'] ?? 'Patient'),
                    subtitle: const Text('Connected Patient'),
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // PATIENT STATUS
                // ==================================================
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(
                      latestAlert == null ? Icons.check_circle : Icons.warning,
                      color: latestAlert == null ? Colors.green : Colors.red,
                    ),
                    title: const Text('Patient Status'),
                    subtitle: Text(latestAlert == null ? 'SAFE' : 'ALERT'),
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // QUICK ACTIONS
                // ==================================================
                const Text(
                  'Patient Management',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // Schedule Activity
                actionButton(
                  icon: Icons.calendar_month,
                  title: 'Schedule Activity',
                  subtitle: 'Create medicine, meals, appointments and tasks.',
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.pushNamed(context, '/schedule');
                  },
                ),

                // Activity Monitor
                actionButton(
                  icon: Icons.task_alt,
                  title: 'Activity Monitor',
                  subtitle: 'Check the patient\'s latest activity.',
                  color: Colors.green,
                  onPressed: () {
                    Navigator.pushNamed(context, '/monitor');
                  },
                ),

                // Live Location
                actionButton(
                  icon: Icons.location_on,
                  title: 'Live Patient Location',
                  subtitle: 'View the latest patient GPS coordinates.',
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.pushNamed(context, '/live-location');
                  },
                ),

                // Live Map
                actionButton(
                  icon: Icons.map,
                  title: 'Live Map',
                  subtitle: 'View patient, home and safe-zone location.',
                  color: Colors.deepPurple,
                  onPressed: () {
                    Navigator.pushNamed(context, '/liveMap');
                  },
                ),

                const SizedBox(height: 20),

                // ==================================================
                // LOCATION
                // ==================================================
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: 35,
                    ),
                    title: const Text('Current Location'),
                    subtitle: Text(
                      latestLocation == null
                          ? 'No location available yet'
                          : 'Lat: ${latestLocation!['latitude']}\n'
                                'Lng: ${latestLocation!['longitude']}\n'
                                'Updated: ${latestLocation!['created_at']}',
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // ALERT
                // ==================================================
                Card(
                  color: latestAlert != null ? Colors.red.shade50 : null,
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(
                      Icons.warning,
                      color: latestAlert != null ? Colors.red : Colors.grey,
                      size: 35,
                    ),
                    title: const Text('Latest Alert'),
                    subtitle: Text(
                      latestAlert == null
                          ? 'No active alerts'
                          : '${latestAlert!['message'] ?? 'Emergency alert'}',
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // TODAY'S ACTIVITIES
                // ==================================================
                const Text(
                  "Today's Activities",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                if (activities.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No activities assigned yet.'),
                    ),
                  ),

                ...activities.map((activity) {
                  final completed = activity['status'] == 'completed';

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        completed ? Icons.check_circle : Icons.schedule,
                        color: completed ? Colors.green : Colors.orange,
                      ),
                      title: Text(activity['activity_name'] ?? 'Activity'),
                      subtitle: Text(activity['activity_time'] ?? '--'),
                      trailing: Text(
                        completed ? 'Completed' : 'Pending',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: completed ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
