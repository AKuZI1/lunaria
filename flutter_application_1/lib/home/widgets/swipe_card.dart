import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/swipe_model.dart';

class SwipeCard extends StatefulWidget {
  final SwipeModel user;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final double width;
  final double height;

  const SwipeCard({
    super.key,
    required this.user,
    required this.onLike,
    required this.onDislike,
    this.width = 340,
    this.height = 460,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  double _dragX = 0;
  bool _isDragging = false;

  static const double _threshold = 100;

  void _onPanUpdate(DragUpdateDetails d) => setState(() {
    _dragX += d.delta.dx;
    _isDragging = true;
  });

  void _onPanEnd(DragEndDetails _) {
    if (_dragX > _threshold) {
      widget.onLike();
    } else if (_dragX < -_threshold) {
      widget.onDislike();
    } else {
      setState(() => _dragX = 0);
    }
    setState(() => _isDragging = false);
  }

  double get _rotation => _dragX * 0.002;
  double get _opacity => (_dragX.abs() / _threshold).clamp(0.0, 1.0);
  bool get _isLiking => _dragX > 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: Offset(_dragX, 0),
        child: Transform.rotate(
          angle: _rotation,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Фото / placeholder ──────────────────────────────
                  widget.user.avatarUrl != null
                      ? Image.network(
                          widget.user.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),

                  // ── Градиент снизу ──────────────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Имя и город ─────────────────────────────────────
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.user.name}, ${widget.user.age}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.user.city.isNotEmpty)
                          Text(
                            widget.user.city,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Иконка сердца (всегда) ──────────────────────────
                  Positioned(
                    bottom: 20,
                    right: 16,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.pink.shade300,
                      size: 28,
                    ),
                  ),

                  // ── Цветной оверлей при свайпе ──────────────────────
                  if (_isDragging && _opacity > 0.05)
                    Container(
                      color: _isLiking
                          ? Colors.green.withOpacity(_opacity * 0.35)
                          : Colors.red.withOpacity(_opacity * 0.35),
                    ),

                  // ── Иконка ЛАЙК (сердечко) при свайпе вправо ────────
                  if (_isDragging && _isLiking && _opacity > 0.2)
                    Positioned(
                      top: 24,
                      left: 20,
                      child: Opacity(
                        opacity: _opacity.clamp(0.0, 1.0),
                        child: Transform.rotate(
                          angle: -0.3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green, width: 3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.favorite,
                                  color: Colors.green,
                                  size: 28,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'ЛАЙК',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ── Иконка НOPE (крестик) при свайпе влево ───────────
                  if (_isDragging && !_isLiking && _opacity > 0.2)
                    Positioned(
                      top: 24,
                      right: 20,
                      child: Opacity(
                        opacity: _opacity.clamp(0.0, 1.0),
                        child: Transform.rotate(
                          angle: 0.3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red, width: 3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.close, color: Colors.red, size: 28),
                                SizedBox(width: 6),
                                Text(
                                  'НOPE',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppTheme.primaryLight,
    child: const Center(
      child: Icon(Icons.person, size: 100, color: AppTheme.primary),
    ),
  );
}
