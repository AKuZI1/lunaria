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
    } catch (e) {
      debugPrint('Ошибка загрузки пользователей: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSwipe(String direction) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null || _currentIndex >= _users.length) return;

    final toUserId = _users[_currentIndex].id;
    try {
      await _client.from('swipes').upsert({
        'from_user_id': myId,
        'to_user_id': toUserId,
        'direction': direction,
      }, onConflict: 'from_user_id,to_user_id');
    } catch (e) {
      debugPrint('Ошибка сохранения свайпа: $e');
    }
  }

  bool get _isEmpty => _currentIndex >= _users.length;

  Future<void> _onLike() async {
    await _saveSwipe('like');
    if (!mounted) return;
    setState(() => _currentIndex++);
  }

  Future<void> _onDislike() async {
    await _saveSwipe('dislike');
    if (!mounted) return;
    setState(() => _currentIndex++);
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : _isEmpty
                  ? _emptyState()
                  : _cardContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardContent(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (_currentIndex + 1 < _users.length)
              Transform.scale(
                scale: 0.95,
                child: Opacity(
                  opacity: 0.6,
                  child: Container(
                    width: screenW * 0.88,
                    height: screenH * 0.46,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            SwipeCard(
              user: _users[_currentIndex],
              onLike: _onLike,
              onDislike: _onDislike,
            ),
          ],
        ),
        const SizedBox(height: 20),
        ActionButtons(onDislike: _onDislike, onLike: _onLike),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Container(
                  height: 58,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}
