import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../screens/login_tab.dart';
import '../screens/register_tab.dart';
import '../../core/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthController _controller = AuthController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  String get _title =>
      _tabController.index == 0 ? 'Регистрация' : 'Авторизация';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Пастельный фон ────────────────────────────────────────────────
          const _PastelBackground(),

          // ── Контент ───────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _title,
                          key: ValueKey(_title),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: AppTheme.textMuted,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(text: 'Регистрация'),
                          Tab(text: 'Авторизация'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          RegisterTab(
                            controller: _controller,
                            onGoToLogin: () => _tabController.animateTo(1),
                          ),
                          LoginTab(
                            controller: _controller,
                            onGoToRegister: () => _tabController.animateTo(0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Пастельный фон ────────────────────────────────────────────────────────────

class _PastelBackground extends StatelessWidget {
  const _PastelBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _PastelPainter(),
    );
  }
}

class _PastelPainter extends CustomPainter {
  // Цвета
  static const mint = Color(0xFFB2DFDB);
  static const peach = Color(0xFFFFCCBC);
  static const lavend = Color(0xFFE1BEE7);
  static const mintD = Color(0xFF80CBC4);
  static const peachD = Color(0xFFFFAB91);
  static const lavendD = Color(0xFFCE93D8);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Градиентный фон ──────────────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F8F0),
            Color(0xFFF5EEF8),
            Color(0xFFFEF0E8),
            Color(0xFFF8EEF5),
          ],
          stops: [0.0, 0.35, 0.70, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // ── Блобы ────────────────────────────────────────────────────────────────
    _blob(canvas, -30, h * 0.11, 160, 130, -20, mint, 0.22);
    _blob(canvas, w + 30, h * 0.17, 150, 120, 15, peach, 0.20);
    _blob(canvas, w * 0.5, h * 0.5, 200, 160, 10, lavend, 0.15);
    _blob(canvas, -20, h * 0.71, 140, 110, -10, peach, 0.18);
    _blob(canvas, w + 20, h * 0.83, 160, 130, 20, mint, 0.20);
    _blob(canvas, w * 0.47, h * 0.95, 180, 100, 0, lavend, 0.18);

    // ── Волны ────────────────────────────────────────────────────────────────
    _wave(canvas, w, h, h * 0.31, mint, 0.3);
    _wave(canvas, w, h, h * 0.57, peach, 0.28);
    _wave(canvas, w, h, h * 0.8, lavend, 0.25);

    // ── Кольца ───────────────────────────────────────────────────────────────
    _ring(canvas, 52, h * 0.17, 36, mintD, 0.45);
    _ring(canvas, w - 50, h * 0.37, 28, peachD, 0.40);
    _ring(canvas, 60, h * 0.63, 22, lavendD, 0.38);
    _ring(canvas, w - 30, h * 0.71, 30, mintD, 0.35);
    _ring(canvas, w * 0.5, h * 0.86, 24, peachD, 0.32);

    // ── Маленькие круги ───────────────────────────────────────────────────────
    _fill(canvas, w * 0.82, h * 0.09, 38, peach, 0.28);
    _fill(canvas, w * 0.82, h * 0.09, 22, peachD, 0.20);
    _fill(canvas, -10, h * 0.46, 44, mint, 0.22);
    _fill(canvas, w + 10, h * 0.60, 36, lavend, 0.25);
    _fill(canvas, w * 0.4, h * 0.97, 50, peach, 0.18);

    // ── Точки ────────────────────────────────────────────────────────────────
    for (final d in [
      [w * 0.26, h * 0.07, 3.0, mintD, 0.6],
      [w * 0.53, h * 0.04, 2.5, peachD, 0.55],
      [w * 0.76, h * 0.14, 2.0, lavendD, 0.5],
      [w * 0.95, h * 0.26, 3.0, mintD, 0.45],
      [w * 0.05, h * 0.36, 2.5, peachD, 0.55],
      [w * 0.66, h * 0.44, 2.0, lavendD, 0.5],
      [w * 0.34, h * 0.54, 3.0, mintD, 0.45],
      [w * 0.97, h * 0.51, 2.5, peachD, 0.5],
      [w * 0.21, h * 0.76, 2.0, lavendD, 0.45],
      [w * 0.74, h * 0.80, 3.0, mintD, 0.5],
      [w * 0.11, h * 0.91, 2.5, peachD, 0.45],
      [w * 0.89, h * 0.88, 2.0, lavendD, 0.5],
    ]) {
      _fill(
        canvas,
        d[0] as double,
        d[1] as double,
        d[2] as double,
        d[3] as Color,
        d[4] as double,
      );
    }

    // ── Сердечки ──────────────────────────────────────────────────────────────
    _heart(canvas, 26, h * 0.23, 13, mintD, 0.55);
    _heart(canvas, w - 22, h * 0.27, 11, peachD, 0.50);
    _heart(canvas, w * 0.37, h * 0.37, 10, lavendD, 0.45);
    _heart(canvas, w - 18, h * 0.60, 12, mintD, 0.42);
    _heart(canvas, 20, h * 0.80, 10, peachD, 0.45);
    _heart(canvas, w * 0.63, h * 0.60, 11, lavendD, 0.40);
    _heart(canvas, w * 0.82, h * 0.88, 10, mintD, 0.38);
  }

  void _blob(
    Canvas canvas,
    double cx,
    double cy,
    double rx,
    double ry,
    double angleDeg,
    Color color,
    double opacity,
  ) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angleDeg * 3.14159 / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
      Paint()..color = color.withOpacity(opacity),
    );
    canvas.restore();
  }

  void _wave(
    Canvas canvas,
    double w,
    double h,
    double y,
    Color color,
    double opacity,
  ) {
    final path = Path()
      ..moveTo(0, y)
      ..quadraticBezierTo(w * 0.25, y - 40, w * 0.5, y)
      ..quadraticBezierTo(w * 0.75, y + 40, w, y)
      ..lineTo(w, y + 110)
      ..quadraticBezierTo(w * 0.75, y + 70, w * 0.5, y + 110)
      ..quadraticBezierTo(w * 0.25, y + 150, 0, y + 110)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withOpacity(opacity));
  }

  void _ring(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Color color,
    double opacity,
  ) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withOpacity(opacity);
    canvas.drawCircle(Offset(cx, cy), r, p);
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.62,
      p
        ..strokeWidth = 0.7
        ..color = color.withOpacity(opacity * 0.6),
    );
  }

  void _fill(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Color color,
    double opacity,
  ) {
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = color.withOpacity(opacity),
    );
  }

  void _heart(
    Canvas canvas,
    double cx,
    double cy,
    double s,
    Color color,
    double opacity,
  ) {
    final path = Path()
      ..moveTo(cx, cy + s * 0.6)
      ..cubicTo(
        cx - s * 1.2,
        cy - s * 0.2,
        cx - s * 1.2,
        cy - s,
        cx,
        cy - s * 0.3,
      )
      ..cubicTo(
        cx + s * 1.2,
        cy - s,
        cx + s * 1.2,
        cy - s * 0.2,
        cx,
        cy + s * 0.6,
      );
    canvas.drawPath(path, Paint()..color = color.withOpacity(opacity));
  }

  @override
  bool shouldRepaint(_PastelPainter old) => false;
}
