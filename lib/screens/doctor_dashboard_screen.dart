import 'package:flutter/material.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          "Doctor Dashboard",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Overview",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: _summaryCard(
                    "Total Patients",
                    "15",
                    Icons.people,
                    Colors.blue,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _summaryCard(
                    "Warnings",
                    "2",
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Recent Patient Alerts",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _alertCard(
              "Mary Smith",
              "Behavioral deviation detected",
              Colors.orange,
            ),

            _alertCard(
              "John Doe",
              "Normal activity pattern",
              Colors.green,
            ),

            _alertCard(
              "Robert Johnson",
              "Normal activity pattern",
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Icon(
              icon,
              size: 40,
              color: color,
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _alertCard(
      String patient,
      String status,
      Color color,
      ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        leading: Icon(
          Icons.person,
          color: color,
          size: 35,
        ),

        title: Text(patient),

        subtitle: Text(status),

        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),
      ),
    );
  }
}