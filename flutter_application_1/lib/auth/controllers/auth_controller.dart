import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_form_data.dart';

class AuthController {
  final AuthFormData formData = AuthFormData();
  static final _client = Supabase.instance.client;

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ── Вход ──────────────────────────────────────────────────────────────────
  Future<String?> login() async {
    final validErr = formData.loginError;
    if (validErr != null) return validErr;

    try {
      await _client.auth.signInWithPassword(
        email: formData.email.trim(),
        password: formData.password,
      );
      return null;
    } on AuthException catch (e) {
      switch (e.statusCode) {
        case '400':
          return 'Неверный email или пароль.';
        case '422':
          return 'Некорректные данные.';
        case '429':
          return 'Слишком много попыток. Подождите минуту.';
        default:
          return 'Ошибка входа: ${e.message}';
      }
    } catch (_) {
      return 'Неизвестная ошибка. Попробуйте ещё раз.';
    }
  }

  // ── Регистрация ───────────────────────────────────────────────────────────
  Future<String?> register() async {
    final validErr = formData.registerError;
    if (validErr != null) return validErr;

    try {
      final res = await _client.auth.signUp(
        email: formData.email.trim(),
        password: formData.password,
      );

      if (res.user == null) return 'Не удалось создать аккаунт.';

      await _client.auth.signInWithPassword(
        email: formData.email.trim(),
        password: formData.password,
      );

      await _client.from('users').upsert({
        'id': res.user!.id,
        'email': formData.email.trim(),
        'full_name': formData.name.trim(),
        'age': formData.age,
        'gender': formData.gender,
        'city': formData.city.trim(),
        'password_hash': _hashPassword(formData.password),
      });

      return null;
    } on AuthException catch (e) {
      switch (e.statusCode) {
        case '400':
          return 'Этот email уже зарегистрирован.';
        case '422':
          return 'Пароль должен быть не менее 6 символов.';
        case '429':
          return 'Слишком много попыток. Подождите 1-2 минуты.';
        default:
          if (e.message.contains('already registered')) {
            return 'Этот email уже зарегистрирован.';
          }
          return 'Ошибка регистрации: ${e.message}';
      }
    } catch (_) {
      return 'Неизвестная ошибка. Попробуйте ещё раз.';
    }
  }

  void dispose() => formData.reset();
}
