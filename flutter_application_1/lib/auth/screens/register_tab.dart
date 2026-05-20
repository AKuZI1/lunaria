import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_button.dart';
import '../widgets/gender_dropdown.dart';
import '../../core/theme/app_theme.dart';

class RegisterTab extends StatefulWidget {
  final AuthController controller;
  final VoidCallback onGoToLogin;

  const RegisterTab({
    super.key,
    required this.controller,
    required this.onGoToLogin,
  });

  @override
  State<RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<RegisterTab> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(
      () => widget.controller.formData.name = _nameCtrl.text,
    );
    _emailCtrl.addListener(
      () => widget.controller.formData.email = _emailCtrl.text,
    );
    _ageCtrl.addListener(
      () => widget.controller.formData.age = int.tryParse(_ageCtrl.text),
    );
    _passCtrl.addListener(
      () => widget.controller.formData.password = _passCtrl.text,
    );
    _cityCtrl.addListener(
      () => widget.controller.formData.city = _cityCtrl.text,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    _passCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final error = await widget.controller.register();
    setState(() => _isLoading = false);
    if (error != null) {
      _showSnack(error);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        color: AppTheme.textDark,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  InputDecoration _dec(String hint, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.textHint, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Имя
            _label('Имя пользователя'),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
              decoration: _dec('Имя пользователя', Icons.person_outline),
            ),
            const SizedBox(height: 14),

            // Почта
            _label('Почта'),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
              decoration: _dec('Почта', Icons.mail_outline),
            ),
            const SizedBox(height: 14),

            // Возраст + Пол
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Возраст'),
                      TextField(
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 14,
                        ),
                        decoration: _dec('18', Icons.cake_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Пол'),
                      GenderDropdown(
                        value: widget.controller.formData.gender,
                        onChanged: (v) => setState(
                          () => widget.controller.formData.gender = v,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Город
            _label('Город'),
            TextField(
              controller: _cityCtrl,
              style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
              decoration: _dec('Например: Москва', Icons.location_on_outlined),
            ),
            const SizedBox(height: 14),

            // Пароль
            _label('Пароль'),
            TextField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
              decoration: _dec(
                'Не менее 6 символов',
                Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.textHint,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
            ),
            const SizedBox(height: 24),

            AuthButton(
              label: 'Зарегистрироваться',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Уже есть аккаунт? ',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                GestureDetector(
                  onTap: widget.onGoToLogin,
                  child: const Text(
                    'Войти',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
