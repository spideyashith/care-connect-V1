import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/doctor_service.dart';
import 'doctor_patient_detail_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final DoctorService doctorService = DoctorService();

  List<dynamic> patients = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadPatients();
  }

  Future<void> loadPatients() async {
    try {
      final result = await doctorService.getPatients();

      if (!mounted) return;

      setState(() {
        patients = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Doctor patients error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to load patients.')));
    }
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      debugPrint('Doctor logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),

        actions: [
          IconButton(
            onPressed: loadPatients,
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
        onRefresh: loadPatients,

        child: patients.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                children: const [
                  SizedBox(height: 250),

                  Center(
                    child: Text(
                      'No patients registered yet.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),

                itemCount: patients.length,

                itemBuilder: (context, index) {
                  final patient = Map<String, dynamic>.from(patients[index]);

                  return Card(
                    elevation: 3,

                    margin: const EdgeInsets.only(bottom: 12),

                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),

                      title: Text(patient['full_name'] ?? 'Patient'),

                      subtitle: Text(
                        'Care Code: '
                        '${patient['care_code'] ?? '--'}',
                      ),

                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorPatientDetailScreen(
                              patientId: patient['id'].toString(),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
