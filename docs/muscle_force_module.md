# 肌肉與發力模組規格

> 後續使用者已指定教學改為動漫分解圖，並要求對應技術訓練全部項目。本文件保留原始規格；影片時間同步的舊要求已由手動點選圖解阶段取代。現行十一項／49 階段內容及驗證見 `tactics_muscle_update.md`；AI 使用者上傳影片分析仍保留。

請先完整閱讀專案根目錄中的 `AGENTS.md`、`README.md` 與 `docs/`，理解目前 SmashCoach 專案架構。  
不要重寫或破壞目前已可運作的 Flutter 教學、影片播放、AI Pose Detection、區間分析與動作評分功能。  
這次新增一個完整的「肌肉與發力」功能模組，並預留未來與 AI 動作分析串接的架構。

## 專案背景

SmashCoach 是 Flutter 羽球教學與 AI 動作分析 App。

目前已完成：

- 羽球技術分類
- 教學影片
- 技能詳情
- 學習進度
- AI 教練
- 影片上傳
- Google ML Kit Pose Detection
- 骨架辨識
- 單張畫面分析
- 指定區間分析
- 手肘 / 肩膀 / 膝蓋角度
- 高遠球、殺球與其他技術第一版規則式評分架構

目前首頁有「肌肉與發力」入口，現在需要把它正式做成可使用功能。

---

## 一、主要目標

新增「肌肉與發力」模組，讓使用者可以了解每一種羽球技術在不同動作階段：

- 使用哪些主要肌群
- 使用哪些輔助肌群
- 哪些肌群負責穩定
- 發力順序
- 發力方式
- 常見錯誤
- 動作與肌群如何配合

第一版先完成：

- 高遠球
- 殺球

其他技術先預留資料結構，之後擴充：

- 平球
- 挑球
- 切球
- 吊球
- 放網
- 接殺
- 啟動步

---

## 二、首頁入口

首頁原本的：

```text
肌肉與發力
```

卡片要可以點擊並進入：

```text
MuscleTrainingScreen
```

不要再顯示「Coming Soon」。

---

## 三、建議檔案結構

請新增：

```text
lib/
├─ models/
│  └─ muscle_phase.dart
│
├─ data/
│  └─ muscle_data.dart
│
└─ screens/
   ├─ muscle_training_screen.dart
   └─ muscle_detail_screen.dart
```

如果有共用 Widget，也可以新增：

```text
lib/widgets/
├─ muscle_body_view.dart
├─ muscle_phase_card.dart
└─ muscle_group_chip.dart
```

---

## 四、資料模型

建立 `muscle_phase.dart`。

建議至少包含：

```dart
class MusclePhase {
  final String phaseName;
  final double startSecond;
  final double endSecond;

  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> stabilizingMuscles;

  final String forceDescription;
  final List<String> mistakes;

  const MusclePhase({
    required this.phaseName,
    required this.startSecond,
    required this.endSecond,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.stabilizingMuscles,
    required this.forceDescription,
    required this.mistakes,
  });
}
```

也可以建立一層完整技術模型，例如：

```dart
class MuscleSkillData {
  final String skillName;
  final String englishName;
  final String videoPath;
  final String overview;
  final List<MusclePhase> phases;

  const MuscleSkillData({
    required this.skillName,
    required this.englishName,
    required this.videoPath,
    required this.overview,
    required this.phases,
  });
}
```

---

## 五、資料與 UI 必須分離

不要把：

```text
三角肌
背闊肌
核心肌群
...
```

全部直接寫死在 Widget 裡。

技術與肌群資料統一放在：

```text
lib/data/muscle_data.dart
```

UI 只負責讀資料與顯示。

---

## 六、高遠球資料

高遠球至少拆成：

```text
1. 準備
2. 架拍 / 引拍
3. 加速揮拍
4. 擊球
5. 隨揮
6. 回位
```

發力概念以動力鏈呈現：

```text
下肢蹬地
→ 髖部旋轉
→ 軀幹旋轉
→ 肩部帶動
→ 上臂
→ 前臂
→ 手腕 / 手指
```

每一階段顯示：

```text
主要肌群
輔助肌群
穩定肌群
發力說明
常見錯誤
```

例如不要只寫：

```text
使用肩膀
```

而是呈現成：

```text
主要肌群
- 三角肌
- 背闊肌

輔助肌群
- 肱三頭肌
- 前臂肌群

穩定肌群
- 核心肌群
- 肩胛穩定肌群

發力說明
下肢先建立力量，再透過髖部與軀幹旋轉，
將力量傳遞到肩、手臂與球拍。
```

---

## 七、殺球資料

殺球同樣拆成：

```text
1. 準備
2. 架拍
3. 引拍
4. 加速
5. 擊球
6. 隨揮
7. 回位
```

殺球特別強調：

```text
下肢發力
髖部旋轉
核心旋轉
肩膀內旋與上舉
手肘伸展
前臂旋轉
手腕 / 手指控制
```

但不要用沒有可靠依據的：

```text
肩膀出力 40%
手腕出力 25%
```

這類固定百分比。

第一版統一使用：

```text
主要肌群
輔助肌群
穩定肌群
```

---

## 八、影片同步

