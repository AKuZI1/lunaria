import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../chat_tile.dart';
import '../chat_model.dart';
import '../screens/chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  static final _client = Supabase.instance.client;

  bool _isLoading = true;
  List<ChatModel> _chats = [];
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadMatches();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _pollMatches(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await _fetchChats();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _pollMatches() async {
    if (!mounted) return;
    await _fetchChats();
  }

  Future<void> _fetchChats() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final res = await _client
          .from('matches')
          .select('id, user1_id, user2_id')
          .or('user1_id.eq.$userId,user2_id.eq.$userId');

      if (!mounted) return;

      final List<ChatModel> chats = [];

      for (final match in res as List) {
        if (!mounted) return;

        final partnerId = match['user1_id'] == userId
            ? match['user2_id']
            : match['user1_id'];

        final userRes = await _client
            .from('users')
            .select('full_name, age, avatar_url')
            .eq('id', partnerId)
            .maybeSingle();

        if (!mounted) return;
        if (userRes == null) continue;

        final msgRes = await _client
            .from('messages')
            .select('content')
            .eq('match_id', match['id'])
            .order('sent_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (!mounted) return;

        final unreadRes = await _client
            .from('messages')
            .select('id')
            .eq('match_id', match['id'])
            .eq('is_read', false)
            .neq('sender_id', userId);

        if (!mounted) return;

        chats.add(
          ChatModel(
            id: match['id'],
            name: userRes['full_name'] ?? 'Пользователь',
            age: userRes['age'] ?? 0,
            lastMessage: msgRes != null
                ? msgRes['content'] as String
                : 'Начните общение!',
            avatarUrl: userRes['avatar_url'],
            unreadCount: (unreadRes as List).length,
            isOnline: false,
          ),
        );
      }

      if (!mounted) return;
      setState(() => _chats = chats);
    } catch (e) {
      debugPrint('Ошибка загрузки чатов: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          // ✅ Ограничиваем ширину как на мобиле
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Заголовок ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Чаты',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _loadMatches,
                        icon: const Icon(
                          Icons.refresh,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Список ──────────────────────────────────────────
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        )
                      : _chats.isEmpty
                      ? _emptyState()
                      : RefreshIndicator(
                          onRefresh: _loadMatches,
                          color: AppTheme.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 16),
                            itemCount: _chats.length,
                            itemBuilder: (context, index) {
                              final chat = _chats[index];
                              return ChatTile(
                                name: chat.name,
                                age: chat.age,
                                lastMessage: chat.lastMessage,
                                avatarUrl: chat.avatarUrl,
                                unreadCount: chat.unreadCount,
                                isOnline: chat.isOnline,
                                onTap: () =>
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                          name: chat.name,
                                          matchId: chat.id,
                                          avatarUrl: chat.avatarUrl,
                                          isOnline: chat.isOnline,
                                        ),
                                      ),
                                    ).then((_) {
                                      if (mounted) _loadMatches();
                                    }),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          const Text(
            'Пока нет совпадений',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Свайпай — и здесь появятся чаты',
            style: TextStyle(color: AppTheme.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
