# 課程收納與平球／高遠球圖片修正

## 版面

技術訓練預設不展開 11 項課程；先顯示搜尋、全部課程按鈕、場上情境／問題入口。點「全部課程（11 課）」才展開清單，可按「回到分類」收起。選分類、問題或搜尋時只列符合課程。保留本機教材閱讀與原有技能頁，不修改 AI、會員、紀錄或趨勢。

## 圖片，不新增播放動畫

使用 imagegen 內建編輯模式，保留同一角色、右手持拍及透明背景，新增版本圖而非刪除舊檔。

- `assets/images/drive/backswing-v2.png`：修正腰旁拍頭，改為身前正手側短引拍與向上拍頭準備。
- `assets/images/drive/contact-v2.png`：胸前來球的正手側迎球示意，完整球拍、短距離前揮、非持拍手放鬆。技術與肌肉課程共用。
- `assets/images/lessons/clear/contact-v2.png`：高遠球向上伸展，拍頭在持拍肩上方；不是殺球般斜向前探。觸球點重設到新圖拍面中央，文字與自我檢查同步。

平球圖為胸前來球的一個示例，不代表所有平球高度。仍是靜態姿勢示意，不能證明精細握拍及前臂旋轉完全正確，仍需教練逐張驗證。生成原圖 1280 方形、約 0.45–0.74 MB，APP 顯示預載仍用 512 寬解碼；未改用播放器、輪播或背景計時。

參考：[Badminton Bible 高遠球](https://www.badmintonbible.com/shots/rearcourt/forehand/clears/hitting-a-full-length) 區分持拍肩上方與殺球較前方觸球；[Badminton Insight 正手平球](https://badminton-insight.com/how-to-hit-the-forehand-drive-in-badminton/) 的短引拍與手肘、手向前配合概念（該頁搜尋文字可取得，全文開啟回傳 403，未聲稱看完影片）。

## 檢視與測試

中文實際 Flutter 畫面：`preview/training_revision/overview.png`、`all-courses.png`、`drive-1.png`、`drive-2.png`；高遠球觸球頁 `preview/illustrated_courses/clear-contact.png`。

測試涵蓋首次不展開課程、全部 11 項可找到、返回分類、搜尋／篩選、三張新圖 RGBA 與大小、技術／肌肉圖檔一致、階段切換及放大。原圖仍保留，若回退可改回旧引用；沒有變更已儲存 AI 分數。

完整 79 項 APP 測試、4 項後端隔離測試通過，靜態檢查無問題；中文畫面渲染已逐頁查看。未量測所有手機 FPS，插圖仍需教練校正。

## 內建編輯的最終提示詞

### 高遠球：輸入原 clear/step_4.png

Use case: precise-object-edit, badminton educational anime cutout. Image 1 is the edit target. Correct only the right-handed forehand HIGH CLEAR contact pose: the racket-arm reaches almost vertically upward above his RIGHT racket shoulder, natural extended elbow (not locked), racket shaft extends upward, complete racket head above the shoulder at the high reachable contact point. This is a HIGH defensive CLEAR, NOT a smash and NOT a 45-degree forward-reaching hit. Remove the old diagonal reaching arm/racket. Keep the same young male anime character face, hair, black-purple shirt, shorts and white shoes, same side/three-quarter viewpoint facing right, both feet on ground in a compact comfortable shoulder-width stagger, no jumping, no exaggerated back arch. Preserve character identity and illustration style. Reframe full body including whole racket with transparent margin; shoulder-to-racket contact nearly vertical, do not crop racket or shoes. Only one right arm, two total arms, one complete racket. No shuttle, text, watermark, arrows or background; app overlays markers. Square PNG with genuine alpha, preferably 512x512.

### 平球觸球：輸入原 drive/contact.png

Use case: precise-object-edit. Edit target Image 1 is a right-handed male anime badminton instructional character. Correct the pose to a FOREHAND FLAT DRIVE CONTACT, not a push, jab, lift, overhead shot, baseball swing or boxing punch. Keep identical face, short hair, black shirt with purple diagonal design, shorts, white shoes and anime rendering. Full body side/three-quarter facing right, feet balanced comfortably shoulder-width, knees slightly bent, torso upright slight forward athletic lean. Right racket arm is on the forehand/outside side of body; shoulder and elbow drive forwards from a SHORT backswing, elbow remains softly bent and not locked; forearm rotation brings an upright full racket face toward a shuttle in front of the RIGHT shoulder, around upper chest height, not hip or waist. Right hand at chest height clearly holds the racket grip. Whole racket shaft and stringed head are visible extending forward from the hand, racket head upright (not a sideways horizontal oval). Left non-racket hand open and relaxed for balance, NOT a clenched fighting fist. No actual shuttle, arrows, speed lines, text or background (app supplies annotation). No large rear swing, no straight rigid punch arm, no extra limbs. Preserve style and all apparel. Genuine transparent square PNG, preferably 512x512, full racket and shoes with margins.

### 平球短引拍：輸入原 backswing.png＋新 contact-v2.png

Edit Image 1: correct this right-handed anime badminton player's FOREHAND DRIVE SHORT BACKSWING. Image 2 is the corrected contact phase, for same character and stroke-height continuity. Keep identical character face, hair, black-purple shirt, shorts, shoes and anime style. Full body three-quarter side view facing right, knees gently bent, feet comfortably about shoulder-width, torso upright/slight forward lean. Right shoulder, elbow, wrist and racket remain on forehand side and IN FRONT of torso, not behind back. Move bent right elbow only slightly backward to beside ribcage; elbow not tucked down at hip. Right hand at upper chest height, forearm angled forward/upward, racket head upright about face/upper chest height, ready for a short forward swing into Image 2. IMPORTANT racket head must NOT be sideways at waist level as in old Image 1. Left hand open relaxed balance, not boxing fist. One right-hand held complete racket, realistic anatomy, two arms total. No text, arrows, shuttle, watermarks, background, speed lines. Genuine alpha square PNG, preferably512x512, full feet and whole racket visible.
