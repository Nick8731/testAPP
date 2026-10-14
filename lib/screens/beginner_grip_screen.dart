import 'package:flutter/material.dart';

import '../data/beginner_course_data.dart';
import '../data/training_catalog.dart';
import '../services/progress_service.dart';
import 'skill_detail_screen.dart';
import '../widgets/grip_handle_guide.dart';

class BeginnerGripScreen extends StatefulWidget {
  const BeginnerGripScreen({super.key});
  @override
  State<BeginnerGripScreen> createState() => _BeginnerGripScreenState();
}

class _BeginnerGripScreenState extends State<BeginnerGripScreen> {
  int _step = 0;
  final Set<int> _visited = {0};
  bool _saving = false, _saved = false;
  bool _preloaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_preloaded) return;
    _preloaded = true;
    for (final asset in beginnerGripAssets) {
      precacheImage(
        ResizeImage(AssetImage(asset), width: 512),
        context,
        onError: (_, _) {},
      );
    }
  }

  void _select(int i) => setState(() {
    _step = i;
    _visited.add(i);
  });
  Future<void> _markRead() async {
    if (_saving || _saved || _visited.length != gripLessonSteps.length) return;
    setState(() => _saving = true);
    try {
      await ProgressService.markCompleted(beginnerCourseName);
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

  Widget _section(String title, String body) => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 9),
          Text(body, style: const TextStyle(height: 1.65)),
        ],
      ),
    ),
  );
  Widget _picture(int index) => Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: Image.asset(
                beginnerGripAssets[index],
                fit: BoxFit.contain,
                cacheWidth: 512,
                errorBuilder: (_, _, _) =>
                    const Center(child: Text('示意圖暫時無法載入，請參考文字步驟。')),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                key: ValueKey('grip-enlarge-$index'),
                tooltip: '放大握拍示意',
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(gripLessonSteps[index].title),
                          const SizedBox(height: 12),
                          Flexible(
                            child: InteractiveViewer(
                              minScale: 1,
                              maxScale: 3,
                              child: Image.asset(
                                beginnerGripAssets[index],
                                fit: BoxFit.contain,
                                cacheWidth: 1024,
                              ),
                            ),
                          ),
                          TextButton(
                            key: const ValueKey('grip-close-enlarged'),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('關閉'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                icon: const Icon(Icons.zoom_in),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Text(
        index == 0 ? '看拇指與食指的 V 型關係，不是用掌心握成拳頭。' : '看拇指順著拍桿的支撐方向；只示範身前基本反手。',
        style: const TextStyle(color: Color(0xFF48654B), height: 1.5),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final step = gripLessonSteps[_step];
    return Scaffold(
      appBar: AppBar(title: const Text(beginnerCourseName)),
      body: ListView(
        key: const ValueKey('grip-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF123524),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '先握得對，再學會換',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '右手持拍入門｜三段靜態教學\n本課沒有 AI 握拍評分，也不是肌力診斷。',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(
              gripLessonSteps.length,
              (i) => ChoiceChip(
                key: ValueKey('grip-step-$i'),
                label: Text('${i + 1} ${['正手 V 型', '身前反手', '放鬆與換握'][i]}'),
                showCheckmark: false,
                selected: _step == i,
                onSelected: (_) => _select(i),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_step + 1}/3 · ${step.title}',
            key: const ValueKey('grip-current-step'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(step.scope, style: const TextStyle(height: 1.6)),
          const SizedBox(height: 14),
          if (_step < 2)
            _picture(_step)
          else ...[
            _picture(0),
            const SizedBox(height: 12),
            const Icon(Icons.swap_vert),
            const SizedBox(height: 12),
            _picture(1),
          ],
          const SizedBox(height: 14),
          const Text(
            '動漫近景是教學示意，不能用來量測精確虎口角度、手指壓力或替代教練校正。請拿自己的球拍配合下面步驟檢查，不硬扭成圖片角度。',
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
          const GripHandleGuide(),
          _section('怎麼握／怎麼換', step.how),
          _section('為什麼重要', step.why),
          _section('先避免這些錯誤', step.avoid),
          _section(
            '試一個短練習',
            '${step.exercise}\n\n確認周圍有空間；手腕、拇指或手肘疼痛、麻木時停止，不勉強做力量訓練。',
          ),
          _section('拿自己的拍子檢查', step.checkpoints.map((s) => '• $s').join('\n')),
          _section(
            '拍柄與握法不是一個死角度',
            '八面拍柄有平面與斜面。V 型握拍是入門基本握法；身前反手可用拇指支撐。擊球在身旁、身後或後場時，可能需要不同斜面及調整，後場反手高遠球請另由教練示範。不要用一張拇指圖套用所有反手。',
          ),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '記下這次閱讀',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('已查看 ${_visited.length}/3 段。看完後可自行標記教材已讀。'),
                  FilledButton.icon(
                    key: const ValueKey('grip-mark-read'),
                    onPressed: _saving || _saved || _visited.length != 3
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
                  const Text(
                    '只保存在本機，不表示握拍已掌握，也不影響帳號 AI 分析紀錄。',
                    style: TextStyle(color: Colors.black54, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          ExpansionTile(
            title: const Text('下一步練什麼？'),
            children: ['啟動步', '放網', '挑球', '反手短發球']
                .map(
                  (name) => ListTile(
                    title: Text(name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => SkillDetailScreen(
                          skill: trainingSkills.firstWhere(
                            (s) => s.name == name,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            '教學概念參考 BWF Shuttle Time 教師手冊的握拍與換握；圖片尚需教練逐張驗證，沒有影片播放器或背景動畫。',
            style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}
