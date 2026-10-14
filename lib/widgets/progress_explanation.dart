import 'package:flutter/material.dart';

class ProgressExplanation extends StatelessWidget {
  const ProgressExplanation({super.key});
  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '進步趨勢怎麼看？',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            '只比較目前帳號已成功儲存、且屬於所選技術與評分版本的 AI 總分，按分析日期排序；預設選最近一筆紀錄的版本，不混合新舊版本。\n\n最新：所選版本最後一筆總分。\n變化：同版本最新減上一筆；只有一筆時顯示 —。\n最佳：所選版本的最高總分。\n長條：各筆總分／100，不是完成率。',
            style: TextStyle(height: 1.6),
          ),
          SizedBox(height: 8),
          Text(
            '分數上升不等於實戰能力或肌力一定進步。新版比較人工標記階段的固定時間影格，不是完整揮拍評分；舊版區間曾取最高分。請比較相同分析方式、持拍側、拍攝角度、動作階段與評分版本；不同條件及舊版分數不宜直接比較。',
            style: TextStyle(height: 1.6),
          ),
          SizedBox(height: 8),
          Text(
            '沒看到資料？確認登入同一帳號、選擇正確技術，並確認曾出現「分析紀錄已安全儲存」。只有分析、尚未按儲存，不會加入趨勢。',
            style: TextStyle(height: 1.6),
          ),
        ],
      ),
    ),
  );
}
