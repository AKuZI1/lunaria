import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../auth/screens/auth_screen.dart';
import '../models/swipe_model.dart';
import '../widgets/swipe_card.dart';
import '../widgets/action_buttons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final _client = Supabase.instance.client;

  int _currentIndex = 0;
  bool _isLoading = true;
  List<SwipeModel> _users = [];

  List<String> _currentPhotos = [];
  int _photoIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final myId = _client.auth.currentUser?.id;
      if (myId == null) return;

      final swipedRes = await _client
          .from('swipes')
          .select('to_user_id')
          .eq('from_user_id', myId);
      if (!mounted) return;

      final swipedIds = (swipedRes as List)
          .map((s) => s['to_user_id'] as String)
          .toList();

      final res = await _client
          .from('users')
          .select('id, full_name, age, city, avatar_url')
          .neq('id', myId);
      if (!mounted) return;

      final users = (res as List)
          .where((u) => !swipedIds.contains(u['id']))
          .map(
            (u) => SwipeModel(
              id: u['id'],
              name: u['full_name'] ?? 'Пользователь',
              age: u['age'] ?? 0,
              city: u['city'] ?? '',
              avatarUrl: u['avatar_url'],
            ),
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _users = users;
        _currentIndex = 0;
        _isLoading = false;
      });

      if (users.isNotEmpty) {
        _loadPhotos(users[0].id, users[0].avatarUrl);
      }
    } catch (e) {
      debugPrint('Ошибка загрузки: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPhotos(String userId, String? avatarUrl) async {
    try {
      final res = await _client
          .from('photos')
          .select('url')
          .eq('user_id', userId)
          .order('order', ascending: true)
          .limit(3);

      if (!mounted) return;

      final List<String> photos = [];
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        photos.add(avatarUrl);
      }
      for (final p in res as List) {
        final url = p['url'] as String?;
        if (url != null && url.isNotEmpty && !photos.contains(url)) {
          photos.add(url);
        }
      }

      setState(() {
        _currentPhotos = photos;
        _photoIndex = 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentPhotos =
            _currentIndex < _users.length &&
                _users[_currentIndex].avatarUrl != null
            ? [_users[_currentIndex].avatarUrl!]
            : [];
        _photoIndex = 0;
      });
    }
  }

  Future<void> _saveSwipe(String direction) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null || _currentIndex >= _users.length) return;
    try {
      await _client.from('swipes').upsert({
        'from_user_id': myId,
        'to_user_id': _users[_currentIndex].id,
        'direction': direction,
      }, onConflict: 'from_user_id,to_user_id');
    } catch (e) {
      debugPrint('Ошибка свайпа: $e');
    }
  }

  bool get _isEmpty => _currentIndex >= _users.length;

  Future<void> _onLike() async {
    await _saveSwipe('like');
    if (!mounted) return;
    final next = _currentIndex + 1;
    setState(() {
      _currentIndex = next;
      _currentPhotos = [];
      _photoIndex = 0;
    });
    if (next < _users.length) {
      _loadPhotos(_users[next].id, _users[next].avatarUrl);
    }
  }

  Future<void> _onDislike() async {
    await _saveSwipe('dislike');
    if (!mounted) return;
    final next = _currentIndex + 1;
    setState(() {
      _currentIndex = next;
      _currentPhotos = [];
      _photoIndex = 0;
    });
    if (next < _users.length) {
      _loadPhotos(_users[next].id, _users[next].avatarUrl);
    }
  }

  Future<void> _logout() async {
    await _client.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 20, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _logout,
                    icon: const Icon(
                      Icons.chevron_left,
                      color: AppTheme.textDark,
                      size: 28,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Знакомства',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppTheme.primary)
                    : _isEmpty
                    ? _emptyState()
                    : _cardContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardContent(BuildContext context) {
    final availH = MediaQuery.of(context).size.height;
    final cardH = (availH * 0.60).clamp(300.0, 460.0);
    const cardW = 340.0;

    // ✅ Текущее фото берётся из _currentPhotos по _photoIndex
    final displayUrl = _currentPhotos.isNotEmpty
        ? _currentPhotos[_photoIndex]
        : _users[_currentIndex].avatarUrl;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Карточка — Key меняется при смене фото, форсируя перестройку
          SizedBox(
            width: cardW,
            height: cardH,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_currentIndex + 1 < _users.length)
                  Transform.scale(
                    scale: 0.95,
                    child: Container(
                      width: cardW,
                      height: cardH,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                // ✅ ValueKey форсирует перестройку при смене фото
                SwipeCard(
                  key: ValueKey('$_currentIndex-$_photoIndex'),
                  user: _users[_currentIndex].copyWith(avatarUrl: displayUrl),
                  onLike: _onLike,
                  onDislike: _onDislike,
                  width: cardW,
                  height: cardH,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ActionButtons(onDislike: _onDislike, onLike: _onLike),

          const SizedBox(height: 16),

          // Миниатюры
          SizedBox(
            width: cardW,
            child: Row(
              children: List.generate(3, (i) {
                final hasPhoto = i < _currentPhotos.length;
                final isActive = i == _photoIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: hasPhoto
                        ? () => setState(() => _photoIndex = i)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: isActive && hasPhoto
                            ? Border.all(color: AppTheme.primary, width: 2.5)
                            : null,
                        boxShadow: isActive && hasPhoto
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(isActive ? 10 : 12),
                        child: hasPhoto
                            ? Image.network(
                                _currentPhotos[i],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _thumbPlaceholder(),
                              )
                            : _thumbPlaceholder(),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _thumbPlaceholder() => Container(
    color: AppTheme.primaryLight.withOpacity(0.7),
    child: const Center(
      child: Icon(Icons.image_outlined, color: AppTheme.primary, size: 20),
    ),
  );

  Widget _emptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.favorite_border, size: 72, color: AppTheme.textHint),
        const SizedBox(height: 16),
        const Text(
          'Больше никого нет',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Загляни позже — появятся новые люди',
          style: TextStyle(color: AppTheme.textHint, fontSize: 13),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _loadUsers, child: const Text('Обновить')),
      ],
    );
  }
}
