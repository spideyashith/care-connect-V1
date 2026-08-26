import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
import 'services/fcm_service.dart';
import 'services/notification_service.dart';

/// Handles Firebase messages received while
/// the application is running in the background.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();

    debugPrint('FCM background message: ${message.messageId}');

    debugPrint('FCM title: ${message.notification?.title}');

    debugPrint('FCM body: ${message.notification?.body}');
  } catch (e) {
    debugPrint('FCM background handler error: $e');
  }
}

/// Initializes Firebase Messaging.
Future<void> initializeFirebaseMessaging() async {
  if (defaultTargetPlatform != TargetPlatform.android) {
    return;
  }

  try {
    final messaging = FirebaseMessaging.instance;

    final permission = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint(
      'FCM notification permission: '
      '${permission.authorizationStatus}',
    );

    final token = await messaging.getToken();

    debugPrint('FCM DEVICE TOKEN:');

    debugPrint(token);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        'FCM foreground message: '
        '${message.messageId}',
      );

      debugPrint(
        'FCM title: '
        '${message.notification?.title}',
      );

      debugPrint(
        'FCM body: '
        '${message.notification?.body}',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        'FCM notification opened: '
        '${message.messageId}',
      );
    });

    final initialMessage = await messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint(
        'App opened from FCM notification: '
        '${initialMessage.messageId}',
      );
    }
  } catch (e) {
    debugPrint('Firebase Messaging initialization error: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // LOAD ENVIRONMENT
  // ============================================================

  await dotenv.load(fileName: '.env');

  // ============================================================
  // INITIALIZE SUPABASE
  // ============================================================

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      detectSessionInUri: true,
    ),
  );

  // ============================================================
  // INITIALIZE FIREBASE
  // ============================================================

  if (defaultTargetPlatform == TargetPlatform.android) {
    try {
      await Firebase.initializeApp();

      debugPrint('Firebase initialized successfully.');

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await initializeFirebaseMessaging();
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  }

  // ============================================================
  // INITIALIZE FCM DEVICE TOKEN SERVICE
  // ============================================================

  if (defaultTargetPlatform == TargetPlatform.android) {
    try {
      await FcmService().initialize();

      debugPrint('FCM device token service initialized.');
    } catch (e) {
      debugPrint('FCM device token service error: $e');
    }
  }

  // ============================================================
  // INITIALIZE LOCAL NOTIFICATIONS
  // ============================================================

  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Local notification initialization error: $e');
  }

  // ============================================================
  // START APPLICATION
  // ============================================================

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
        // ======================================================
        // STARTUP
        // ======================================================
        '/': (context) => const SplashScreen(),

        // ======================================================
        // AUTHENTICATION
        // ======================================================
        '/login': (context) => const LoginScreen(),

        '/signup': (context) => const SignupScreen(),

        '/reset-password': (context) => const ResetPasswordScreen(),

        // Legacy route
        '/role': (context) => const RoleSelectionScreen(),

        // ======================================================
        // MAIN DASHBOARDS
        // ======================================================
        '/patient': (context) => const PatientDashboardScreen(),

        '/caregiver': (context) => const CaregiverDashboardScreen(),

        '/doctor': (context) => const DoctorDashboardScreen(),

        // ======================================================
        // PATIENT
        // ======================================================
        '/anchor': (context) => const PatientAnchorScreen(),

        '/activities': (context) => const TodayActivitiesScreen(),

        '/location': (context) => const LocationTestScreen(),

        '/take-home': (context) => const TakeMeHomeScreen(),

        // ======================================================
        // CAREGIVER
        // ======================================================
        '/schedule': (context) => const CaregiverScheduleScreen(),

        '/monitor': (context) => const ActivityMonitorScreen(),

        '/live-location': (context) => const CaregiverLiveLocationScreen(),

        '/safe-zone': (context) => const SetSafeZoneScreen(),

        '/homeSetup': (context) => const HomeSetupScreen(),

        '/liveMap': (context) => const LiveMapScreen(),

        // ======================================================
        // ADMIN
        // ======================================================
        '/admin': (context) => const AdminInvitationScreen(),
      },
    );
  }
}
