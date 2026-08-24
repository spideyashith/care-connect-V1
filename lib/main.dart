import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/activity_monitor_screen.dart';
import 'screens/admin_invitation_screen.dart';
import 'screens/caregiver_dashboard_screen.dart';
import 'screens/caregiver_live_location_screen.dart';
import 'screens/caregiver_schedule_screen.dart';
import 'screens/doctor_dashboard_screen.dart';
import 'screens/home_setup_screen.dart';
import 'screens/live_map_screen.dart';
import 'screens/location_test_screen.dart';
import 'screens/login_screen.dart';
import 'screens/patient_anchor_screen.dart';
import 'screens/patient_dashboard_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/set_safe_zone_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/take_me_home_screen.dart';
import 'screens/today_activities_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      detectSessionInUri: true,
    ),
  );

  // Initialize local notifications
  await NotificationService().initialize();

  runApp(const CareConnectApp());
}

class CareConnectApp extends StatelessWidget {
  const CareConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'CareConnect',

      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),

      initialRoute: '/',

      routes: {
        // =========================
        // STARTUP
        // =========================
        '/': (context) => const SplashScreen(),

        // =========================
        // AUTHENTICATION
        // =========================
        '/login': (context) => const LoginScreen(),

        '/signup': (context) => const SignupScreen(),

        '/reset-password': (context) => const ResetPasswordScreen(),

        // Legacy route
        '/role': (context) => const RoleSelectionScreen(),

        // =========================
        // MAIN DASHBOARDS
        // =========================
        '/patient': (context) => const PatientDashboardScreen(),

        '/caregiver': (context) => const CaregiverDashboardScreen(),

        '/doctor': (context) => const DoctorDashboardScreen(),

        // =========================
        // PATIENT
        // =========================
        '/anchor': (context) => const PatientAnchorScreen(),

        '/activities': (context) => const TodayActivitiesScreen(),

        '/location': (context) => const LocationTestScreen(),

        // =========================
        // CAREGIVER
        // =========================
        '/schedule': (context) => const CaregiverScheduleScreen(),

        '/monitor': (context) => const ActivityMonitorScreen(),

        '/live-location': (context) => const CaregiverLiveLocationScreen(),

        '/safe-zone': (context) => const SetSafeZoneScreen(),

        '/homeSetup': (context) => const HomeSetupScreen(),

        '/liveMap': (context) => const LiveMapScreen(),

        '/admin': (context) => const AdminInvitationScreen(),
        '/take-home': (context) => const TakeMeHomeScreen(),
      },
    );
  }
}
