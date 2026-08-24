import 'package:flutter/material.dart';

import '../services/activity_service.dart';

class TodayActivitiesScreen extends StatefulWidget {
  const TodayActivitiesScreen({super.key});

  @override
  State<TodayActivitiesScreen> createState() => _TodayActivitiesScreenState();
}

class _TodayActivitiesScreenState extends State<TodayActivitiesScreen> {
  final ActivityService activityService = ActivityService();

  List<dynamic> activities = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadActivities();
  }

  Future<void> loadActivities() async {
    try {
      final result = await activityService.getAllActivities();

      if (!mounted) return;

      setState(() {
        activities = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Activities error: $e');

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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Activities"),
        actions: [
          IconButton(
            onPressed: loadActivities,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadActivities,

        child: activities.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 250),
                  Center(
                    child: Text(
                      'No activities assigned yet.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.all(8),

                itemCount: activities.length,

                itemBuilder: (context, index) {
                  final activity = Map<String, dynamic>.from(activities[index]);

                  final completed = activity['status'] == 'completed';

                  return Card(
                    margin: const EdgeInsets.all(8),

                    child: ListTile(
                      leading: Icon(
                        completed ? Icons.check_circle : Icons.schedule,
                        color: completed ? Colors.green : Colors.orange,
                        size: 32,
                      ),

                      title: Text(
                        activity['activity_name'] ?? 'Activity',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: Text(
                        'Time: '
                        '${activity['activity_time'] ?? '--'}',
                      ),

                      trailing: Text(
                        completed ? 'Completed' : 'Pending',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: completed ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
