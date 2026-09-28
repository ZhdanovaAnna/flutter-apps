import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/bmi_record.dart';

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  User? get currentUser => client.auth.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) {
    return client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
      },
    );
  }

  String get firstName {
    final value = currentUser?.userMetadata?['first_name'];
    return value is String ? value : '';
  }

  String get lastName {
    final value = currentUser?.userMetadata?['last_name'];
    return value is String ? value : '';
  }

  String get email => currentUser?.email ?? '';

  Future<List<BmiRecord>> getHistory() async {
    final user = currentUser;
    if (user == null) return const [];

    final data = await client
        .from('body_mass_index_calculations')
        .select(
          'id, created_at, height, weight, body_mass_index, recommendation',
        )
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return data
        .map((row) => BmiRecord.fromMap(row))
        .toList(growable: false);
  }

  Future<BmiRecord> saveBmi({
    required double heightCm,
    required double weightKg,
    required double bmi,
    required String recommendation,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('Пользователь не авторизован');
    }

    final row = await client
        .from('body_mass_index_calculations')
        .insert({
          'user_id': user.id,
          'height': heightCm.round(),
          'weight': weightKg.round(),
          'body_mass_index': bmi,
          'recommendation': recommendation,
        })
        .select(
          'id, created_at, height, weight, body_mass_index, recommendation',
        )
        .single();

    return BmiRecord.fromMap(row);
  }

  Future<void> signOut() => client.auth.signOut();
}
