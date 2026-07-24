import 'package:flutter/material.dart';

class CaregiverDashboardScreen extends StatelessWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          "Caregiver Dashboard",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Assigned Patients",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/schedule');
                },
                child: const Text("Schedule Builder"),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/monitor');
                },
                child: const Text("Activity Monitor"),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/live-location');
                },
                child: const Text("Live Patient Location"),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/safe-zone');
                },
                child: const Text("Set Home Location"),
              ),
            ),

            const SizedBox(height: 20),

            _patientCard(context, "John Doe", "Normal", Colors.green),

            _patientCard(context, "Mary Smith", "Review Needed", Colors.orange),

            _patientCard(context, "Robert Johnson", "Normal", Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _patientCard(
    BuildContext context,
    String name,
    String status,
    Color statusColor,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: const Icon(Icons.person, color: Colors.white),
        ),

        title: Text(name),

        subtitle: Text(
          status,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),

        trailing: const Icon(Icons.arrow_forward_ios),

        onTap: () {},
      ),
    );
  }
}
