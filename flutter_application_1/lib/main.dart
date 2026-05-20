import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/screens/auth_screen.dart';
import 'auth/screens/recovery_screen.dart';
import 'core/theme/app_theme.dart';
import 'home/screens/home_screen.dart';
import 'matches/screens/matches_screen.dart';
import 'matches/screens/ai_chat_screen.dart';
import 'profile/screens/profile_screen.dart';
import 'profile/screens/edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sdujdvejzjcedgbuysrg.supabase.co',
    anonKey: 'sb_publishable_kfIeE9cp1lgSJF_16uyTCQ_apQqUQf6',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dating App',
      theme: AppTheme.theme,
      home: const _SplashPage(),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const MainNavPage(),
        '/recovery': (context) => const RecoveryScreen(),
        '/profile/edit': (context) => const EditProfileScreen(),
      },
    );
  }
}

// ── Splash ────────────────────────────────────────────────────────────────────

class _SplashPage extends StatefulWidget {
  const _SplashPage();

  @override
  State<_SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<_SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF0ECF9),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF7B5EA7))),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────────────────────

class MainNavPage extends StatefulWidget {
  const MainNavPage({super.key});

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  int _index = 1;

  final Map<int, Widget> _cache = {};

  Widget _buildScreen(int index) {
    if (!_cache.containsKey(index)) {
      _cache[index] = switch (index) {
        0 => const AiChatScreen(),
        1 => const HomeScreen(),
        2 => const ChatsScreen(),
        3 => const ProfileScreen(),
        _ => const SizedBox(),
      };
    }
    return _cache[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: List.generate(4, _buildScreen),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textHint,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'Диалог ИИ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Знакомства',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Чаты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
