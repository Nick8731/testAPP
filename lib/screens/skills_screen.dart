import 'package:flutter/material.dart';

import '../data/training_catalog.dart';
import '../data/illustrated_lesson_data.dart';
import '../data/shot_route_data.dart';
import '../services/progress_service.dart';
import '../test/test_skill.dart';
import 'skill_detail_screen.dart';
import 'beginner_grip_screen.dart';
import '../data/beginner_course_data.dart';
import '../widgets/beginner_course_tile.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});
  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final _search = TextEditingController();
  bool _problems = false;
  bool _showAll = false;
  TrainingGroup? _group;
  TrainingProblem? _problem;
  Set<String> _read = {};
  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    try {
      final values = await Future.wait(
        [
          ...trainingSkills.map((s) => s.name),
          beginnerCourseName,
        ].map(ProgressService.getProgress),
      );
      if (!mounted) return;
      setState(
        () => _read = {
          for (var i = 0; i < trainingSkills.length; i++)
            if (values[i] == 100) trainingSkills[i].name,
          if (values.last == 100) beginnerCourseName,
        },
      );
    } catch (error) {
      debugPrint('本機教材閱讀紀錄暫不可用：$error');
    }
  }

  Future<void> _open(BadmintonSkill skill) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => SkillDetailScreen(skill: skill)),
    );
    if (mounted) await _loadProgress();
  }

  List<BadmintonSkill> get _filtered {
    final q = _search.text.trim().toLowerCase();
    final problemMatches = trainingProblems
        .where((p) => '${p.title} ${p.explanation}'.toLowerCase().contains(q))
        .expand((p) => p.skills)
        .toSet();
    return trainingSkills.where((s) {
      final route = shotRoutes[lessonFor(s.name).key]!;
      final matches =
          q.isEmpty ||
          '${s.name} ${s.englishName} ${s.description} ${groupFor(s.name).name} ${route.from} ${route.to}'
              .toLowerCase()
              .contains(q) ||
          problemMatches.contains(s.name);
      return matches &&
          (_group == null || _group!.skills.contains(s.name)) &&
          (_problem == null || _problem!.skills.contains(s.name));
    }).toList();
  }

  bool get _showBeginner {
    final q = _search.text.trim().toLowerCase();
    return (_group == null || _group!.name == '入門與步法') &&
        _problem == null &&
        (q.isEmpty ||
            '$beginnerCourseName $beginnerCourseKeywords'
                .toLowerCase()
                .contains(q));
  }

  Future<void> _openBeginner() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const BeginnerGripScreen()),
    );
    if (mounted) await _loadProgress();
  }

  Widget _title(String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.black54, height: 1.5),
        ),
      ],
    ),
  );
  Widget _groupCard(TrainingGroup group, double width) => SizedBox(
    width: width,
    child: Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: _group == group ? const Color(0xFFE1EEDB) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() {
          _group = _group == group ? null : group;
          _problem = null;
        }),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Icon(
                    _group == group ? Icons.check_circle : Icons.arrow_outward,
                    size: 18,
                    color: const Color(0xFF386547),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                group.hint,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '${group.skills.length + (group.name == "入門與步法" ? 1 : 0)} 課',
                style: const TextStyle(fontSize: 12, color: Color(0xFF386547)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final showCourses =
        _showAll ||
        _group != null ||
        _problem != null ||
        _search.text.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(title: const Text('技術訓練')),
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        child: ListView(
          key: const ValueKey('training-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF123524),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '從看懂一拍開始',
                    style: TextStyle(
                      color: Color(0xFFCDE0C5),
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '知道怎麼打\n也知道為什麼',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '右手持拍示範 · 動漫分解圖 · 球路與擊球點',
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              key: const ValueKey('training-search'),
              controller: _search,
              onChanged: (_) => setState(() {
                _showAll = false;
                _group = null;
                _problem = null;
              }),
              decoration: InputDecoration(
                hintText: '搜尋技術或問題，例如：吊球、打不遠',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: '清除搜尋',
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('training-all-courses'),
              onPressed: () => setState(() {
                _showAll = !_showAll;
                _search.clear();
                _group = null;
                _problem = null;
              }),
              icon: Icon(
                _showAll ? Icons.grid_view_outlined : Icons.menu_book_outlined,
              ),
              label: Text(
                _showAll ? '回到分類' : '全部課程（${trainingSkills.length + 1} 課）',
              ),
            ),
            const SizedBox(height: 12),
            if (!_showAll)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    key: const ValueKey('training-by-area'),
                    label: const Text('依場上情境'),
                    selected: !_problems,
                    showCheckmark: false,
                    onSelected: (_) => setState(() {
                      _problems = false;
                      _group = null;
                      _problem = null;
                    }),
                  ),
                  ChoiceChip(
                    key: const ValueKey('training-by-problem'),
                    label: const Text('從問題找課程'),
                    selected: _problems,
                    showCheckmark: false,
                    onSelected: (_) => setState(() {
                      _problems = true;
                      _group = null;
                      _problem = null;
                    }),
                  ),
                ],
              ),
            if (_search.text.trim().isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('搜尋結果直接列在下方；搜尋不會自動判定你的動作問題。'),
              )
            else if (!_showAll && _problems) ...[
              _title('你常遇到哪個問題？', '這是自我排查入口，不是 AI 診斷；先選一個問題。'),
              ...trainingProblems
                  .where((p) => _problem == null || _problem == p)
                  .map(
                    (p) => Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      color: _problem == p
                          ? const Color(0xFFE1EEDB)
                          : Colors.white,
                      child: ListTile(
                        key: ValueKey('problem-${trainingProblems.indexOf(p)}'),
                        title: Text(
                          p.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            p.explanation,
                            style: const TextStyle(height: 1.5),
                          ),
                        ),
                        trailing: Icon(
                          _problem == p
                              ? Icons.check_circle
                              : Icons.chevron_right,
                        ),
                        onTap: () => setState(() {
                          _problem = _problem == p ? null : p;
                          _group = null;
                        }),
                      ),
                    ),
                  ),
            ] else if (!_showAll) ...[
              _title('先選場上情境', '分類依你要處理的來球位置，不只分基礎／進階。'),
              if (_group != null)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: trainingGroups
                      .map(
                        (g) => ChoiceChip(
                          label: Text(g.name),
                          selected: _group == g,
                          onSelected: (_) =>
                              setState(() => _group = _group == g ? null : g),
                        ),
                      )
                      .toList(),
                )
              else
                LayoutBuilder(
                  builder: (context, c) {
                    final columns =
                        c.maxWidth < 350 ||
                            MediaQuery.textScalerOf(context).scale(16) > 22
                        ? 1
                        : 2;
                    final width = (c.maxWidth - (columns - 1) * 12) / columns;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: trainingGroups
                          .map((g) => _groupCard(g, width))
                          .toList(),
                    );
                  },
                ),
            ],
            if (_group != null || _problem != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _group = null;
                    _problem = null;
                  }),
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('取消分類／問題篩選'),
                ),
              ),
            if (showCourses) ...[
              _title(
                _problem?.title ?? _group?.name ?? '全部課程',
                '${filtered.length + (_showBeginner ? 1 : 0)} 課 · 入門先握拍，動作課再看球路與分解步驟',
              ),
              if (filtered.isEmpty && !_showBeginner)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('沒有符合的課程。試試「發球、網前、打不遠」，或取消篩選。'),
                  ),
                ),
              if (_showBeginner)
                BeginnerCourseTile(
                  read: _read.contains(beginnerCourseName),
                  onTap: _openBeginner,
                ),
              ...filtered.map((s) {
                final lesson = lessonFor(s.name),
                    route = shotRoutes[lesson.key]!;
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  child: InkWell(
                    key: ValueKey('training-course-${s.name}'),
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _open(s),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 72,
                            height: 92,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDF3EA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              lesson.assetAt(0),
                              cacheWidth: 128,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.sports_tennis),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${groupFor(s.name).name} · ${s.level}${_read.contains(s.name) ? ' · 教材已讀' : ''}',
                                  style: const TextStyle(
                                    color: Color(0xFF386547),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${route.from} → ${route.to}',
                                  style: const TextStyle(height: 1.5),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${lesson.steps.length} 張分解圖 · ${lesson.key.startsWith('serve') ? '教學課程／未提供 AI 評分' : '含動作排查'}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF386547),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: const Color(0xFFF0F2E8),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '先知道的三件事',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '握拍：正手通常使用 V 型握拍；身前基本反手使用拇指支撐。兩種握法要能放鬆轉換，不是握死同一種。\n\n'
                      '放鬆：肩頸與手指放鬆，不代表軀幹沒有支撐。觸球時只短暫加強控制，之後再放鬆。\n\n'
                      '學習順序：先握拍與小步移動，再練放網、挑球及發球；掌握頭頂擊球後再練殺球與切吊。',
                      style: TextStyle(height: 1.6),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '圖片是階段示意，精細握拍與旋轉需教練校正。疼痛時停止練習；本機教材已讀不等於動作已掌握。',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
