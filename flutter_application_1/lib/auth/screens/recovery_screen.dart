import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: success ? Colors.green : AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _sendReset() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Введите корректный email.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      setState(() => _sent = true);
      _showSnack('Письмо отправлено! Проверьте почту.', success: true);
    } catch (e) {
      _showSnack('Ошибка. Попробуйте ещё раз.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ── Фон ────────────────────────────────────────────────────────
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _SimpleBgPainter(),
          ),

          // ── Контент ────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Кнопка назад
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppTheme.textDark,
                          size: 28,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Иконка
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        color: AppTheme.primary,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Заголовок
                    const Text(
                      'Восстановление пароля',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Введите email и мы отправим\nссылку для сброса пароля',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Карточка с формой
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                            const Text(
                              'Электронная почта',
                              style: TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),

                            TextField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !_sent,
                              style: const TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'example@mail.com',
                                hintStyle: const TextStyle(
                                  color: AppTheme.textHint,
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(
                                  Icons.mail_outline,
                                  color: AppTheme.textHint,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: _sent
                                    ? AppTheme.background
                                    : Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppTheme.border,
                                    width: 1.2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppTheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppTheme.border,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Кнопка
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: (_isLoading || _sent)
                                    ? null
                                    : _sendReset,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: _sent
                                      ? Colors.green
                                      : AppTheme.primary.withOpacity(0.6),
                                  disabledForegroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        _sent
                                            ? '✓ Письмо отправлено'
                                            : 'Отправить письмо',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Вернуться к входу
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Вернуться к авторизации',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Простой фон ───────────────────────────────────────────────────────────────

class _SimpleBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F8F0), Color(0xFFF5EEF8), Color(0xFFFEF0E8)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Круги
    for (final c in [
      [0.0, 0.1, 130.0, 0xFFB2DFDB, 0.2],
      [size.width + 0.0, 0.15, 110.0, 0xFFFFCCBC, 0.18],
      [-20.0, size.height * 0.7, 100.0, 0xFFE1BEE7, 0.2],
      [size.width + 0.0, size.height * 0.85, 120.0, 0xFFB2DFDB, 0.18],
    ]) {
      canvas.drawCircle(
        Offset(c[0] as double, c[1] as double),
        c[2] as double,
        Paint()..color = Color(c[3] as int).withOpacity(c[4] as double),
      );
    }
  }

  @override
  bool shouldRepaint(_SimpleBgPainter old) => false;
}
