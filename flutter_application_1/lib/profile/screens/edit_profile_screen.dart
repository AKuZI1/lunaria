import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static final _client = Supabase.instance.client;

  final _nameCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _avatarUrl;

  static const int _maxAbout = 500;
  static const int _maxInterests = 3;

  // Все доступные интересы
  static const List<String> _allInterests = [
    'Путешествия',
    'Музыка',
    'Кино',
    'Горы',
    'Спорт',
    'Кулинария',
    'Фотография',
    'Чтение',
    'Игры',
    'Танцы',
    'Йога',
    'Природа',
    'Искусство',
    'Технологии',
    'Животные',
    'Кофе',
  ];

  List<String> _selectedInterests = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _aboutCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final userRes = await _client
          .from('users')
          .select('full_name, age, avatar_url')
          .eq('id', userId)
          .single();

      final profileRes = await _client
          .from('profiles')
          .select('about, interests')
          .eq('user_id', userId)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        _nameCtrl.text = userRes['full_name'] ?? '';
        _ageCtrl.text = (userRes['age'] ?? '').toString();
        _avatarUrl = userRes['avatar_url'];
        _aboutCtrl.text = profileRes?['about'] ?? '';
        _selectedInterests = List<String>.from(profileRes?['interests'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else if (_selectedInterests.length < _maxInterests) {
        _selectedInterests.add(interest);
      } else {
        // Показываем подсказку если уже выбрано 3
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Можно выбрать не более 3 интересов',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
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

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnack('Введите имя пользователя.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      await _client
          .from('users')
          .update({
            'full_name': _nameCtrl.text.trim(),
            'age': int.tryParse(_ageCtrl.text) ?? 0,
          })
          .eq('id', userId);

      await _client.from('profiles').upsert({
        'user_id': userId,
        'about': _aboutCtrl.text.trim(),
        'interests': _selectedInterests,
      }, onConflict: 'user_id');

      if (!mounted) return;
      _showSnack('Сохранено!', success: true);
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Ошибка сохранения: $e');
      if (!mounted) return;
      _showSnack('Ошибка сохранения.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Имя пользователя'),
                  const SizedBox(height: 8),
                  _nameField(),
                  const SizedBox(height: 20),

                  _label('О себе'),
                  const SizedBox(height: 8),
                  _aboutField(),
                  const SizedBox(height: 20),

                  _label('Возраст'),
                  const SizedBox(height: 8),
                  _ageField(),
                  const SizedBox(height: 20),

                  // ── Интересы ──────────────────────────────────────
                  Row(
                    children: [
                      _label('Интересы'),
                      const SizedBox(width: 8),
                      Text(
                        '(${_selectedInterests.length}/$_maxInterests)',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _interestsGrid(),
                  const SizedBox(height: 32),

                  // ── Кнопка сохранить ──────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.primary.withOpacity(
                          0.6,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Сохранить',
                              style: TextStyle(
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
        ],
      ),
    );
  }

  // ── Сетка интересов ───────────────────────────────────────────────

  Widget _interestsGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allInterests.map((interest) {
        final isSelected = _selectedInterests.contains(interest);
        return GestureDetector(
          onTap: () => _toggleInterest(interest),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.border,
                width: 1.2,
              ),
            ),
            child: Text(
              interest,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Шапка ────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB39DDB), Color(0xFFCE93D8)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Редактировать профиль',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              ProfileAvatar(
                imageUrl: _avatarUrl,
                size: 90,
                onUploaded: (url) => setState(() => _avatarUrl = url),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Поля ─────────────────────────────────────────────────────────

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      color: AppTheme.textDark,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _nameField() => _inputContainer(
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              hintText: 'Имя пользователя',
              hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 14),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 14),
          child: Icon(Icons.person_outline, color: AppTheme.textHint, size: 20),
        ),
      ],
    ),
  );

  Widget _aboutField() => _inputContainer(
    child: Column(
      children: [
        TextField(
          controller: _aboutCtrl,
          maxLines: 5,
          maxLength: _maxAbout,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: InputBorder.none,
            counterText: '',
            hintText:
                'Расскажите о себе, своих интересах,\nлюбимой музыке, фильмах, книгах\nи всём, что важно для вас.',
            hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 14, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_aboutCtrl.text.length}/$_maxAbout',
              style: const TextStyle(color: AppTheme.textHint, fontSize: 11),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _ageField() => _inputContainer(
    child: TextField(
      controller: _ageCtrl,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: InputBorder.none,
        hintText: 'Возраст',
        hintStyle: TextStyle(color: AppTheme.textHint, fontSize: 14),
      ),
    ),
  );

  Widget _inputContainer({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border, width: 1.2),
    ),
    child: child,
  );
}
