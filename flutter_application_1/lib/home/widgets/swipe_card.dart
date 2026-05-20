import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/swipe_model.dart';

class SwipeCard extends StatefulWidget {
  final SwipeModel user;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const SwipeCard({
    super.key,
    required this.user,
    required this.onLike,
    required this.onDislike,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  double _dragX = 0;
  bool _isDragging = false;

  // Порог свайпа
  static const double _threshold = 100;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
      _isDragging = true;
    });
  }

  void _onPanEnd(DragEndDetails details) {
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
  double get _opacity =>
      _isDragging ? (_dragX.abs() / _threshold).clamp(0, 1) : 0;
  bool get _isLiking => _dragX > 0;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: Offset(_dragX, 0),
        child: Transform.rotate(
          angle: _rotation,
          child: Stack(
            children: [
              // ── Карточка ────────────────────────────────────────────────
              Container(
                width: screenW * 0.88,
                height: screenH * 0.52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Фото
                      widget.user.avatarUrl != null
                          ? Image.network(
                              widget.user.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),

                      // Градиент снизу
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.45),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Имя, возраст, город
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.user.name}, ${widget.user.age}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.user.city,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Лайк иконка справа снизу
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.pink.shade300,
                          size: 28,
                        ),
                      ),

                      // ── Оверлей свайпа ────────────────────────────────
                      if (_isDragging)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: _isLiking
                                ? Colors.green.withOpacity(_opacity * 0.3)
                                : Colors.red.withOpacity(_opacity * 0.3),
                          ),
                        ),

                      // Лейбл ЛАЙК / НOPE
                      if (_isDragging && _opacity > 0.3)
                        Center(
                          child: Transform.rotate(
                            angle: _isLiking ? -0.4 : 0.4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _isLiking ? Colors.green : Colors.red,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _isLiking ? 'ЛАЙК' : 'НOPE',
                                style: TextStyle(
                                  color: _isLiking ? Colors.green : Colors.red,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
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
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.primaryLight,
      child: const Center(
        child: Icon(Icons.person, size: 100, color: AppTheme.primary),
      ),
    );
  }
}
