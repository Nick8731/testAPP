# 前場跨步、接殺與反手短發球修正／新增撲球

更新：2026-10-13。全部以右手持拍示範，仍是静態圖片，沒有加入教學播放器或背景動畫。

## 完成範圍

- 挑球與放網：跨步、觸球圖改為右腳（持拍側）在前、左腳留後，膝腳尖同向，文字與回位說明同步。
- 接殺：右手單手持拍，左手放鬆打開平衡，不抓拍柄或右腕。回位圖重用修正後的準備圖，表示回到同一可接球姿勢；未採用一張把持拍手換成左手的失敗版本。
- 反手短發球：右腳稍前、左腳稍後示範；開始發球至擊出雙腳各有部分接觸地面且不移位。此站姿不是所有發球的硬性規定。
- 前場新增「撲球」：拍高判斷 → 右腳迎球 → 手指短促下壓 → 收拍推回。高於網帶且在我方空間才撲，低球改放網／挑球。手指握放配合小幅前臂控制，不用食指單獨指球、硬壓手腕或大掄拍。
- 撲球同步球路、觸球點、放鬆／發力、练習、自我檢查、肌群分工與可選強化。肌群為功能性教學，不是肌電活化排名或傷痛診斷。

現在 12 項動作課＋1 入門握拍課，共 13 課；肌肉教材 12 項／53 階段。原九項 AI 與 pose-phase-v3、會員/API/SQLite 資料沒有修改；撲球不提供尚不存在的 AI 評分。

## 核對與限制

