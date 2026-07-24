import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/activity_monitor_screen.dart';
import 'screens/caregiver_dashboard_screen.dart';
import 'screens/caregiver_live_location_screen.dart';
import 'screens/caregiver_schedule_screen.dart';
import 'screens/doctor_dashboard_screen.dart';
import 'screens/location_test_screen.dart';
import 'screens/login_screen.dart';
import 'screens/patient_anchor_screen.dart';
import 'screens/patient_dashboard_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/set_safe_zone_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/today_activities_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const CareConnectApp());
}

class CareConnectApp extends StatelessWidget {
  const CareConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CareConnect',

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/role': (context) => const RoleSelectionScreen(),
        '/patient': (context) => const PatientDashboardScreen(),
        '/caregiver': (context) => const CaregiverDashboardScreen(),
        '/doctor': (context) => const DoctorDashboardScreen(),
        '/anchor': (context) => const PatientAnchorScreen(),
        '/schedule': (context) => const CaregiverScheduleScreen(),
        '/monitor': (context) => const ActivityMonitorScreen(),
        '/activities': (context) => const TodayActivitiesScreen(),
        '/location': (context) => const LocationTestScreen(),
        '/live-location': (context) => const CaregiverLiveLocationScreen(),
        '/safe-zone': (context) => const SetSafeZoneScreen(),
      },
    );
  }
}
