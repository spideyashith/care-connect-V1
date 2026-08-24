import 'package:supabase_flutter/supabase_flutter.dart';

class CurrentUserService {
  final SupabaseClient supabase = Supabase.instance.client;

  String? get currentUserId {
    return supabase.auth.currentUser?.id;
  }

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    return await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }

  Future<String?> getCurrentRole() async {
    final profile = await getCurrentProfile();

    return profile?['role'] as String?;
  }
}