[BWF Shuttle Time 教師手冊](https://www.badminton.org.au/wp-content/uploads/2022/11/1.-BWF-ST-Teachers-Manual_Inclusivity_ENGLISH.pdf) 第 48 頁（內頁44）用來核對持拍腿跨步、膝腳尖方向及非持拍手平衡；實戰仍有非持拍腳跨步，不把本課右腳示例宣稱唯一合法步法。
[Badminton Insight 撲球教學](https://badminton-insight.com/how-to-play-a-net-kill-in-badminton/) 核對高球機會、小動作及放鬆後短促收緊握拍；貼網刷撲與反手撲球不在本課範圍。
發球接地與越網初次觸球／觸網依賽事採用的 BWF 規則；不從圖片量測發球高度或判定犯規。

生成圖已檢視持拍側、前腳及完整球拍，但不是現場教練逐張認證；精細手指、拍面及前臂旋轉仍須真人校正。原圖保留，僅新增版本引用；不改寫學習紀錄或既有 AI 分數。

## 素材與產生方式

使用 imagegen 技能的內建生成／編輯工具，透明背景；沒有 CLI API 或外部影片服務。最終 PNG 直接保留工具原生透明度與尺寸，不以程式重畫／修腿。APP 一般解碼 512 寬、放大 1024 寬。

實際資產在 `D:/Users/User/test_app/assets/images/lessons/`：

- `lift/step_2-v2.png`、`step_3-v2.png`
- `net/step_2-v2.png`、`step_3-v2.png`
- `defence/step_1-v2.png` 到 `step_4-v2.png`（第4張重用第1張）
- `serve_short/step_1-v2.png` 到 `step_4-v2.png`
- `net_kill/step_1.png` 到 `step_4.png`

初輪未修正前腳的挑球／放網／撲球圖未採用；透過第二個正確跨步參考修正，而非鏡像整張人物。反手短發球前視圖須以畫面左側的右腳更靠近觀看者表示前腳，不能把畫面右腳等同人體右腳。

## 圖像提示詞紀錄

### 原圖定向修正

#### lift 第2張

Use case: precise-object-edit. Image 1 is edit target. Correct badminton forehand lift low underhand illustration anatomy ONLY: right-handed player facing screen right. Current near/camera-side RIGHT leg with logo is trailing, wrong. Move that anatomically RIGHT leg forward to screen right, bent right knee over right toes, right shoe forward; LEFT leg extends behind toward screen left. Racket remains in anatomical RIGHT hand, unchanged position and racket height. Do not mirror whole image. Preserve face, hair, black purple shirt, navy shorts, shoes, style, framing, full intact racket and transparent background. Clear natural right-foot-leading lunge, no extra limbs, no text.

#### lift 第3張

Use case: precise-object-edit. Image 1 is edit target. Correct badminton forehand lift low underhand illustration anatomy ONLY: right-handed player facing screen right. Current near/camera-side RIGHT leg with logo is trailing, wrong. Move that anatomically RIGHT leg forward to screen right, bent right knee over right toes, right shoe forward; LEFT leg extends behind toward screen left. Racket remains in anatomical RIGHT hand, unchanged position and racket height. Do not mirror whole image. Preserve face, hair, black purple shirt, navy shorts, shoes, style, framing, full intact racket and transparent background. Clear natural right-foot-leading lunge, no extra limbs, no text.

#### net 第2張

Use case: precise-object-edit. Image 1 is edit target. Correct badminton forehand soft net shot illustration anatomy ONLY: right-handed player facing screen right. Current near/camera-side RIGHT leg with logo is trailing, wrong. Move that anatomically RIGHT leg forward to screen right, bent right knee over right toes, right shoe forward; LEFT leg extends behind toward screen left. Racket remains in anatomical RIGHT hand, unchanged position and racket height. Do not mirror whole image. Preserve face, hair, black purple shirt, navy shorts, shoes, style, framing, full intact racket and transparent background. Clear natural right-foot-leading lunge, no extra limbs, no text.

#### net 第3張

Use case: precise-object-edit. Image 1 is edit target. Correct badminton forehand soft net shot illustration anatomy ONLY: right-handed player facing screen right. Current near/camera-side RIGHT leg with logo is trailing, wrong. Move that anatomically RIGHT leg forward to screen right, bent right knee over right toes, right shoe forward; LEFT leg extends behind toward screen left. Racket remains in anatomical RIGHT hand, unchanged position and racket height. Do not mirror whole image. Preserve face, hair, black purple shirt, navy shorts, shoes, style, framing, full intact racket and transparent background. Clear natural right-foot-leading lunge, no extra limbs, no text.

#### defence 第1張

Use case: precise-object-edit. Image 1 edit target. Preserve character, right hand holding racket, racket exact location, full body stance, outfit and transparency. Change ONLY anatomical LEFT non-racket arm and hand: open relaxed left hand extended comfortably sideways for balance, distinctly separated from right hand and racket handle/shaft. No two handed grip, no touching right wrist. Five natural fingers, no stiff fan pose. For step 1, keep existing short backhand defence racket posture; only right hand holds racket. No text, no extra arms.

#### defence 第2張

Use case: precise-object-edit. Image 1 edit target. Preserve character, right hand holding racket, racket exact location, full body stance, outfit and transparency. Change ONLY anatomical LEFT non-racket arm and hand: open relaxed left hand extended comfortably sideways for balance, distinctly separated from right hand and racket handle/shaft. No two handed grip, no touching right wrist. Five natural fingers, no stiff fan pose. For step 2, keep existing short backhand defence racket posture; only right hand holds racket. No text, no extra arms.

#### defence 第3張

Use case: precise-object-edit. Image 1 edit target. Preserve character, right hand holding racket, racket exact location, full body stance, outfit and transparency. Change ONLY anatomical LEFT non-racket arm and hand: open relaxed left hand extended comfortably sideways for balance, distinctly separated from right hand and racket handle/shaft. No two handed grip, no touching right wrist. Five natural fingers, no stiff fan pose. For step 3, keep existing short backhand defence racket posture; only right hand holds racket. No text, no extra arms.

#### defence 第4張

Use case: precise-object-edit. Image 1 edit target. Preserve character, right hand holding racket, racket exact location, full body stance, outfit and transparency. Change ONLY anatomical LEFT non-racket arm and hand: open relaxed left hand extended comfortably sideways for balance, distinctly separated from right hand and racket handle/shaft. No two handed grip, no touching right wrist. Five natural fingers, no stiff fan pose. For step 4, keep existing short backhand defence racket posture; only right hand holds racket. No text, no extra arms.

#### serve_short 第1張

Use case: precise-object-edit. Image 1 edit target. Change ONLY lower-body stance to right-handed badminton backhand short serve: anatomical RIGHT foot (on same side as racket-holding RIGHT hand) modestly in front toward screen right, anatomical LEFT foot behind screen left, shoulder width, both soles grounded, no lunge. Current near-camera right leg should be forward, not trailing. Preserve upper body, right hand on racket, left hand holding white shuttlecock, face, hair, black purple shirt, navy shorts, style, complete racket and transparency. Do NOT mirror the image or change hands, no text.

#### serve_short 第2張

Use case: precise-object-edit. Image 1 edit target. Change ONLY lower-body stance to right-handed badminton backhand short serve: anatomical RIGHT foot (on same side as racket-holding RIGHT hand) modestly in front toward screen right, anatomical LEFT foot behind screen left, shoulder width, both soles grounded, no lunge. Current near-camera right leg should be forward, not trailing. Preserve upper body, right hand on racket, left hand holding white shuttlecock, face, hair, black purple shirt, navy shorts, style, complete racket and transparency. Do NOT mirror the image or change hands, no text.

#### serve_short 第3張

Use case: precise-object-edit. Image 1 edit target. Change ONLY lower-body stance to right-handed badminton backhand short serve: anatomical RIGHT foot (on same side as racket-holding RIGHT hand) modestly in front toward screen right, anatomical LEFT foot behind screen left, shoulder width, both soles grounded, no lunge. Current near-camera right leg should be forward, not trailing. Preserve upper body, right hand on racket, left hand released shuttlecock, face, hair, black purple shirt, navy shorts, style, complete racket and transparency. Do NOT mirror the image or change hands, no text.

#### serve_short 第4張

Use case: precise-object-edit. Image 1 edit target. Change ONLY lower-body stance to right-handed badminton backhand short serve: anatomical RIGHT foot (on same side as racket-holding RIGHT hand) modestly in front toward screen right, anatomical LEFT foot behind screen left, shoulder width, both soles grounded, no lunge. Current near-camera right leg should be forward, not trailing. Preserve upper body, right hand on racket, left hand released shuttlecock, face, hair, black purple shirt, navy shorts, style, complete racket and transparency. Do NOT mirror the image or change hands, no text.


### 跨步第二輪（挑球2/3、放網3、撲球2）

Image 1 edit target; Image 2 correct right-forward lunge reference. Replace pants and legs only: near RIGHT thigh with logo forward SCREEN RIGHT, far LEFT leg trails SCREEN LEFT; forward thigh overlaps rear thigh, do not mirror. Keep upper body, racket height, face, costume, alpha and two legs.

### 撲球各階段生成（角色參考 net/step_1.png）

第1張：Use case: scientific-educational. Asset: ONE static full-body Japanese sports anime badminton teaching transparent PNG, same character as reference image 1 (identity and outfit reference ONLY, NOT target pose). Adult male dark tousled hair, black purple/blue diagonal shirt, navy shorts, white trainers. Camera three-quarter from anatomical RIGHT side, facing screen right, near arm/leg are RIGHT. Ready with racket in RIGHT hand held in front above chest, feet shoulder width softly bent, watching a high forecourt shuttle, left free hand open to side. No shuttle. Full body and racket, two arms/two legs, ample margins, no text/arrows/background, true alpha.

第2張：Use case: scientific-educational. Asset: ONE static full-body Japanese sports anime badminton teaching transparent PNG, same character as reference image 1 (identity and outfit reference ONLY, NOT target pose). Adult male dark tousled hair, black purple/blue diagonal shirt, navy shorts, white trainers. Camera three-quarter from anatomical RIGHT side, facing screen right, near arm/leg are RIGHT. Step anatomical RIGHT foot toward screen right into a controlled shallow lunge, left foot behind, right knee tracks toes. RIGHT racket arm raised forward, racket head at face height in front not overhead backswing, relaxed fingers ready. LEFT hand open sideways away from racket. No shuttle. Full body and racket, two arms/two legs, ample margins, no text/arrows/background, true alpha.

第3張：Use case: scientific-educational. Asset: ONE static full-body Japanese sports anime badminton teaching transparent PNG, same character as reference image 1 (identity and outfit reference ONLY, NOT target pose). Adult male dark tousled hair, black purple/blue diagonal shirt, navy shorts, white trainers. Camera three-quarter from anatomical RIGHT side, facing screen right, near arm/leg are RIGHT. FOREHAND NET KILL CONTACT: anatomical RIGHT foot leading toward screen right, same near-side RIGHT leg bent forward, left foot trailing left. RIGHT arm reaching forwards near shoulder height, elbow soft, hand loosely wrapped then squeezed on grip, racket head in front around head height with slightly downward-directed face, one white shuttle cork touches center strings. Short action, NOT overhead smash, NOT underhand lift, NOT two-handed grip. Left hand open aside. No net/floor; app overlays net-height explanation. Full body and racket, two arms/two legs, ample margins, no text/arrows/background, true alpha.

第4張：Use case: scientific-educational. Asset: ONE static full-body Japanese sports anime badminton teaching transparent PNG, same character as reference image 1 (identity and outfit reference ONLY, NOT target pose). Adult male dark tousled hair, black purple/blue diagonal shirt, navy shorts, white trainers. Camera three-quarter from anatomical RIGHT side, facing screen right, near arm/leg are RIGHT. After short forehand net kill: right foot still slightly forward but beginning controlled push back, racket lowered only a little to in-front chest height, shoulders relaxed, no huge follow through. LEFT hand open sideways; RIGHT hand alone holds racket. No shuttle. Full body and racket, two arms/two legs, ample margins, no text/arrows/background, true alpha.


### 撲球觸球腿部第二輪

Use case: precise-object-edit. Target image 1: correct ONLY legs, which currently STILL incorrectly show the RIGHT near-side leg trailing. Do not merely restate pose. ACTUALLY REPLACE lower body: near/camera-side thigh currently bearing white logo must run diagonally DOWN AND RIGHT from near right hip to the FORWARD bent knee on image RIGHT; right shin vertical below that bent knee, right shoe on image RIGHT. Far-side LEFT thigh runs diagonally DOWN AND LEFT from far hip into rear leg extending to image LEFT shoe. The right-front thigh visibly overlaps the far left-back thigh at crotch. MOVE WHITE SHORTS LOGO onto the FRONT thigh, on image RIGHT; rear thigh on image LEFT has NO logo. This visible shorts-logo mapping is mandatory and proves actual swap. Right wrist and right forward knee on same near body side. Keep upper body/racket/shuttle/face/clothes unchanged. Camera unchanged. Two legs only, natural moderate lunge, no twisted knees. Preserve alpha, no labels.

### 反手短發球第二輪（四張，僅改腿部）

Upper body unchanged: RIGHT racket hand on viewer LEFT, LEFT hand on viewer RIGHT holds/releases shuttle. RIGHT foot on viewer LEFT distinctly nearer and LOWER, larger shoe bottom x=.37 y=.94; LEFT foot on viewer RIGHT smaller farther back, bottom x=.58 y=.86. Shoulder-width standing, both soles grounded, not a lunge. Right thigh/logo slopes forward toward viewer. Do not change upper body, racket, shuttle or alpha, no labels.

## 驗證

- Flutter 靜態檢查無問題，完整 88 項測試通過；新版 PNG 均為 RGBA，檔案小於 1 MB，另確認全部教材資產測試通過。
- 後端使用記憶體 SQLite，4 項測試通過（兩則既有套件棄用警告）；沒有修改正式會員與分析資料。
- 額外兩項實際中文渲染測試通過：五課四步總覽 `preview/frontcourt_revision/contact-sheet.png` 與全部 53 個階段的頁面；已查看跨步、接殺、短發球及撲球觸球頁。
- Android debug APK 建置成功，對原 emulator-5554 使用 `adb install -r` 保留資料更新，未卸載、清除帳號或重建資料庫。實際確認全部課程 13 課、前場 3 課，撲球第 3 步、圖片放大／關閉、同項肌群連結及肌肉階段切換正常。
- 模擬器截圖：`preview/frontcourt_revision/android-net-kill.png`，已檢視。當前 APP 程序的 Flutter／AndroidRuntime 錯誤日誌無輸出，後台 health 回應 ok。未量測真機 FPS 或做長時間壓力測試，不宣稱所有手機永不當機。

可選視覺檢查工具 `preview_tools/render_frontcourt_sheet_test.dart` 與既有全課程渲染工具；不寫入正式會員或閱讀資料。原 AI、登入、戰術及閱讀狀態保留，圖片仍需現場教練校正精細動作。

