import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../services/activity_service.dart';

class CaregiverScheduleScreen extends StatefulWidget {
  const CaregiverScheduleScreen({super.key});

  @override
  State<CaregiverScheduleScreen> createState() =>
      _CaregiverScheduleScreenState();
}

class _CaregiverScheduleScreenState
    extends State<CaregiverScheduleScreen> {

  final TextEditingController activityController =
  TextEditingController();

  final TextEditingController timeController =
  TextEditingController();

  final ActivityService activityService =
  ActivityService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Builder"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: activityController,
              decoration: const InputDecoration(
                labelText: "Activity Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: timeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Time",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {

                TimeOfDay? pickedTime =
                await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {

                  String formattedTime =
                  pickedTime.format(context);

                  setState(() {
                    timeController.text =
                        formattedTime;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: () async {

                  if (activityController.text.isEmpty ||
                      timeController.text.isEmpty) {
                    return;
                  }

                  await activityService.saveActivity(
                    patientId: "patient_001",
                    activityName:
                    activityController.text,
                    activityTime:
                    timeController.text,
                  );

                  setState(() {
                    ActivityModel.activityName =
                        activityController.text;

                    ActivityModel.activityTime =
                        timeController.text;
                  });

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Activity Saved To Supabase",
                      ),
                    ),
                  );
                },

                child: const Text(
                  "SAVE ACTIVITY",
                ),
              ),
            ),
            const SizedBox(height: 30),

            Card(
              elevation: 4,
              child: ListTile(
                leading: const Icon(
                  Icons.schedule,
                  color: Colors.blue,
                ),
                title: Text(
                  ActivityModel.activityName,
                ),
                subtitle: Text(
                  ActivityModel.activityTime,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}