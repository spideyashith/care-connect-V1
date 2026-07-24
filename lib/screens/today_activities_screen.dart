import 'package:flutter/material.dart';
import '../services/activity_service.dart';

class TodayActivitiesScreen extends StatefulWidget {
  const TodayActivitiesScreen({super.key});

  @override
  State<TodayActivitiesScreen> createState() =>
      _TodayActivitiesScreenState();
}

class _TodayActivitiesScreenState
    extends State<TodayActivitiesScreen> {

  final ActivityService activityService =
  ActivityService();

  List<dynamic> activities = [];

  bool isLoading = true;

  Future<void> loadActivities() async {

    final result =
    await activityService
        .getAllActivities();

    setState(() {

      activities = result;

      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadActivities();
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
          "Today's Activities",
        ),
      ),

      body: ListView.builder(
        itemCount: activities.length,

        itemBuilder: (context, index) {

          final activity =
          activities[index];

          return Card(
            margin:
            const EdgeInsets.all(8),

            child: ListTile(

              leading: Icon(
                activity['status'] ==
                    'completed'
                    ? Icons.check_circle
                    : Icons.schedule,
                color:
                activity['status'] ==
                    'completed'
                    ? Colors.green
                    : Colors.orange,
              ),

              title: Text(
                activity[
                'activity_name'],
              ),

              subtitle: Text(
                activity[
                'activity_time'],
              ),

              trailing: Text(
                activity['status'],
              ),
            ),
          );
        },
      ),
    );
  }
}