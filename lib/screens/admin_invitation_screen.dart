import 'package:flutter/material.dart';

import '../services/admin_service.dart';

class AdminInvitationScreen extends StatefulWidget {
  const AdminInvitationScreen({super.key});

  @override
  State<AdminInvitationScreen> createState() => _AdminInvitationScreenState();
}

class _AdminInvitationScreenState extends State<AdminInvitationScreen> {
  final AdminService adminService = AdminService();

  final TextEditingController emailController = TextEditingController();

  String selectedRole = 'caregiver';

  int expiryHours = 24;

  bool isCreating = false;
  bool isLoading = true;

  List<dynamic> invitations = [];

  @override
  void initState() {
    super.initState();
    loadInvitations();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> loadInvitations() async {
    try {
      final result = await adminService.getInvitations();

      if (!mounted) return;

      setState(() {
        invitations = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Load invitations error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('Unable to load invitations.', isError: true);
    }
  }

  Future<void> createInvitation() async {
    setState(() {
      isCreating = true;
    });

    try {
      final result = await adminService.createInvitation(
        role: selectedRole,
        invitedEmail: emailController.text.trim(),
        expiresInHours: expiryHours,
      );

      final code = result['code']?.toString() ?? '';

      if (!mounted) return;

      emailController.clear();

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Invitation Created'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Role: ${selectedRole == 'doctor' ? 'Doctor' : 'Caregiver'}',
                ),

                const SizedBox(height: 12),

                const Text(
                  'Invitation Code',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                SelectableText(
                  code,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text('Expires in $expiryHours hours.'),

                const SizedBox(height: 8),

                const Text(
                  'Copy this code and provide it to the staff member.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('DONE'),
              ),
            ],
          );
        },
      );

      await loadInvitations();
    } catch (e) {
      debugPrint('Create invitation error: $e');

      if (!mounted) return;

      showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isCreating = false;
        });
      }
    }
  }

  Future<void> revokeInvitation(String invitationId) async {
    try {
      await adminService.revokeInvitation(invitationId);

      await loadInvitations();

      if (!mounted) return;

      showMessage('Invitation revoked successfully.');
    } catch (e) {
      debugPrint('Revoke invitation error: $e');

      if (!mounted) return;

      showMessage(e.toString(), isError: true);
    }
  }

  String invitationStatus(Map<String, dynamic> invite) {
    if (invite['revoked_at'] != null) {
      return 'REVOKED';
    }

    if (invite['used_at'] != null) {
      return 'USED';
    }

    final expiryText = invite['expires_at']?.toString();

    if (expiryText != null) {
      final expiry = DateTime.tryParse(expiryText);

      if (expiry != null && expiry.isBefore(DateTime.now().toUtc())) {
        return 'EXPIRED';
      }
    }

    return 'ACTIVE';
  }

  Color statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;

      case 'USED':
        return Colors.blue;

      case 'EXPIRED':
        return Colors.orange;

      case 'REVOKED':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : Colors.green,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Invitations'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadInvitations,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadInvitations,

              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.all(16),

                children: [
                  // =================================================
                  // CREATE INVITATION
                  // =================================================
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Create Staff Invitation',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          DropdownButtonFormField<String>(
                            value: selectedRole,

                            decoration: const InputDecoration(
                              labelText: 'Staff Role',
                              border: OutlineInputBorder(),
                            ),

                            items: const [
                              DropdownMenuItem(
                                value: 'caregiver',
                                child: Text('Caregiver'),
                              ),
                              DropdownMenuItem(
                                value: 'doctor',
                                child: Text('Doctor'),
                              ),
                            ],

                            onChanged: isCreating
                                ? null
                                : (value) {
                                    if (value == null) {
                                      return;
                                    }

                                    setState(() {
                                      selectedRole = value;
                                    });
                                  },
                          ),

                          const SizedBox(height: 16),

                          TextField(
                            controller: emailController,

                            keyboardType: TextInputType.emailAddress,

                            decoration: const InputDecoration(
                              labelText: 'Staff Email (optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          DropdownButtonFormField<int>(
                            value: expiryHours,

                            decoration: const InputDecoration(
                              labelText: 'Expires After',
                              border: OutlineInputBorder(),
                            ),

                            items: const [
                              DropdownMenuItem(value: 1, child: Text('1 hour')),
                              DropdownMenuItem(
                                value: 24,
                                child: Text('24 hours'),
                              ),
                              DropdownMenuItem(
                                value: 48,
                                child: Text('48 hours'),
                              ),
                              DropdownMenuItem(
                                value: 72,
                                child: Text('72 hours'),
                              ),
                              DropdownMenuItem(
                                value: 168,
                                child: Text('7 days'),
                              ),
                            ],

                            onChanged: isCreating
                                ? null
                                : (value) {
                                    if (value == null) {
                                      return;
                                    }

                                    setState(() {
                                      expiryHours = value;
                                    });
                                  },
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 52,

                            child: ElevatedButton.icon(
                              onPressed: isCreating ? null : createInvitation,

                              icon: isCreating
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.key),

                              label: Text(
                                isCreating
                                    ? 'CREATING...'
                                    : 'CREATE INVITATION',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =================================================
                  // HISTORY
                  // =================================================
                  const Text(
                    'Invitation History',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  if (invitations.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No invitations created yet.'),
                      ),
                    ),

                  ...invitations.map((item) {
                    final invite = Map<String, dynamic>.from(item);

                    final status = invitationStatus(invite);

                    final canRevoke = status == 'ACTIVE';

                    final isDoctor = invite['role'] == 'doctor';

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            isDoctor ? Icons.medical_services : Icons.person,
                          ),
                        ),

                        title: Text(isDoctor ? 'Doctor' : 'Caregiver'),

                        subtitle: Text(
                          '${invite['invited_email'] ?? 'No email'}\n'
                          'Expires: ${invite['expires_at'] ?? '--'}',
                        ),

                        isThreeLine: true,

                        trailing: SizedBox(
                          width: 90,

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Text(
                                status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor(status),
                                ),
                              ),

                              if (canRevoke)
                                TextButton(
                                  onPressed: () =>
                                      revokeInvitation(invite['id']),
                                  child: const Text('REVOKE'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
