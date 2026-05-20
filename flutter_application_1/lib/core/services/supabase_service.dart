import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // ─── Авторизация ──────────────────────────────────────────────────────────────
  static Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return res.user;
    } on AuthException {
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── Регистрация ──────────────────────────────────────────────────────────────
  static Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(email: email, password: password);
      return res.user;
    } on AuthException {
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── Выход ────────────────────────────────────────────────────────────────────
  static Future<void> logOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }

  // ─── Сброс пароля ─────────────────────────────────────────────────────────────
  static Future<bool> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Текущий пользователь ─────────────────────────────────────────────────────
  static User? get currentUser => _client.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;
}
