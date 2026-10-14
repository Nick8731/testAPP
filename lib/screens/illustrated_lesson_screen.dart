import 'package:flutter/material.dart';

import '../widgets/lesson_muscle_link.dart';

import '../data/illustrated_lesson_data.dart';
import '../data/lesson_timing_data.dart';
import '../data/lesson_contact_points.dart';
import '../data/shot_route_data.dart';
import '../widgets/shot_route_card.dart';
import '../services/progress_service.dart';
import '../data/skill_data.dart';
import 'ai_coach_screen.dart';
import '../widgets/lesson_character_figure.dart';

class IllustratedLessonScreen extends StatefulWidget {
  final IllustratedLesson lesson;
  const IllustratedLessonScreen({super.key, required this.lesson});
  @override
  State<IllustratedLessonScreen> createState() =>
      _IllustratedLessonScreenState();
}

class _IllustratedLessonScreenState extends State<IllustratedLessonScreen> {
  int _step = 0, _sets = 0;
  final Set<int> _visited = {0};
  bool _saving = false, _saved = false;
  late final List<bool> _checks = List.filled(
    widget.lesson.checks.length,
    false,
  );
  void _select(int i) {
    if (i < 0 || i >= widget.lesson.steps.length || i == _step) return;
    setState(() {
      _step = i;
      _visited.add(i);
    });
  }

