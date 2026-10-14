import 'package:flutter/material.dart';

import '../widgets/lesson_muscle_link.dart';

import '../data/drive_lesson_data.dart';
import '../data/illustrated_lesson_data.dart';
import '../data/lesson_timing_data.dart';
import '../data/shot_route_data.dart';
import '../widgets/shot_route_card.dart';
import '../services/progress_service.dart';
import '../data/skill_data.dart';
import 'ai_coach_screen.dart';
import '../widgets/drive_pose_diagram.dart';

/// Deliberately isolated pilot: session-only checks, no auth/API/progress changes.
class DriveLessonScreen extends StatefulWidget {
  const DriveLessonScreen({super.key});

  @override
  State<DriveLessonScreen> createState() => _DriveLessonScreenState();
}

class _DriveLessonScreenState extends State<DriveLessonScreen> {
  int _step = 0;
  int _sets = 0;
  final Set<int> _visited = {0};
  bool _saved = false, _saving = false;
  final List<bool> _checks = List.filled(driveSelfChecks.length, false);
  bool _preloaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_preloaded) return;
    _preloaded = true;
    for (final asset in driveCharacterAssets) {
      precacheImage(
        ResizeImage(AssetImage(asset), width: 512),
        context,
        onError: (error, stack) => debugPrint('平球圖解預載失敗：$error'),
      );
    }
  }

  void _changeStep(int index) {
    if (index < 0 || index >= driveLessonSteps.length || index == _step) return;
    setState(() {
      _step = index;
      _visited.add(index);
    });
  }

  Future<void> _markRead() async {
    if (_saving || _saved || _visited.length != 4) return;
    setState(() => _saving = true);
    try {
      await ProgressService.markCompleted('平球');
      if (mounted) setState(() => _saved = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('閱讀紀錄暫時無法儲存，請稍後再試。')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _panel({required String title, required List<Widget> children}) =>
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      );

  Widget _comparison(bool wrong) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        wrong ? '避免：引拍拉到身後' : '建議：短距離引拍',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: wrong ? const Color(0xFF994D25) : const Color(0xFF1B5E20),
        ),
      ),
      const SizedBox(height: 8),
      DrivePoseDiagram(pose: DrivePose.backswing, largeBackswing: wrong),
      const SizedBox(height: 8),
      Text(wrong ? '幅度太大，較難及時準備下一球。' : '保留身前空間，快速擊球、收拍。'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final step = driveLessonSteps[_step];
    return Scaffold(
      appBar: AppBar(title: const Text('平球｜圖解教學')),
      body: SingleChildScrollView(
        key: const ValueKey('drive-lesson-scroll'),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '短引拍，快收拍',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '看懂四個步驟，再試一組慢速練習。',
              style: TextStyle(height: 1.5, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            _panel(
              title: '看四個步驟',
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(
                    driveLessonSteps.length,
                    (i) => ChoiceChip(
                      key: ValueKey('drive-step-$i'),
                      label: Text('${i + 1} ${['準備', '引拍', '擊球', '回位'][i]}'),
                      showCheckmark: false,
                      selected: _step == i,
                      onSelected: (_) => _changeStep(i),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DrivePoseDiagram(
                  key: ValueKey('drive-diagram-$_step'),
                  pose: step.pose,
                ),
                const SizedBox(height: 8),
                const Text(
                  '點放大鏡看細節；橘色箭頭表示出球方向',
                  style: TextStyle(color: Color(0xFF805512), fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_step + 1}/4 · ${step.title}',
                  key: const ValueKey('drive-current-step'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(step.cue, style: const TextStyle(height: 1.5)),
                ),
                const SizedBox(height: 12),
                Text(
                  '為什麼重要：${lessonFor('平球').steps[_step].why}',
                  style: const TextStyle(height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  '避免：${lessonFor('平球').steps[_step].avoid}',
                  style: const TextStyle(height: 1.5),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      key: const ValueKey('drive-previous'),
                      onPressed: _step == 0
                          ? null
                          : () => _changeStep(_step - 1),
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('上一步'),
                    ),
                    FilledButton.icon(
                      key: const ValueKey('drive-next'),
                      onPressed: _step == 3
                          ? null
                          : () => _changeStep(_step + 1),
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('下一步'),
                    ),
                  ],
                ),
              ],
            ),
            _panel(
              title: '這一拍打去哪裡？',
              children: [ShotRouteCard(route: shotRoutes['drive']!)],
            ),
            _panel(
              title: '擊球點與發力時機',
              children: [
                Text(
                  '擊球點：${lessonTiming['drive']!.contact}',
                  style: const TextStyle(height: 1.6),
                ),
                const SizedBox(height: 12),
                Text(
                  '準備／引拍放鬆：${lessonTiming['drive']!.relax}',
                  style: const TextStyle(height: 1.6),
                ),
                const SizedBox(height: 12),
                Text(
                  '何時發力：${lessonTiming['drive']!.power}',
                  style: const TextStyle(height: 1.6),
                ),
              ],
            ),
            _panel(
              title: '只比較一個常見錯誤',
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 520) {
                      return Column(
                        children: [
                          _comparison(false),
                          const SizedBox(height: 20),
                          _comparison(true),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _comparison(false)),
                        const SizedBox(width: 20),
                        Expanded(child: _comparison(true)),
                      ],
                    );
                  },
                ),
              ],
            ),
            const LessonMuscleLink(skillName: '平球'),
            const SizedBox(height: 12),
            _panel(
              title: '試一個短練習',
              children: [
                const Text(
                  drivePracticeInstructions,
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  drivePracticeSafety,
                  style: TextStyle(color: Color(0xFF6D532D), height: 1.5),
                ),
                const SizedBox(height: 16),
                Text('本次完成 $_sets/3 組', key: const ValueKey('drive-set-count')),
                const SizedBox(height: 8),
                FilledButton.icon(
                  key: const ValueKey('drive-record-set'),
                  onPressed: _sets == 3 ? null : () => setState(() => _sets++),
                  icon: const Icon(Icons.check),
                  label: Text(_sets == 3 ? '先休息，檢查動作' : '我已練完一組'),
                ),
              ],
            ),
            _panel(
              title: '練完自我檢查',
              children: [
                ...List.generate(
                  driveSelfChecks.length,
                  (i) => CheckboxListTile(
                    key: ValueKey('drive-check-$i'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(driveSelfChecks[i]),
                    value: _checks[i],
                    onChanged: (value) =>
                        setState(() => _checks[i] = value ?? false),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _checks.every((checked) => checked)
                      ? '檢查完成！下次拍攝時，留意這三件事。這不是動作評分或已掌握的認證。'
                      : '勾選自己實際做到的項目，不必一次全做到。',
                  key: const ValueKey('drive-check-feedback'),
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
            _panel(
              title: '想了解自己的動作？',
              children: [
                const Text(
                  '先檢查短引拍、身前觸球與快收拍，再拍攝完整身體與球拍。AI 結果是規則式參考，不取代教練。',
                  style: TextStyle(height: 1.6),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => AiCoachScreen(
                        initialSkill: badmintonSkills.firstWhere(
                          (s) => s.name == '平球',
                        ),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.video_camera_back_outlined),
                  label: const Text('選取影片，分析平球'),
                ),
              ],
            ),
            _panel(
              title: '記下這次閱讀',
              children: [
                Text('已查看 ${_visited.length}/4 個步驟。全部查看後，可自行標記教材已讀。'),
                const SizedBox(height: 8),
                FilledButton.icon(
                  key: const ValueKey('drive-mark-read'),
                  onPressed: _saving || _saved || _visited.length != 4
                      ? null
                      : _markRead,
                  icon: const Icon(Icons.bookmark_outline),
                  label: Text(
                    _saved
                        ? '已記錄教材已讀'
                        : _saving
                        ? '正在儲存'
                        : '標記教材已讀',
                  ),
                ),
                const Text('只存於這台裝置，不代表動作已掌握，不影響帳號分析紀錄。'),
              ],
            ),
            const Text(
              '組數與勾選只保留在本次頁面，離開後重設；只有自行按下「標記教材已讀」才記錄本機閱讀。',
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              '圖解為右手正手的幅度與位置示意，不是精確握拍或前臂旋轉模型。',
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              '教學概念參考：Sikana 正手平球；圖解尚需教練校正。',
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
