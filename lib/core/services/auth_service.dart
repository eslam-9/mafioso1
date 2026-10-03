import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  Future<void> signInAnonymouslyIfNeeded() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        AppLogger.logInfo('[AuthService] No active session. Signing in anonymously...');
        await _supabase.auth.signInAnonymously();
        AppLogger.logInfo('[AuthService] Signed in anonymously successfully.');
      } else {
        AppLogger.logInfo('[AuthService] Active session found.');
      }
    } catch (e, st) {
      AppLogger.logError('[AuthService] Failed to sign in anonymously', e, stackTrace: st);
    }
  }

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Session? get currentSession => _supabase.auth.currentSession;
}
