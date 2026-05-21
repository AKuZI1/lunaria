// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ChatTile extends StatelessWidget {
  final String name;
  final int age;
  final String lastMessage;
  final String? avatarUrl;
  final int unreadCount;
  final bool isOnline;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.age,
    required this.lastMessage,
    required this.onTap,
    this.avatarUrl,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  // Насыщенные цвета аватара
  static const _colors = [
    Color(0xFFAB47BC), // фиолетовый
    Color(0xFF26A69A), // бирюзовый
    Color(0xFFEF5350), // красный
    Color(0xFF42A5F5), // синий
    Color(0xFF66BB6A), // зелёный
    Color(0xFFFF7043), // оранжевый
    Color(0xFFEC407A), // розовый
    Color(0xFF7E57C2), // лавандовый
  ];

  Color _avatarColor() => _colors[name.codeUnitAt(0) % _colors.length];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Аватар ─────────────────────────────────────────────
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: _avatarColor(),
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: avatarUrl == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // ── Текст ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name, $age',
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unreadCount > 0
                          ? AppTheme.textDark
                          : AppTheme.textMuted,
                      fontSize: 13,
                      fontWeight: unreadCount > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Бейдж / стрелка ─────────────────────────────────────
            if (unreadCount > 0)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textHint,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
