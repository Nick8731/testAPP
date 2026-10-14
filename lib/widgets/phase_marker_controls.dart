import 'package:flutter/material.dart';

class PhaseMarkerControls extends StatelessWidget {
  static const phases = ['準備／引拍', '揮拍／出手附近', '隨揮／回位'];
  final String phase;
  final double? second;
  final bool busy;
  final VoidCallback onMark;
  final ValueChanged<String> onPhase;
  const PhaseMarkerControls({
    super.key,
    required this.phase,
    required this.second,
    required this.busy,
    required this.onMark,
    required this.onPhase,
  });
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '先標記同一動作階段',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '播放或拖曳到你要比較的姿勢，再按標記。階段由你確認，不是 AI 自動辨認擊球瞬間；名稱不改變既有技術評分權重。',
            style: TextStyle(height: 1.5),
          ),
          DropdownButtonFormField<String>(
            initialValue: phase,
            decoration: const InputDecoration(labelText: '人工確認的階段'),
            items: phases
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: busy
                ? null
                : (p) {
                    if (p != null) onPhase(p);
                  },
          ),
          const SizedBox(height: 8),
          Text(
            second == null
                ? '尚未標記'
                : '固定比較時間：${second!.toStringAsFixed(3)} 秒（影片零點 0.1 秒格）',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const ValueKey('phase-mark'),
            onPressed: busy ? null : onMark,
            icon: const Icon(Icons.push_pin_outlined),
            label: const Text('暫停並標記這個階段'),
          ),
        ],
      ),
    ),
  );
}