`MuscleDetailScreen` 要能播放教學影片。

使用目前專案已使用的：

```text
video_player
```

影片播放時，根據目前秒數，自動判斷目前是哪個 `MusclePhase`。

例如：

```text
0.0 - 2.0 秒：準備
2.0 - 4.0 秒：架拍
4.0 - 6.0 秒：揮拍
6.0 - 6.5 秒：擊球
6.5 - 8.0 秒：隨揮
```

畫面上的：

```text
當前階段
主要肌群
發力說明
人體肌肉高亮
```

都要跟著影片自動切換。

注意：目前影片階段時間可能只是示範值，要集中在資料層，方便之後校正，不要散落在 UI 裡。

---

## 九、UI 設計

### `MuscleTrainingScreen`

顯示技術列表：

```text
肌肉與發力

高遠球
殺球
平球
挑球
切球
吊球
放網
接殺
啟動步
```

第一版高遠球、殺球可進入完整內容。

其他尚未完成的技術可以顯示：

```text
建置中
```

但資料結構要先可擴充。

### `MuscleDetailScreen`

希望畫面大致：

```text
高遠球｜肌肉與發力

┌──────────────────┐
│     教學影片      │
└──────────────────┘

當前階段：架拍

┌──────────────────┐
│   人體肌肉示意圖   │
│                   │
│  高亮目前主要肌群  │
└──────────────────┘

主要肌群
・三角肌
・背闊肌

輔助肌群
・肱三頭肌
・前臂肌群

穩定肌群
・核心
・肩胛穩定肌群

發力說明
...

常見錯誤
...

[上一階段] [下一階段]
```

---

## 十、人體肌肉示意圖

第一版不要做複雜 3D 人體模型。

可以先使用：

```text
人體前面圖
人體背面圖
```

並透過區域 Overlay / SVG / CustomPainter 高亮目前肌群。

建議人體圖與肌肉高亮邏輯獨立成：

```text
muscle_body_view.dart
```

未來可以再升級：

```text
3D 人體
旋轉人體
點擊肌肉
動態肌群動畫
```

第一版不需要。

---

## 十一、與現有 BadmintonSkill 整合

目前專案已有：

```text
BadmintonSkill
SkillPhase
```

其中：

```text
lib/test/test_skill.dart
```

已經存在 `BadmintonSkill`。

不要再建立第二個 `BadmintonSkill` class。

如果可以合理重用目前 `SkillPhase` 的影片時間資訊，可以重用；如果肌肉資料需要更多欄位，使用新的 `MusclePhase`，不要破壞現有技能教學資料模型。

---

## 十二、未來與 AI 動作分析串接

請預留架構，使未來可以做到：

```text
AI Pose Analysis
      ↓
發現動作問題
      ↓
對應肌群 / 動力鏈
      ↓
給使用者肌肉與發力修正建議
```

例如：

```text
AI 問題：
殺球肩膀上舉不足

對應肌肉與發力：
肩帶穩定與軀幹旋轉不足，
不應只靠手臂揮拍。

建議：
改善架拍高度與軀幹到肩膀的力量傳遞。
```

第一版不用真的完成 AI → 肌肉建議自動映射，但資料架構不要阻礙未來加入。

---

## 十三、首頁流程

最終流程：

```text
SmashCoach
│
├─ 技術訓練
│
├─ AI 教練
│
├─ 戰術學院
│
├─ 肌肉與發力
│   ├─ 高遠球
│   │   ├─ 準備
│   │   ├─ 架拍
│   │   ├─ 揮拍
│   │   ├─ 擊球
│   │   └─ 隨揮
│   │
│   └─ 殺球
│       ├─ 準備
│       ├─ 架拍
│       ├─ 引拍
│       ├─ 加速
│       ├─ 擊球
│       └─ 隨揮
│
└─ 我的
```

---

## 十四、設計要求

請沿用 SmashCoach 現有視覺風格：

```text
主色：
深綠色

背景：
淺灰綠 / 白色

卡片：
大圓角

UI：
簡潔、運動、教學感
```

不要突然改成完全不同的設計系統。

---

## 十五、實作規則

1. 不要破壞現有 AI 分析功能。
2. 不要重新建立 `BadmintonSkill`。
3. 資料與 Widget 分離。
4. 高遠球與殺球先完整實作。
5. 其他技術預留架構。
6. 不要自行加入沒有依據的肌肉發力百分比。
7. 不要把第一版肌群描述宣稱為醫療或正式生物力學診斷。
8. 影片時間區間集中管理。
9. 修改完成後執行：

```bash
flutter analyze
```

10. 修正所有因本次修改產生的 error。
11. 完成後列出：

```text
新增檔案
修改檔案
功能完成項目
尚未完成項目
如何測試
```

---

## 十六、這次任務完成條件

完成後，我要可以實際操作：

```text
首頁
→ 肌肉與發力
→ 高遠球
→ 播放影片
→ 影片進入不同階段
→ 人體示意圖肌群跟著切換
→ 主要 / 輔助 / 穩定肌群同步更新
→ 發力說明同步更新
→ 常見錯誤同步更新
```

殺球也要有相同流程。

先完成這個模組，不要現在去重寫 AI 評分演算法或 REST backend。
