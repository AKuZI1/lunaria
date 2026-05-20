import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onDislike;
  final VoidCallback onLike;

  const ActionButtons({
    super.key,
    required this.onDislike,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── Дизлайк ───────────────────────────────────────────────────────
        GestureDetector(
          onTap: onDislike,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.close, color: Colors.grey, size: 28),
          ),
        ),

        const SizedBox(width: 32),

        // ── Лайк ──────────────────────────────────────────────────────────
        GestureDetector(
          onTap: onLike,
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 30),
          ),
        ),
      ],
    );
  }
}
