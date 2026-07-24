import 'package:flutter/material.dart';
import '../services/activity_service.dart';

class ActivityMonitorScreen extends StatefulWidget {
  const ActivityMonitorScreen({super.key});

  @override
  State<ActivityMonitorScreen> createState() =>
      _ActivityMonitorScreenState();
}

class _ActivityMonitorScreenState
    extends State<ActivityMonitorScreen> {

  final ActivityService activityService =
  ActivityService();

  Map<String, dynamic>? activity;

  bool isLoading = true;

  Future<void> loadActivity() async {

    try {

      final result =
      await activityService
          .getLatestActivity();

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

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Patient Activity Monitor",
        ),
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(16),

        child: Card(
          elevation: 4,

          child: Padding(
            padding:
            const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                const Text(
                  "Today's Activity",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  "Activity: ${activity?['activity_name'] ?? ''}",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  "Scheduled Time: ${activity?['activity_time'] ?? ''}",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  activity?['status'] ==
                      'completed'
                      ? "Status: Completed"
                      : "Status: Pending",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    activity?['status'] ==
                        'completed'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                if (activity?['status'] ==
                    'completed')
                  Text(
                    "Completed At: ${activity?['completed_at'] ?? ''}",
                    style:
                    const TextStyle(
                      fontSize: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}