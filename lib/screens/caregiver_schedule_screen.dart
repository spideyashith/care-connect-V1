import 'package:flutter/material.dart';

import '../services/activity_service.dart';
import '../services/caregiver_patient_service.dart';

class CaregiverScheduleScreen extends StatefulWidget {
  const CaregiverScheduleScreen({super.key});

  @override
  State<CaregiverScheduleScreen> createState() =>
      _CaregiverScheduleScreenState();
}

class _CaregiverScheduleScreenState extends State<CaregiverScheduleScreen> {
  final TextEditingController activityController = TextEditingController();

  final TextEditingController timeController = TextEditingController();

  final ActivityService activityService = ActivityService();

  final CaregiverPatientService caregiverPatientService =
      CaregiverPatientService();

  bool isSaving = false;

  String? assignedPatientName;

  @override
  void initState() {
    super.initState();

    loadAssignedPatient();
  }

  @override
  void dispose() {
    activityController.dispose();
    timeController.dispose();

    super.dispose();
  }

  Future<void> loadAssignedPatient() async {
    try {
      final patient = await caregiverPatientService.getAssignedPatient();

      if (!mounted) return;

      setState(() {
        assignedPatientName = patient?['full_name'];
      });
    } catch (e) {
      debugPrint('Load patient error: $e');
    }
  }

  Future<void> saveActivity() async {
    final activityName = activityController.text.trim();

    final activityTime = timeController.text.trim();

    if (activityName.isEmpty || activityTime.isEmpty) {
      showMessage('Enter activity name and time.', isError: true);
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final patientId = await caregiverPatientService.getAssignedPatientId();

      if (patientId == null) {
        throw Exception('No patient is connected to this caregiver.');
      }

      await activityService.saveActivity(
        patientId: patientId,
        activityName: activityName,
        activityTime: activityTime,
      );

      if (!mounted) return;

      activityController.clear();
      timeController.clear();

      showMessage('Activity saved successfully.');
    } catch (e) {
      debugPrint('Save activity error: $e');

      if (!mounted) return;

      showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Activity')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Assigned Patient',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),

                title: Text(assignedPatientName ?? 'No patient connected'),

                subtitle: const Text(
                  'This activity will be assigned to the connected patient.',
                ),
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: activityController,

              textInputAction: TextInputAction.next,

              decoration: const InputDecoration(
                labelText: 'Activity Name',
                hintText: 'Example: Take Medicine',
                prefixIcon: Icon(Icons.task_alt),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: timeController,

              readOnly: true,

              decoration: const InputDecoration(
                labelText: 'Time',
                hintText: 'Select time',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),

              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (picked == null) {
                  return;
                }

                if (!mounted) return;

                setState(() {
                  timeController.text = picked.format(context);
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveActivity,

                icon: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),

                label: Text(isSaving ? 'SAVING...' : 'SAVE ACTIVITY'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
