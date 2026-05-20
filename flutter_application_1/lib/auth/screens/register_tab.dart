import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  bool _cityValid = false;
  bool _cityChecking = false;

  List<String> _citySuggestions = [];

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

  // ── Поиск городов через API ────────────────────────────────────────────────
  Future<void> _searchCity(String query) async {
    if (query.length < 2) {
      setState(() {
        _citySuggestions = [];
        _cityValid = false;
        widget.controller.formData.city = '';
      });
      return;
    }

    setState(() => _cityChecking = true);

    try {
      // Используем бесплатный GeoDB Cities API
      final uri = Uri.parse(
        'https://wft-geo-db.p.rapidapi.com/v1/geo/cities'
        '?namePrefix=${Uri.encodeComponent(query)}'
        '&limit=5&languageCode=ru',
      );

      final res = await http.get(
        uri,
        headers: {
          'x-rapidapi-host': 'wft-geo-db.p.rapidapi.com',
          'x-rapidapi-key': 'DEMO', // бесплатный ключ с лимитом
        },
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final cities = (data['data'] as List)
            .map((c) => '${c['name']}, ${c['country']}')
            .toList();
        setState(() => _citySuggestions = List<String>.from(cities));
      } else {
        // Fallback — проверяем по локальному списку популярных городов
        _searchLocalCities(query);
      }
    } catch (_) {
      if (!mounted) return;
      _searchLocalCities(query);
    } finally {
      if (mounted) setState(() => _cityChecking = false);
    }
  }

  // ── Локальный список городов (fallback) ───────────────────────────────────
  void _searchLocalCities(String query) {
    final q = query.toLowerCase();
    final matches = _popularCities
        .where((c) => c.toLowerCase().startsWith(q))
        .take(5)
        .toList();
    setState(() => _citySuggestions = matches);
  }

  void _selectCity(String city) {
    _cityCtrl.text = city;
    widget.controller.formData.city = city;
    setState(() {
      _cityValid = true;
      _citySuggestions = [];
    });
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
    if (!_cityValid && _cityCtrl.text.isNotEmpty) {
      _showSnack('Выберите город из списка.');
      return;
    }
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

            // Город с автодополнением
            _label('Город'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _cityCtrl,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14,
                  ),
                  onChanged: (v) {
                    setState(() => _cityValid = false);
                    widget.controller.formData.city = '';
                    _searchCity(v);
                  },
                  decoration: InputDecoration(
                    hintText: 'Например: Москва',
                    hintStyle: const TextStyle(
                      color: AppTheme.textHint,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.textHint,
                      size: 20,
                    ),
                    suffixIcon: _cityChecking
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : _cityValid
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _cityValid ? Colors.green : AppTheme.border,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _cityValid ? Colors.green : AppTheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                // Список подсказок
                if (_citySuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: _citySuggestions.map((city) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _selectCity(city),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: AppTheme.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  city,
                                  style: const TextStyle(
                                    color: AppTheme.textDark,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
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

// ── Список популярных городов (fallback без интернета) ────────────────────────
const List<String> _popularCities = [
  'Москва',
  'Санкт-Петербург',
  'Новосибирск',
  'Екатеринбург',
  'Казань',
  'Нижний Новгород',
  'Челябинск',
  'Самара',
  'Омск',
  'Ростов-на-Дону',
  'Уфа',
  'Красноярск',
  'Пермь',
  'Воронеж',
  'Волгоград',
  'Краснодар',
  'Саратов',
  'Тюмень',
  'Тольятти',
  'Ижевск',
  'Барнаул',
  'Ульяновск',
  'Иркутск',
  'Хабаровск',
  'Владивосток',
  'Ярославль',
  'Махачкала',
  'Томск',
  'Оренбург',
  'Кемерово',
  'Новокузнецк',
  'Рязань',
  'Астрахань',
  'Набережные Челны',
  'Пенза',
  'Липецк',
  'Киров',
  'Чебоксары',
  'Тула',
  'Калининград',
  'Брянск',
  'Курск',
  'Иваново',
  'Магнитогорск',
  'Улан-Удэ',
  'Сочи',
  'Сургут',
  'Чита',
  'Минск',
  'Алматы',
  'Астана',
  'Киев',
  'Ташкент',
  'Баку',
  'Тбилиси',
  'Ереван',
];
