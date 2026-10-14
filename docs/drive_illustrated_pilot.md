# 平球圖解：單堂試用範圍

入口：首頁 → 技術訓練 → 平球；或學習頁 → 平球。

僅缺影片的平球使用新頁面；其他課程仍走原本的影片與教材頁。
沒有改動 AI 骨架、評分、登入、REST API、資料庫或原影片。

## 本次新增

- 四步驟圖解，可直接點選或使用上／下一步。
- 小引拍與過大引拍的幅度對照。
- 低速無球短練習與本次組數（最多 3 組）。
- 三項自我檢查，不把勾選當成掌握技術或 AI 評分。
- 小螢幕／大字時自動換行，對照圖改為上下排列。
- 靜態 CustomPainter 與 RepaintBoundary；沒有影片載入、網路、計時器、Ticker 或背景動畫。

## 版面第二次調整

人物相對球場縮小約 22%，腳部仍貼地；持拍前臂與擊球方向以橘色高亮，
球拍輪廓加深，球路箭頭不隨人物縮短。步驟標籤縮短，提示文字改為獨立淺綠區塊。
完整握拍／前臂旋轉限制仍保留在頁面底部，沒有新增動作評分或背景動畫。

試用組數與勾選只保留在目前頁面，返回再進入即重設。
不自動把課程進度改為 50% 或 100%，也不寫入帳號。

## 素材與教學限制

平球四個步驟已改為透明背景的同角色動漫插圖，離線資產位於
`assets/images/drive/`，總檔案量約 0.5 MB，每張 512×512 RGBA。
人物保持小比例，放大鏡可開啟圖片細節；錯誤幅度仍用原簡易圖解表示。
`pubspec.yaml` 增加圖片目錄；沒有新增網路服務或動畫播放器。
生圖提示詞與素材來源見 `drive_character_prompt.md`。

這是右手正手的位置／幅度示意，不呈現精確握拍、前臂旋轉或人體生物力學。
其他技術與完整教學／分析連結沒有擴充。圖解需教練校正才適合作正式教材。
教學概念參考：[Sikana 正手平球](https://www.sikana.tv/en/sport/badminton/how-to-hit-a-forehand-drive)。

## 檔案

新增 `lib/data/drive_lesson_data.dart`、`lib/widgets/drive_pose_diagram.dart`、
`lib/screens/drive_lesson_screen.dart`、`test/drive_lesson_test.dart`。
修改 `lib/screens/skill_detail_screen.dart`：用薄包裝將平球導向試用頁，原影片頁實作不變。
可選畫面檢查工具為 `preview_tools/render_drive_preview_test.dart`。

## 測試

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub preview_tools/render_drive_preview_test.dart
```

互動測試涵蓋 80 次步驟選擇、邊界按鈕、練習上限、勾選與取消、
320×640 與 800×1100 的兩倍文字、20 次進入／返回，以及不寫入既有進度。
畫面檢查工具在 Windows 使用系統微軟正黑體，輸出到 `preview/drive_lesson/`。

這些測試不是 Android 真機效能量測，不能保證所有手機都不當機或維持特定 FPS。

本次驗證：`flutter analyze --no-pub` 無問題；`flutter test --no-pub` 18 個測試通過。
新增檢查四張 RGBA 圖片資產，以及 10 次放大視窗開啟／關閉。
獨立元件畫面輸出測試亦通過。

後續已在 Pixel_9（emulator-5554，Android x86_64）以 `adb install -r` 保留資料更新 APK，
重新啟動並進入「技術訓練 → 基礎技術 → 平球」。確認四步驟圖片切換、
放大視窗開啟／關閉正常，操作後程序仍存活，該程序的 Flutter／AndroidRuntime
錯誤級別紀錄沒有輸出。實際畫面為 `preview/drive_lesson/android-anime-contact.png`
與 `android-anime-detail.png`。這不是實體手機或 FPS 量測，也不是長時間穩定性保證。
