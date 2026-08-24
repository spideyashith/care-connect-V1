import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    checkSession();
  }

  Future<void> checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = supabase.auth.currentUser;

    if (!mounted) return;

    if (user == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

      return;
    }

    try {
      final profile = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      final role = profile?['role']?.toString().toLowerCase();

      if (role == 'patient') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/patient',
          (route) => false,
        );
      } else if (role == 'caregiver') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/caregiver',
          (route) => false,
        );
      } else if (role == 'doctor') {
        Navigator.pushNamedAndRemoveUntil(context, '/doctor', (route) => false);
      } else {
        await supabase.auth.signOut();

        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      debugPrint('Session check error: $e');

      await supabase.auth.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology, size: 90, color: Color(0xFF1565C0)),
            SizedBox(height: 20),
            Text(
              'CareConnect',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
