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

  // ============================================================
  // LOAD DASHBOARD
  // ============================================================

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

  // ============================================================
  // REALTIME EMERGENCY LISTENER
  // ============================================================

  Future<void> startEmergencyListener() async {
    try {
      final patientId = await caregiverService.getPatientId();

      if (patientId == null) {
        return;
      }

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

  // ============================================================
  // CONNECT PATIENT
  // ============================================================

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

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      debugPrint('Caregiver logout error: $e');

      if (!mounted) return;

      showMessage('Unable to logout.', isError: true);
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : Colors.green,
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),

        actions: [
          if (assignedPatient != null)
            IconButton(
              icon: const Icon(Icons.map),
              tooltip: 'Live Map',
              onPressed: () {
                Navigator.pushNamed(context, '/liveMap');
              },
            ),

          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: loadDashboard,
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
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
              if (assignedPatient == null)
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

              // ==================================================
              // CONNECTED PATIENT
              // ==================================================
              if (assignedPatient != null) ...[
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),

                    title: Text(assignedPatient!['full_name'] ?? 'Patient'),

                    subtitle: const Text('Connected Patient'),
                  ),
                ),

                const SizedBox(height: 15),

                // CONNECTION STATUS
                Card(
                  child: const ListTile(
                    leading: Icon(Icons.verified_user, color: Colors.green),

                    title: Text('Patient Connected'),

                    subtitle: Text('Monitoring is active.'),
                  ),
                ),

                const SizedBox(height: 15),

                // PATIENT STATUS
                Card(
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

                // CURRENT LOCATION
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.blue),

                    title: const Text('Current Location'),

                    subtitle: Text(
                      latestLocation == null
                          ? 'No Location'
                          : 'Lat: ${latestLocation!['latitude']}\n'
                                'Lng: ${latestLocation!['longitude']}',
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // LATEST ALERT
                Card(
                  color: latestAlert != null ? Colors.red.shade50 : null,

                  child: ListTile(
                    leading: Icon(
                      Icons.warning,
                      color: latestAlert != null ? Colors.red : Colors.grey,
                    ),

                    title: const Text('Latest Alert'),

                    subtitle: Text(
                      latestAlert == null
                          ? 'No Active Alerts'
                          : '${latestAlert!['message'] ?? 'Emergency Alert'}',
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ACTIVITIES
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
