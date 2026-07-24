import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),

      appBar: AppBar(
        title: const Text("Select Role"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 30),

            _buildRoleCard(
              context,
              "Patient",
              Icons.person,
            ),

            const SizedBox(height: 20),

            _buildRoleCard(
              context,
              "Caregiver",
              Icons.favorite,
            ),

            const SizedBox(height: 20),

            _buildRoleCard(
              context,
              "Doctor",
              Icons.medical_services,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
      BuildContext context,
      String title,
      IconData icon,
      ) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(
          icon,
          size: 40,
          color: const Color(0xFF1565C0),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {

          if (title == "Patient") {
            Navigator.pushNamed(context, '/patient');
          }

          else if (title == "Caregiver") {
            Navigator.pushNamed(context, '/caregiver');
          }
          else if (title == "Doctor") {
            Navigator.pushNamed(
              context,
              '/doctor',
            );
          }
        },
      ),
    );
  }
}