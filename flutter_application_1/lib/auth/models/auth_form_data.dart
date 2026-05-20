class AuthFormData {
  String name = '';
  String email = '';
  String password = '';
  String city = '';
  int? age;
  String? gender;

  // ── Валидация регистрации ─────────────────────────────────────────────────
  String? get registerError {
    if (name.trim().isEmpty) return 'Введите имя пользователя.';
    if (email.trim().isEmpty) return 'Введите email.';
    if (!email.contains('@')) return 'Введите корректный email.';
    if (password.isEmpty) return 'Введите пароль.';
    if (password.length < 6) return 'Пароль должен быть не менее 6 символов.';
    if (gender == null) return 'Выберите пол.';
    if (age == null) return 'Введите возраст.';
    if (age! < 18) return 'Регистрация доступна только с 18 лет.';
    if (age! > 100) return 'Введите корректный возраст.';
    if (city.trim().isEmpty) return 'Введите город.';
    return null;
  }

  // ── Валидация входа ───────────────────────────────────────────────────────
  String? get loginError {
    if (email.trim().isEmpty) return 'Введите email.';
    if (!email.contains('@')) return 'Введите корректный email.';
    if (password.isEmpty) return 'Введите пароль.';
    if (password.length < 6) return 'Пароль должен быть не менее 6 символов.';
    return null;
  }

  bool get isRegisterValid => registerError == null;
  bool get isLoginValid => loginError == null;

  void reset() {
    name = '';
    email = '';
    password = '';
    city = '';
    age = null;
    gender = null;
  }
}
