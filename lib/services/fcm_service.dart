import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FcmService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> registerDeviceToken() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    final token = await messaging.getToken();

    if (token == null || token.isEmpty) {
      return;
    }

    await supabase.from('device_tokens').upsert({
      'user_id': user.id,
      'token': token,
      'platform': 'android',
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'token');
  }

  Future<void> initialize() async {
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    await registerDeviceToken();

    messaging.onTokenRefresh.listen((newToken) async {
      final user = supabase.auth.currentUser;

      if (user == null) {
        return;
      }

      await supabase.from('device_tokens').upsert({
        'user_id': user.id,
        'token': newToken,
        'platform': 'android',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'token');
    });
  }
}