  Future<void> _markRead() async {
    if (_saving || _saved || _visited.length != widget.lesson.steps.length) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ProgressService.markCompleted(widget.lesson.skillName);
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

  Widget _panel(String title, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
  Widget _cue(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(height: 1.6)),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson, step = lesson.steps[_step];
    final timing = lessonTiming[lesson.key]!;
    final contacting = timing.contactStep == _step;
    return Scaffold(
      appBar: AppBar(title: Text('${lesson.skillName}｜動漫圖解')),
      body: SingleChildScrollView(
        key: const ValueKey('lesson-scroll'),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.variant,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(lesson.goal, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 16),
            _panel('先確認基礎', [
              Text(lesson.prerequisite, style: const TextStyle(height: 1.5)),
            ]),
            _panel('這一拍打去哪裡？', [
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  '${shotRoutes[lesson.key]!.from} → ${shotRoutes[lesson.key]!.to}',
                ),
                subtitle: const Text('點開看球場、方向與常見落點'),
                children: [ShotRouteCard(route: shotRoutes[lesson.key]!)],
              ),
            ]),
            if (lesson.key == 'slice' || lesson.key == 'drop')
              _panel('切球與吊球，差在哪？', const [
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text('吊球是球路，切球是擊球方式'),
                  children: [
                    Text(
                      '吊球描述後場打向前場的球路；一般吊球靠控制最後加速和拍面。切球描述斜向擦擊的方式，可用於切吊等變化，因此不是「落在不同格」就一定是切球。',
                      style: TextStyle(height: 1.6),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '本課把一般吊球與正手一般切吊分開。先把一般吊球打穩，再學擦擊；單張全身圖無法驗證精細拍面旋轉。',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ]),
            _panel('一張一個步驟', [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(
                  lesson.steps.length,
                  (i) => ChoiceChip(
                    key: ValueKey('lesson-step-$i'),
                    label: Text('${i + 1} ${lesson.steps[i].title}'),
                    showCheckmark: false,
                    selected: i == _step,
                    onSelected: (_) => _select(i),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              LessonCharacterFigure(
                key: ValueKey('${lesson.key}-figure-$_step'),
                asset: lesson.assetAt(_step),
                title: step.title,
                contact: contacting,
                contactPoint: lessonContactPoints[lesson.key],
                strokeDirection: lessonStrokeDirections[lesson.key],
              ),
              const SizedBox(height: 12),
              Text(
                '${_step + 1}/${lesson.steps.length} · ${step.title}',
                key: const ValueKey('lesson-current-step'),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _cue('怎麼做', step.how),
              _cue('為什麼重要', step.why),
              _cue('避免', step.avoid),
              _cue(
                '現在的放鬆與發力',
                contacting
                    ? timing.power
                    : _step < timing.contactStep
                    ? '${timing.relax} ${(['clear', 'smash'].contains(lesson.key) && _step == timing.contactStep - 1) ? '此步已開始轉體帶拍，接近觸球才集中加速；不是完全不用力。' : '現在先做本步驟，不提前用最大力量。'}'
                    : timing.contactStep == -1
                    ? timing.power
                    : '觸球已完成，恢復放鬆，順勢減速、收拍與回位；不要持續握死拍柄。',
              ),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const ValueKey('lesson-previous'),
                    onPressed: _step == 0 ? null : () => _select(_step - 1),
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('上一步'),
                  ),
                  FilledButton.icon(
                    key: const ValueKey('lesson-next'),
                    onPressed: _step == lesson.steps.length - 1
                        ? null
                        : () => _select(_step + 1),
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('下一步'),
                  ),
                ],
              ),
            ]),
            _panel('擊球點與發力時機', [
              _cue(lesson.key == 'split' ? '觀察對手觸球' : '擊球點在哪裡', timing.contact),
              _cue('架拍／準備：哪些部位放鬆', timing.relax),
              _cue('什麼時候發力', timing.power),
              if (timing.contactStep >= 0)
                TextButton.icon(
                  key: const ValueKey('lesson-show-contact'),
                  onPressed: () => _select(timing.contactStep),
                  icon: const Icon(Icons.my_location),
                  label: const Text('切換到觸球示意'),
                ),
            ]),
            LessonMuscleLink(skillName: lesson.skillName),
            const SizedBox(height: 12),
            _panel('試一個短練習', [
              Text(lesson.drill, style: const TextStyle(height: 1.6)),
              const SizedBox(height: 10),
              const Text(
                '先熱身並確認周圍有足夠空間。慢速、低強度練習；有疼痛或不適就停止。',
                style: TextStyle(color: Color(0xFF79552D), height: 1.5),
              ),
              const SizedBox(height: 12),
              Text('本次完成 $_sets/3 組'),
              FilledButton(
                onPressed: _sets == 3 ? null : () => setState(() => _sets++),
                child: Text(_sets == 3 ? '先休息並檢查動作' : '我已練完一組'),
              ),
            ]),
            _panel(
              '練完自我檢查',
              List.generate(
                _checks.length,
                (i) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(lesson.checks[i]),
                  value: _checks[i],
                  onChanged: (v) => setState(() => _checks[i] = v ?? false),
                ),
              ),
            ),
            _panel('記下這次閱讀', [
              Text(
                '已查看 ${_visited.length}/${lesson.steps.length} 個步驟。全部查看後，可自行標記教材已讀。',
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const ValueKey('lesson-mark-read'),
                onPressed:
                    _saving || _saved || _visited.length != lesson.steps.length
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
              const SizedBox(height: 8),
              const Text(
                '只儲存於這台裝置，不表示動作已掌握，也不影響帳號 AI 分析資料。',
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
            ]),
            _panel('想了解自己的動作？', [
              const Text(
                '先用本課自我檢查找一個重點，再拍攝完整身體與球拍的動作。AI 結果是規則式參考，不取代教練；全身圖也不能驗證握拍細節。',
                style: TextStyle(height: 1.6),
              ),
              if (badmintonSkills.any((s) => s.name == lesson.skillName))
                OutlinedButton.icon(
                  key: const ValueKey('lesson-open-ai'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => AiCoachScreen(
                        initialSkill: badmintonSkills.firstWhere(
                          (s) => s.name == lesson.skillName,
                        ),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.video_camera_back_outlined),
                  label: const Text('選取影片，分析這項技術'),
                )
              else
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    lesson.key.startsWith('serve_')
                        ? '這項發球課程目前只提供教學與自我檢查，尚未提供 AI 評分。'
                        : '本課目前只提供教學與自我檢查，尚未提供 AI 評分。',
                  ),
                ),
            ]),
            _panel('教材與使用限制', [
              const Text(
                '動漫圖片用來辨認動作階段，不是精確握拍、關節角度或前臂旋轉模型。教材經資料核對，尚未經現場教練逐張驗證；請勿把插圖當成個人動作評分。',
                style: TextStyle(height: 1.6),
              ),
              const SizedBox(height: 8),
              Text('參考：${lesson.sources.join('；')}'),
              const SizedBox(height: 8),
              const Text('組數與勾選只保留於本次頁面，離開後重設，不代表已掌握，也不更動帳號分析紀錄。'),
            ]),
          ],
        ),
      ),
    );
  }
}
