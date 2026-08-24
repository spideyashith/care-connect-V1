import 'package:flutter/material.dart';

import '../services/activity_service.dart';

class PatientAnchorScreen extends StatefulWidget {
  const PatientAnchorScreen({super.key});

  @override
  State<PatientAnchorScreen> createState() => _PatientAnchorScreenState();
}

class _PatientAnchorScreenState extends State<PatientAnchorScreen> {
  final ActivityService activityService = ActivityService();

  Map<String, dynamic>? activity;

  bool isLoading = true;
  bool isCompleting = false;

  @override
  void initState() {
    super.initState();

    loadActivity();
  }

  Future<void> loadActivity() async {
    try {
      final result = await activityService.getLatestActivity();

      if (!mounted) return;

      setState(() {
        activity = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Load activity error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> markCompleted() async {
    if (activity == null || isCompleting) {
      return;
    }

    setState(() {
      isCompleting = true;
    });

    try {
      await activityService.markActivityCompleted(activity!['id']);

      await loadActivity();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Activity completed.'),
        ),
      );
    } catch (e) {
      debugPrint('Complete activity error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Unable to complete activity.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCompleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final noActivity = activity == null;

    final completed = activity?['status'] == 'completed';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),

        title: const Text(
          'Patient Board',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            const SizedBox(height: 30),

            const Text(
              'Current Activity',
              style: TextStyle(fontSize: 22, color: Colors.grey),
            ),

            const SizedBox(height: 15),

            Text(
              noActivity
                  ? 'No Activity'
                  : activity!['activity_name']?.toString() ?? 'Activity',
              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            const Text(
              'Scheduled Time',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),

            const SizedBox(height: 10),

            Text(
              noActivity
                  ? '--'
                  : activity!['activity_time']?.toString() ?? '--',
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
                padding: const EdgeInsets.all(18),

                child: Column(
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      noActivity
                          ? 'No Activity'
                          : completed
                          ? 'Completed'
                          : 'Pending',

                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: noActivity
                            ? Colors.grey
                            : completed
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),

                    if (completed && activity!['completed_at'] != null) ...[
                      const SizedBox(height: 15),
                      Text(
                        'Completed At: '
                        '${activity!['completed_at']}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton(
                onPressed: noActivity || completed || isCompleting
                    ? null
                    : markCompleted,

                child: isCompleting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(completed ? 'ACTIVITY COMPLETED' : 'MARK COMPLETED'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
