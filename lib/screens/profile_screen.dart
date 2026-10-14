import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'app_guide_screen.dart';
import 'analysis_history_screen.dart';
import 'login_screen.dart';
import 'progress_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loggingOut = false;

  Future<bool> _ensureLogin() async {
    final auth = AuthService.instance;
    final cachedUser = auth.currentUser;
    if (cachedUser != null) return true;

    if (await auth.isLoggedIn) {
      try {
        await auth.getCurrentUser();
        return true;
      } on ApiException catch (error) {
        if (error.statusCode == 401) {
          await auth.logout();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(error.toString())));
          }
          return false;
        }
      }
    }

    if (!mounted) return false;
    final loggedIn = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    if (loggedIn != true || !mounted) return false;

    final loggedInUser = auth.currentUser ?? await auth.getCurrentUser();
    if (!mounted) return false;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('登入成功，歡迎 ${loggedInUser.name}')));
    return true;
  }

  Future<void> _open(Widget screen) async {
    if (!await _ensureLogin() || !mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      await AuthService.instance.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已登出')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('登出失敗：$error')));
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ValueListenableBuilder<AppUser?>(
        valueListenable: AuthService.instance.currentUserChanges,
        builder: (context, user, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppPalette.ink,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: AppPalette.lime,
                      child: Icon(
                        Icons.person,
                        size: 38,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user == null ? '你的訓練空間' : '已登入',
                            style: const TextStyle(
                              color: AppPalette.lime,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user?.name ?? '尚未登入',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '登入後同步 AI 分析紀錄',
                            style: const TextStyle(
                              color: Color(0xFFD3DFD8),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<String?>(
                valueListenable: AuthService.instance.sessionMessage,
                builder: (context, message, _) => message == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(message),
                      ),
              ),
              _Option(
                icon: user == null ? Icons.login : Icons.logout,
                title: user == null ? '登入 / 註冊' : (_loggingOut ? '登出中…' : '登出'),
                subtitle: user == null ? '建立帳號，保存你的分析結果' : '登出不會刪除已儲存的分析',
                onTap: () async {
                  if (user == null) {
                    await _ensureLogin();
                  } else {
                    await _logout();
                  }
                },
              ),
              const SizedBox(height: 12),
              const Text(
                '我的分析',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                '回顧練習，再決定下一步。',
                style: TextStyle(color: AppPalette.muted),
              ),
              const SizedBox(height: 14),
              _Option(
                icon: Icons.history,
                title: 'AI 分析紀錄',
                subtitle: '查看每次分析的分數與改善建議',
                onTap: () => _open(const AnalysisHistoryScreen()),
              ),
              _Option(
                icon: Icons.trending_up,
                title: '進步趨勢',
                subtitle: '比較相同技術、相同評分版本的紀錄',
                onTap: () => _open(const ProgressScreen()),
              ),
              _Option(
                icon: Icons.help_outline,
                title: '使用指南與資料說明',
                subtitle: '了解操作方式、評分限制與資料保存',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppGuideScreen()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Option({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: Icon(icon, color: const Color(0xFF1B5E20)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          subtitle,
          style: const TextStyle(
            color: AppPalette.muted,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward, size: 19),
      onTap: onTap,
    ),
  );
}
