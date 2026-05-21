import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/message_model.dart';
import '../widgets/chat_input.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<MessageModel> _messages = const [
    MessageModel(
      id: '1',
      text: 'Привет! Хочу познакомиться с девушкой. Как лучше начать разговор?',
      isMe: true,
      time: '14:20',
      isRead: true,
    ),
    MessageModel(
      id: '2',
      text:
          'Привет! Для начала стоит начать разговор с приветствия и узнать что-то интересное. Например: "Привет! Я увидел твоё фото, ты увлечённая!"',
      isMe: false,
      time: '14:20',
    ),
    MessageModel(
      id: '3',
      text: 'А если она не отвечает долго — что делать?',
      isMe: true,
      time: '14:21',
      isRead: true,
    ),
    MessageModel(
      id: '4',
      text:
          'Подожди 1–2 дня и напиши лёгкое сообщение без давления. Например, поделись чем-то интересным или весёлым. 😄',
      isMe: false,
      time: '14:21',
    ),
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_inputController.text.trim().isEmpty) return;
    // TODO: подключить AI API
    _inputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── AppBar без кнопки назад ──────────────────────────────────
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                border: Border(
                  bottom: BorderSide(color: AppTheme.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Диалог с ИИ',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'AI-ассистент',
                        style: TextStyle(
                          color: AppTheme.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Дата ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Сегодня',
              style: TextStyle(
                color: AppTheme.textHint,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ── Сообщения ────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _AiBubble(
                  text: msg.text,
                  isMe: msg.isMe,
                  time: msg.time,
                );
              },
            ),
          ),

          // ── Ввод ────────────────────────────────────────────────────
          ChatInput(
            controller: _inputController,
            onSend: _sendMessage,
            hint: 'Написать ИИ...',
          ),
        ],
      ),
    );
  }
}

// ── Пузырёк ИИ ────────────────────────────────────────────────────────────────

class _AiBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  const _AiBubble({required this.text, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 60 : 16,
        right: isMe ? 16 : 60,
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppTheme.textDark,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppTheme.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
