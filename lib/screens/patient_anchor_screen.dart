import 'package:flutter/material.dart';
import '../services/activity_service.dart';




class PatientAnchorScreen extends StatefulWidget {
  const PatientAnchorScreen({super.key});

  @override
  State<PatientAnchorScreen> createState() =>
      _PatientAnchorScreenState();
}

class _PatientAnchorScreenState
    extends State<PatientAnchorScreen> {

  final ActivityService activityService =
  ActivityService();

  Map<String, dynamic>? activity;

  bool isLoading = true;


  Future<void> loadActivity() async {
    try {

      final result =
      await activityService.getLatestActivity();

      setState(() {
        activity = result;
        isLoading = false;
      });

    } catch (e) {

      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadActivity();
  }

  Future<void> markCompleted() async {

    if (activity == null) return;

    await activityService
        .markActivityCompleted(
      activity!['id'],
    );

    await loadActivity();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Activity Completed",
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          "Patient Board",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.center,

            children: [

              const SizedBox(height: 30),

              const Text(
                "Current Activity",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                activity?['activity_name'] ?? "No Activity",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Scheduled Time",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                activity?['activity_time'] ?? "--",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),

              const SizedBox(height: 40),

              Card(
                elevation: 4,
                child: Padding(
                  padding:
                  const EdgeInsets.all(16),

                  child: Column(
                    children: [

                      const Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        activity?['status'] == 'completed'
                            ? "Completed"
                            : "Pending",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                          FontWeight.bold,
                          color:
                          activity?['status'] == 'completed'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (activity?['status'] == 'completed')
                        Column(
                          children: [

                            const Text(
                              "Completed At",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              activity?['completed_at'] ?? "",
                              style:
                              const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed:
                  activity?['status'] == 'completed'
                      ? null
                      : markCompleted,

                  child: Text(
                    activity?['status'] == 'completed'
                        ? "ACTIVITY COMPLETED"
                        : "MARK COMPLETED",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}