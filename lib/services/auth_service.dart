import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': role},
    );

    if (response.user != null) {
      final user = response.user!;

      await supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'role': role,
      });
    }

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? get currentUser {
    return supabase.auth.currentUser;
  }

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final result = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return result;
  }
}
