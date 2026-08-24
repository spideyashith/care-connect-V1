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

    bool isCompleting = false;

    @override
    void initState() {
        super.initState();
        loadActivity();
    }

    Future<void> loadActivity() async {
        try {
            final patientId =
            activityService.getCurrentPatientId();

            if (patientId == null) {
                throw Exception(
                        'No authenticated patient found.',
                        );
            }

            final result =
            await activityService
              .getLatestActivity(patientId);

            if (!mounted) return;

            setState(() {
                activity = result;
                isLoading = false;
            });
        } catch (e) {
            debugPrint(
                    'Load patient activity error: $e',
                    );

            if (!mounted) return;

            setState(() {
                isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
                    content: Text(
                    'Unable to load patient activity.',
                    ),
        ),
      );
        }
    }

    Future<void> markCompleted() async {
        if (activity == null) return;

        setState(() {
            isCompleting = true;
        });

        try {
            await activityService
          .markActivityCompleted(
                    activity!['id'],
      );

            await loadActivity();

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
                    content: Text(
                    'Activity Completed',
                    ),
        ),
      );
        } catch (e) {
            debugPrint(
                    'Complete activity error: $e',
                    );

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
                    content: Text(
                    'Unable to complete activity.',
                    ),
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
            return const Scaffold(
                    body: Center(
                    child:
            CircularProgressIndicator(),
        ),
      );
        }

        if (activity == null) {
            return Scaffold(
                    backgroundColor:
            const Color(0xFFF5F9FF),

                    appBar: AppBar(
                    backgroundColor:
              const Color(0xFF1565C0),

                    title: const Text(
                    'Patient Board',
                    style: TextStyle(
                    color: Colors.white,
            ),
          ),
        ),

            body: const Center(
                    child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                    'No activity has been assigned yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    fontSize: 22,
                    fontWeight:
            FontWeight.bold,
              ),
            ),
          ),
        ),
      );
        }

        final bool isCompleted =
                activity!['status'] ==
        'completed';

        return Scaffold(
                backgroundColor:
          const Color(0xFFF5F9FF),

                appBar: AppBar(
                backgroundColor:
            const Color(0xFF1565C0),

                title: const Text(
                'Patient Board',
                style: TextStyle(
                color: Colors.white,
          ),
        ),
      ),

        body: SingleChildScrollView(
                padding:
            const EdgeInsets.all(20),

                child: Column(
                children: [
            const SizedBox(height: 30),

            const Text(
                'Current Activity',
                style: TextStyle(
                fontSize: 22,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 15),

        Text(
                activity!['activity_name'] ??
        'Activity',

                textAlign: TextAlign.center,

                style: const TextStyle(
                fontSize: 36,
                fontWeight:
        FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
                'Scheduled Time',
                style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

        Text(
                activity!['activity_time'] ??
        '--',

                style: const TextStyle(
                fontSize: 28,
                fontWeight:
        FontWeight.bold,
                color:
        Color(0xFF1565C0),
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
                'Status',
                style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                      ),
                    ),

                    const SizedBox(
                height: 10,
                    ),

        Text(
                isCompleted
                        ? 'Completed'
                        : 'Pending',

                style: TextStyle(
                fontSize: 24,
                fontWeight:
        FontWeight.bold,
                color: isCompleted
                ? Colors.green
                : Colors.orange,
                      ),
                    ),

        if (isCompleted &&
                activity![
        'completed_at'] !=
        null) ...[
                      const SizedBox(
                height: 20,
                      ),

                      const Text(
                'Completed At',
                style: TextStyle(
                color: Colors.grey,
                        ),
                      ),

                      const SizedBox(
                height: 8,
                      ),

        Text(
                activity![
        'completed_at'],

        style:
                            const TextStyle(
                fontSize: 18,
                fontWeight:
        FontWeight.bold,
                        ),
                      ),
                    ],
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
        isCompleted ||
                isCompleting
                ? null
                : markCompleted,

                child: isCompleting
                ? const SizedBox(
                width: 24,
                height: 24,
                child:
        CircularProgressIndicator(
                color: Colors.white,
                        ),
                      )
                    : Text(
                isCompleted
                        ? 'ACTIVITY COMPLETED'
                        : 'MARK COMPLETED',
                ),
              ),
            ),
          ],
        ),
      ),
    );
    }
}