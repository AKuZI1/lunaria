import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final String matchId;

  const ChatScreen({
    super.key,
    required this.name,
    required this.matchId,
    this.avatarUrl,
    this.isOnline = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static final _client = Supabase.instance.client;

  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  Timer? _pollTimer;

  String get _myId => _client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _pollMessages(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final res = await _client
          .from('messages')
          .select('id, content, sender_id, sent_at, is_read')
          .eq('match_id', widget.matchId)
          .order('sent_at', ascending: true);

      if (!mounted) return;
      setState(() {
        _messages = List<Map<String, dynamic>>.from(res);
        _isLoading = false;
      });
      await _markAsRead();
      _scrollToBottom();
    } catch (e) {
      debugPrint('Ошибка загрузки: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pollMessages() async {
    if (!mounted) return;
    try {
      final res = await _client
          .from('messages')
          .select('id, content, sender_id, sent_at, is_read')
          .eq('match_id', widget.matchId)
          .order('sent_at', ascending: true);

      if (!mounted) return;
      final newMessages = List<Map<String, dynamic>>.from(res);
      if (newMessages.length != _messages.length) {
        setState(() => _messages = newMessages);
        await _markAsRead();
        _scrollToBottom();
      }
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();

    final tempMsg = {
      'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'content': text,
      'sender_id': _myId,
      'sent_at': DateTime.now().toIso8601String(),
      'is_read': false,
    };

    if (!mounted) return;
    setState(() => _messages.add(tempMsg));
    _scrollToBottom();

    try {
      final res = await _client
          .from('messages')
          .insert({
            'match_id': widget.matchId,
            'sender_id': _myId,
            'content': text,
            'is_read': false,
          })
          .select('id, content, sender_id, sent_at, is_read')
          .single();

      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m['id'] == tempMsg['id']);
        if (idx != -1) _messages[idx] = Map<String, dynamic>.from(res);
      });
    } catch (e) {
      debugPrint('Ошибка отправки: $e');
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m['id'] == tempMsg['id']);
      });
    }
  }

  Future<void> _markAsRead() async {
    try {
      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('match_id', widget.matchId)
          .neq('sender_id', _myId)
          .eq('is_read', false);
    } catch (_) {}
  }

  // ── Удалить только сообщения, матч остаётся ───────────────────────────────
  Future<void> _deleteChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Удалить переписку?',
          style: TextStyle(color: AppTheme.textDark),
        ),
        content: const Text(
          'Все сообщения будут удалены. Совпадение останется.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      // ✅ Удаляем только сообщения — матч остаётся
      await _client.from('messages').delete().eq('match_id', widget.matchId);

      if (!mounted) return;
      setState(() => _messages = []);
    } catch (e) {
      debugPrint('Ошибка удаления: $e');
    }
  }

  // ── Заблокировать пользователя ────────────────────────────────────────────
  Future<void> _blockUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Заблокировать ${widget.name}?',
          style: const TextStyle(color: AppTheme.textDark),
        ),
        content: const Text(
          'Пользователь не сможет писать вам сообщения.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Заблокировать',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      // Удаляем матч и сообщения при блокировке
      await _client.from('messages').delete().eq('match_id', widget.matchId);

      await _client.from('matches').delete().eq('id', widget.matchId);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Ошибка блокировки: $e');
    }
  }

  // ── Меню ──────────────────────────────────────────────────────────────────
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: Text(
                'Заблокировать ${widget.name}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _blockUser();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Удалить переписку',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _deleteChat();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: AppTheme.textMuted),
              title: const Text(
                'Отмена',
                style: TextStyle(color: AppTheme.textMuted),
              ),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _ChatAppBar(
            name: widget.name,
            avatarUrl: widget.avatarUrl,
            isOnline: widget.isOnline,
            onBack: () => Navigator.pop(context),
            onMenu: _showMenu,
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Начните общение!',
                      style: TextStyle(color: AppTheme.textHint, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['sender_id'] == _myId;
                      final time = _formatTime(msg['sent_at'] as String);
                      return ChatBubble(
                        text: msg['content'] as String,
                        isMe: isMe,
                        time: time,
                        isRead: msg['is_read'] as bool? ?? false,
                      );
                    },
                  ),
          ),
          ChatInput(controller: _inputController, onSend: _sendMessage),
        ],
      ),
    );
  }

  String _formatTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final VoidCallback onBack;
  final VoidCallback onMenu;

  const _ChatAppBar({
    required this.name,
    required this.avatarUrl,
    required this.isOnline,
    required this.onBack,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.background,
          border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.chevron_left,
                color: AppTheme.textDark,
                size: 28,
              ),
            ),
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryLight,
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: avatarUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 22,
                          color: AppTheme.primary,
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isOnline ? 'онлайн' : 'не в сети',
                    style: TextStyle(
                      color: isOnline
                          ? const Color(0xFF4CAF50)
                          : AppTheme.textHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onMenu,
              icon: const Icon(
                Icons.more_horiz,
                color: AppTheme.textMuted,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
