import 'package:flutter/material.dart';

import '../services/activity_service.dart';

class ActivityMonitorScreen extends StatefulWidget {
  const ActivityMonitorScreen({super.key});

  @override
  State<ActivityMonitorScreen> createState() => _ActivityMonitorScreenState();
}

class _ActivityMonitorScreenState extends State<ActivityMonitorScreen> {
  final ActivityService activityService = ActivityService();

  Map<String, dynamic>? activity;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    loadActivity();
  }

  Future<void> loadActivity() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // ActivityService now automatically uses
      // the currently authenticated patient's ID.
      final result = await activityService.getLatestActivity();

      if (!mounted) return;

      setState(() {
        activity = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Activity monitor error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load activity.';
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
        title: const Text('Patient Activity Monitor'),
        actions: [
          IconButton(onPressed: loadActivity, icon: const Icon(Icons.refresh)),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadActivity,

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(16),

          children: [
            if (errorMessage != null)
              Card(
                color: Colors.red.shade50,

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            Card(
              elevation: 4,

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Latest Activity",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (activity == null)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),

                          child: Column(
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 60,
                                color: Colors.grey,
                              ),

                              SizedBox(height: 12),

                              Text(
                                'No activity found.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      const Text(
                        'Activity',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        activity!['activity_name']?.toString() ?? 'Activity',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Scheduled Time',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        activity!['activity_time']?.toString() ?? '--',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Status',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),

                      const SizedBox(height: 6),

                      _statusWidget(),

                      if (activity!['completed_at'] != null) ...[
                        const SizedBox(height: 20),

                        const Text(
                          'Completed At',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          activity!['completed_at'].toString(),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusWidget() {
    final status = activity?['status']?.toString().toLowerCase();

    if (status == 'completed') {
      return const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 30),
          SizedBox(width: 10),
          Text(
            'Completed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      );
    }

    return const Row(
      children: [
        Icon(Icons.schedule, color: Colors.orange, size: 30),
        SizedBox(width: 10),
        Text(
          'Pending',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}
