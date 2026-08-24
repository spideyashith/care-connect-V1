import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> createInvitation({
    required String role,
    String? invitedEmail,
    required int expiresInHours,
  }) async {
    final response = await supabase.functions.invoke(
      'create-staff-invite',
      body: {
        'role': role,
        'invited_email': invitedEmail?.trim().isEmpty == true
            ? null
            : invitedEmail?.trim(),
        'expires_in_hours': expiresInHours,
      },
    );

    if (response.data is Map) {
      final data = Map<String, dynamic>.from(response.data as Map);

      if (data['error'] != null) {
        throw Exception(data['error'].toString());
      }

      return data;
    }

    throw Exception('Invalid response from server.');
  }

  Future<void> revokeInvitation(String invitationId) async {
    final response = await supabase.functions.invoke(
      'revoke-staff-invite',
      body: {'invite_id': invitationId},
    );

    if (response.data is Map) {
      final data = Map<String, dynamic>.from(response.data as Map);

      if (data['error'] != null) {
        throw Exception(data['error'].toString());
      }

      return;
    }

    throw Exception('Invalid response from server.');
  }

  Future<List<dynamic>> getInvitations() async {
    final result = await supabase
        .from('staff_invites')
        .select(
          'id, role, invited_email, expires_at, used_at, revoked_at, created_at',
        )
        .order('created_at', ascending: false);

    return result;
  }
}
