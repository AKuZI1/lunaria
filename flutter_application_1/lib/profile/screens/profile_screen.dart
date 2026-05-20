import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_interests.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  static final _client = Supabase.instance.client;

  bool _isLoading = true;
  String _name = '';
  int _age = 0;
  String _city = '';
  String _goal = '';
  String _about = '';
  int _matches = 0;
  int _likes = 0;
  List<String> _interests = [];
  String? _avatarUrl;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final userRes = await _client
          .from('users')
          .select('full_name, age, city, avatar_url')
          .eq('id', userId)
          .single();

      final profileRes = await _client
          .from('profiles')
          .select('interests, goal, about, matches_count, likes_count')
          .eq('user_id', userId)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        _name = userRes['full_name'] ?? '';
        _age = userRes['age'] ?? 0;
        _city = userRes['city'] ?? '';
        _avatarUrl = userRes['avatar_url'];

        if (profileRes != null) {
          _goal = profileRes['goal'] ?? '';
          _about = profileRes['about'] ?? '';
          _matches = profileRes['matches_count'] ?? 0;
          _likes = profileRes['likes_count'] ?? 0;
          _interests = List<String>.from(profileRes['interests'] ?? []);
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки профиля: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: ConstrainedBox(
          // ✅ Максимальная ширина 480px — как мобиле
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              _Header(
                name: _name,
                age: _age,
                city: _city,
                goal: _goal,
                avatarUrl: _avatarUrl,
                onAvatarUploaded: (url) => setState(() => _avatarUrl = url),
                onEdit: () => Navigator.pushNamed(
                  context,
                  '/profile/edit',
                ).then((_) => _loadProfile()),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadProfile,
                  color: AppTheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileStats(matches: _matches, likes: _likes),
                        const SizedBox(height: 20),

                        if (_about.isNotEmpty) ...[
                          _Section(
                            title: 'О себе',
                            child: Text(
                              _about,
                              style: const TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (_interests.isNotEmpty) ...[
                          _Section(
                            title: 'Интересы',
                            child: ProfileInterests(interests: _interests),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Шапка ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String name;
  final int age;
  final String city;
  final String goal;
  final String? avatarUrl;
  final VoidCallback onEdit;
  final ValueChanged<String> onAvatarUploaded;

  const _Header({
    required this.name,
    required this.age,
    required this.city,
    required this.goal,
    required this.avatarUrl,
    required this.onEdit,
    required this.onAvatarUploaded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB39DDB), Color(0xFFCE93D8)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 28),
          child: Column(
            children: [
              const Text(
                'Профиль',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ProfileAvatar(
                imageUrl: avatarUrl,
                size: 96,
                onUploaded: onAvatarUploaded,
              ),
              const SizedBox(height: 14),
              Text(
                age > 0 ? '$name, $age' : name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (city.isNotEmpty || goal.isNotEmpty)
                Text(
                  [city, goal].where((s) => s.isNotEmpty).join(' · '),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: 160,
                height: 40,
                child: ElevatedButton(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Редактировать',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Секция ────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
