# 入門：正反手握拍與換握

## 使用入口

技術訓練 → 入門與步法 → 正反手握拍與換握。也可從「全部課程」或搜尋正拍／反拍／握拍／換握進入；「我的學習」亦列出入門教材。

目前為 11 項動作課＋1 項握拍入門，共 12 課。握拍不是新增 BadmintonSkill、AI 分析項目或肌肉動作；原本 9 項 AI、11 項肌肉教材保留。

## 三段教學

1. 正手 V 型：握手式入門、虎口和食指間隔、自然側面包握；不握成拳頭或套用平底鍋握法。
2. 身前反手拇指握法：指腹順拍桿支撐、掌心活動空間；不把此握法直接套用球在身後或後場反手高遠球。
3. 放鬆與換握：手指小幅轉柄，觸球附近短暫加強，之後恢復可換握的控制；不鬆到掉拍或硬扭手腕。

每段有適用範圍、做法、用途、常見錯誤、低強度試練及自我檢查。另有八面拍柄橫切面概念圖。全部為靜態內容，不增加影片或自動播放。疼痛、麻木時停止。

文字依 [BWF Shuttle Time 教師手冊](https://www.badminton.org.au/wp-content/uploads/2022/11/1.-BWF-ST-Teachers-Manual_Inclusivity_ENGLISH.pdf) 的握拍與換握部分核對（PDF 第 45–48 頁／內頁 41–44），練習語句為 APP 自行編寫。此參考不代表 BWF 認證本 APP；生成的手指近景不能量測精確角度、壓力或替代教練校正。

## 圖檔與限制

imagegen 內建生成與編輯模式，沒有使用外部付費影片服務：

- `assets/images/beginner/forehand-grip.png`：正手圖採修正版本，拇指改成側面包握，避免初版與拇指握法太相似。
- `assets/images/beginner/backhand-grip.png`：身前反手拇指支撐示意。

兩圖為不透明背景 PNG，各約 1.6 MB；頁面預載 512 寬，放大用 1024 寬。不將生成圖當精確握拍標準，文字及教練確認優先。

## 閱讀進度

查看三段後才可自行按「標記教材已讀」。只儲存本機閱讀狀態，不自動標記掌握或改動會員分析紀錄。總教材數由 11 增至 12，未讀新課會改變整體百分比，但原課程已讀紀錄不刪除；入門課另列在我的學習卡片。

## 接續中斷項目

保留前一階段全部課程收納、兩張平球修正圖及高遠球高點圖文修正。預覽與目前引用仍完整，沒有回退成播放動畫。原圖保留，可回查 `training_layout_images.md`。

## 驗證紀錄

Flutter 完整 84 項測試通過、靜態檢查無問題；後端隔離資料庫 4 項測試通過。新測試包括握拍搜尋、入門入口、原動作清單不變、三段切換／放大、手動已讀與我的學習總數；中文實際渲染 `preview/beginner_grips/step-1.png`、`step-2.png`、`step-3.png` 及拍柄說明頁已檢視。未量測實機 FPS，不宣稱所有手機永不當機。

Android debug APK 已保留資料更新安裝，原 Pixel_9 與本機後台重新啟動，health 回應正常；模擬器實際確認全部課程 12 課、入門分類 2 課及握拍三段頁。未清除資料庫、重設帳號或寫入測試分析。

## 最終圖像提示詞

### 正手生成後的定向編輯

Use case: precise-object-edit. Image 1 is the edit target for FOREHAND V-GRIP, right hand. It currently resembles an extended backhand thumb grip too much. Correct ONLY digit placement, keep right hand identity, black octagonal handle, sleeve, view, pale ivory background, anime style. The index finger wraps comfortably around the handle at the top and must sit a little HIGHER toward the shaft than the thumb. The thumb must curl diagonally AROUND THE SIDE of the handle, with its tip resting lower than the index finger, between index and middle finger level; do NOT extend thumb lengthwise up the wide face. Show the web between the side-wrapped thumb and raised index as a relaxed V-shape along the narrow beveled side. Thumb follows across the grip sideways/diagonally, not vertically. Middle, ring and little finger spaced gently and curved under index, not a rigid fist. Small palm gap, neutral wrist. Exactly 5 believable digits, no fingernails duplicated, no extra hand. This is a handshake/basic forehand grip, distinct from the parallel straight-thumb backhand grip. No text, arrows, marks or logos. Teaching close-up, square.

### 身前反手生成

Use case: scientific-educational. Original Japanese sports-anime close-up of BASIC BADMINTON BACKHAND THUMB GRIP, for strokes IN FRONT OF BODY only. One adult RIGHT hand holds a black octagonal badminton racket handle, shaft vertical upward, wrist from lower right. View the broad rear flat face of the handle and thumb pad clearly. Thumb gently straightens upward ALONG the broad rear handle face, its pad laid lengthwise parallel to shaft for a short supportive push; do not wrap the thumb diagonally around the side as in forehand grip. Other four fingers curve loosely around opposite side of handle, index comfortably separated, a small natural palm gap, neutral wrist, not a clenched fist or rigid forced thumb. Five plausible fingers total, thumb nail and joints coherent, no extra hand, no left-handed mirror. Hand/handle dominate square frame. Light/medium skin and subtle cel-shading, tiny black-purple sleeve cuff; pale ivory background. No face, torso, court, text, arrows, labels, numbers, logo, watermark or racket head. This is not a rear-court overhead backhand demonstration. Still illustration for a beginner lesson, no animation.
