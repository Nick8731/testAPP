import 'package:flutter/material.dart';

class AppGuideScreen extends StatelessWidget {
  const AppGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '使用指南與資料說明',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        children: const [
          _GuideHeader(),
          SizedBox(height: 18),
          _GuideSection(
            icon: Icons.route_outlined,
            title: '建議使用流程',
            items: [
              '1. 先從技術訓練了解動作重點與常見錯誤。',
              '2. 到戰術學院理解站位與擊球選擇。',
              '3. 拍攝自己的動作，使用 AI 教練選擇正確技術分析。',
              '4. 登入後儲存分析，從歷史與進步趨勢比較變化。',
            ],
          ),
          _GuideSection(
            icon: Icons.videocam_outlined,
            title: '拍攝清楚，分析才有意義',
            items: [
              '全身、球拍手與雙腳都要留在畫面內。',
              '手機固定在側面或斜側面，避免跟著球員晃動。',
              '保持光線充足，避免人物與背景顏色過度接近。',
              '一次影片以一種技術為主，並選取真正動作發生的區間。',
            ],
          ),
          _GuideSection(
            icon: Icons.analytics_outlined,
            title: '如何理解 AI 分數',
            items: [
              '目前採用姿勢關節角度與第一版規則式評分。',
              '分數適合比較自己在相似拍攝條件下的變化。',
              '不同角度、光線與遮擋都可能影響結果，不宜比較不同球員。',
              '它是訓練提示，不取代現場教練、醫療或正式生物力學診斷。',
            ],
          ),
          _GuideSection(
            icon: Icons.privacy_tip_outlined,
            title: '資料與隱私',
            items: [
              '選取的影片用於裝置上的姿勢分析；App 不會自動上傳原始影片。',
              '只有登入並按下「儲存分析紀錄」後，分數與文字建議才會送到後台。',
              '分析紀錄依帳號隔離，可在分析詳情中自行刪除。',
              '正式部署時應使用 HTTPS，並妥善保護帳號密碼與 JWT 設定。',
            ],
          ),
        ],
      ),
    );
  }
}

class _GuideHeader extends StatelessWidget {
  const _GuideHeader();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xFF123524),
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.sports_tennis, color: Colors.white, size: 34),
        SizedBox(height: 12),
        Text(
          '把每一次分析，變成下一次訓練的方向。',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            height: 1.35,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'SmashCoach 將技術、戰術、發力與動作分析放在同一條學習路徑。',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
      ],
    ),
  );
}

class _GuideSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _GuideSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 14),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1B5E20)),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(text, style: const TextStyle(height: 1.5)),
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
