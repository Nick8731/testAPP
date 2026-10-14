import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  // ============================================================
  // 取得課程進度
  // ============================================================

  static Future<int> getProgress(String skillName) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt('skill_progress_$skillName') ?? 0;
  }

  // ============================================================
  // 開始學習
  //
  // 如果原本是 0%
  // 進入課程後變成 50%
  //
  // 已經 100% 的課程不會被改回 50%
  // ============================================================

  static Future<void> markStarted(String skillName) async {
    final prefs = await SharedPreferences.getInstance();

    final current = prefs.getInt('skill_progress_$skillName') ?? 0;

    if (current == 0) {
      await prefs.setInt('skill_progress_$skillName', 50);
    }
  }

  // ============================================================
  // 完成課程
  // ============================================================

  static Future<void> markCompleted(String skillName) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('skill_progress_$skillName', 100);
  }

  // ============================================================
  // 重設單一課程
  // ============================================================

  static Future<void> resetSkill(String skillName) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('skill_progress_$skillName');
  }

  // ============================================================
  // 重設所有課程
  // ============================================================

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();

    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith('skill_progress_')) {
        await prefs.remove(key);
      }
    }
  }
}
