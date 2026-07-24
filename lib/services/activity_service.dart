import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityService {

  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getLatestActivity() async {

    final response =
    await supabase
        .from('activities')
        .select()
        .order('id', ascending: false)
        .limit(1)
        .single();

    return response;
  }

  Future<List<dynamic>> getAllActivities() async {

    final response =
    await supabase
        .from('activities')
        .select()
        .order(
      'created_at',
      ascending: false,
    );

    return response;
  }


  Future<void> markActivityCompleted(
      int activityId,
      ) async {

    await supabase
        .from('activities')
        .update({
      'status': 'completed',
      'completed_at':
      DateTime.now().toString(),
    })
        .eq('id', activityId);
  }

  Future<void> saveActivity({
    required String patientId,
    required String activityName,
    required String activityTime,
  }) async {

    await supabase
        .from('activities')
        .insert({
      'patient_id': patientId,
      'activity_name': activityName,
      'activity_time': activityTime,
      'status': 'pending',
    });
  }
}