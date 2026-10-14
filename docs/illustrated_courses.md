# 動漫圖解教材與技術訓練改版

更新日期：2026-10-12。依使用者最新要求，教學影片改為靜態動漫分解圖；AI 教練分析使用者影片的流程保留。

## 教材範圍與分類

| 情境 | 課程 | 入門重點 |
|---|---|---|
| 入門與步法 | 啟動步 | 觀察對手、小幅卸重、彈性落地、推地 |
| 發球 | 反手短發球、正手高遠發球 | 低點下手觸球、對角有效發球區 |
| 後場 | 高遠球、站姿殺球、一般吊球、正手一般切吊 | 架拍、前上方觸球、連續減速 |
| 前場 | 放網、正手挑球 | 可控跨步、小動作控制與送高送深的差別 |
| 中場 | 正手平球 | 短引拍、身前觸球、快收拍 |
| 防守 | 反手接殺擋網 | 短促迎球、穩定拍面、連續準備 |

十一項教材共 49 張圖。原九項技術仍在 `badmintonSkills`；新增發球只加入 `trainingSkills`，不進入尚無對應分析器的 AI 選單。

除了情境分類，提供七項自我排查入口與文字搜尋。搜尋會直接顯示課程，選問題後收起其他問題，避免再捲過整份清單。這些入口是學習建議，不是自動診斷。

## 每課包含

- 用途、先備能力、限定示範版本。
- 每一步的做法、重要性、常見錯誤。
- 擊球點、哪些部位放鬆、何時帶動與短暫收緊；啟動步明確標示沒有擊球點。
- 正式球場線的俯視方向與示例目標區。曲線高度不由俯視圖表示，常見落點不是唯一落點或預測結果。
- 原有平球的圖片放大與短引拍錯誤比較；其他課程完整人物圖片、觸球階段的橘色示意點及放大。
- 慢速短練習、自我檢查；組數／勾選只保留本次頁面。
- 看過全部步驟後，使用者可自行標記「教材已讀」。沿用本機閱讀紀錄，不冒充帳號同步或動作已掌握。
- 原九項教材可連到既有 AI 教練並預選技術；兩項新發球明確不提供 AI 評分。

一般吊球和切球分開：吊球描述後場到前場球路；切球描述斜向擦擊方法，切吊屬吊球的一種變化，不以落在不同格就判定切球。

## 圖片檢視與限制

所有圖統一右手持拍。頭頂架拍示例改為約肩寬、略前後錯開；前場跨步、防守及落地依各自情境，不套用同一站距。殺球先示範不跳躍的站姿版本。

已逐張查看圖集總覽與 Flutter 渲染，檢查角色、持拍側、完整手腳／拍頭、階段對應和示意點位置。修正挑球圖把隨揮當觸球的問題，以及圖集裁切帶入鄰格鞋子殘片的問題。

**這不是專業教練逐張認證。** 全身動漫圖無法驗證精細握拍、前臂旋轉或切球擦擊角度；手指細節仍可能不精準，不應獨立用作握拍標準。需要教練現場校正，尤其切球、反手接殺與發球握拍。沒有以圖片產生新的 AI 評分門檻、肌肉活化比例或醫療判定。

肌肉與發力原有高遠球六階段、殺球七階段改為對應分解圖與手動階段切換；移除教學影片播放器及同步時間。後續已擴充為全部十一項、49 個階段，詳見 `tactics_muscle_update.md`。既有相容模型保留，不再給圖解綁定舊影片時間點。

## 教學核對來源

- [BWF Shuttle Time 教師手冊](https://www.badminton.org.au/wp-content/uploads/2022/11/1.-BWF-ST-Teachers-Manual_Inclusivity_ENGLISH.pdf)：用途、基本揮拍順序、前場控制及接殺擋網。
- [Sikana 正手平球](https://www.sikana.tv/en/sport/badminton/how-to-hit-a-forehand-drive)、[正手放網](https://www.sikana.tv/en/sport/badminton/how-to-hit-a-forehand-net-shot)、[正手頭頂吊球](https://www.sikana.tv/en/sport/badminton/how-to-hit-a-forehand-overhead-dropshot)。
- [Sikana 反手短發球](https://www.sikana.tv/en/sport/badminton/how-to-hit-a-low-backhand-serve)、[正手高遠發球](https://www.sikana.tv/en/sport/badminton/how-to-hit-a-high-forehand-serve)：動作概念。其舊式腰高合法性敘述不直接套用為現行比賽規則，圖片不量測高度。
- [Badminton Insight 啟動步](https://badminton-insight.com/the-split-step/)：對手觸球附近的時機與避免高跳。
- [Badminton Insight 切吊教學](https://www.youtube.com/watch?v=K32fSOgKcaY)：切吊與一般吊球的區分參考；細節仍需教練實際校正。
- 發球與球場線核對 BWF 法規及來源版本；看到的 Ghana Badminton 下載版為 **2027-01-04 才生效**的版本，不把未生效的計分變更放入目前教材。規則依賽事實際採用版本為準。教材不將「低於腰」或拍頭指向某角度當成足夠的合法判準。

文字為原創教學提示與資料核對後的整理；未把來源影片或照片搬進 APP。

## 舊影片可恢復備存

`assets/videos/clear.mp4`、`smash.mp4`、`lift.mp4` 已移至 `archive/teaching_videos/`，移前移後 SHA256 一致。從 pubspec 移除教學影片打包。`video_player` 保留供使用者選取影片的 AI 分析使用。

`clear.mp4` 與 `smash.mp4` 內容相同，因此不再把其中一支當成正確殺球教材。若要恢復影片，需先核對動作內容，移回資產位置、恢復 pubspec 與相應教學播放器；單純移回檔案不會讓 APP 自動播放。

## 驗證

- `flutter analyze --no-pub`：無問題。
- `flutter test --no-pub`：34 項通過，包括小螢幕、大字體、反覆切換、圖片放大、搜尋／分類、自行標記已讀、AI 預選範圍及既有會員／肌肉模組測試。
- `backend/.venv/Scripts/python.exe -m pytest -q -p no:cacheprovider`：記憶體 SQLite 下四項通過，沒有修改真實會員資料。後端程式未改動。
- 實際 Flutter 渲染 49 個階段畫面及十一項觸球頁，輸出在 `preview/illustrated_courses/`；三張總覽為 `overhead-sheet.png`、`frontcourt-sheet.png`、`serves_drive-sheet.png`。
- Android debug APK 建置及保留資料的更新安裝成功。模擬器已顯示新版技術訓練及高遠球展開球路圖；程序仍執行，近期 Flutter／AndroidRuntime 錯誤日誌無輸出。未量測 FPS，也不宣稱所有手機絕不當機。

## 後續戰術與肌群改版

使用者後續授權完成戰術逐拍動畫校正、場上練習與十一項肌群教材擴充。成果、驗證與限制見 `tactics_muscle_update.md`；本文件保留先前圖解改版的歷史驗證紀錄。

完整圖片提示詞和生成方式見 `illustrated_course_prompts.md`。此改版取代 `drive_illustrated_pilot.md` 的「只改平球且不記錄教材閱讀」範圍，但保留無自動進度寫入原則。
