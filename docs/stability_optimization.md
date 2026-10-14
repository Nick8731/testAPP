# 六項穩定性與易用性優化

## 使用者操作

1. 首頁立即啟動，登入憑證在背景驗證；離線保留憑證，會員頁提示重試。背景舊回應不會在登出後重新寫回會員。
2. 會員 API 回應 401 時，只清除該失效憑證，不讓舊請求清掉新登入。紀錄／趨勢／詳情提供「重新登入」。儲存／刪除不自動重送，避免重複資料或換帳號後誤操作。
3. 分析歷史每頁 20 筆，提供「載入更多」與已載入／總筆數；切換技術、下拉更新、刪除後重新載入首頁，忽略過時請求並依編號去重。換帳號或登入失效時清除舊列表。
4. 趨勢以所選評分版本計算最新、變化、最佳。預設最近一筆紀錄的版本，可切回舊版；沒有版本的舊紀錄列為「舊紀錄（版本未記錄）」，不刪除、不重算舊分數。同版本仍需固定鏡位、持拍側及階段，不能代表實戰能力進步。
5. 後台姓名、技術名稱與分項名称先去除首尾空白，再檢查長度；全空白拒絕為 422。密碼不做去空白修改，雜湊與 JWT 保留。
6. SQLite 自動備份與可驗證的還原工具，見下節。不提供一般會員下載整個資料庫的 API。

AI 骨架、取樣時間格、九項評分權重、13 課教材與戰術內容保持不變。教材已讀仍為本機資料，本次未擴充跨裝置同步或忘記密碼。

## SQLite 備份

後台啟動後背景建立一次快照，運行期間預設每 360 分鐘建立一次；關閉後台時不會繼續執行，這不是 Windows 排程。快照位於 `backend/data/backups/`，不自動刪除舊備份。

可在本機 `.env` 調整（不要提交密鑰）：

```text
SQLITE_BACKUP_ENABLED=true
SQLITE_BACKUP_INTERVAL_MINUTES=360
SQLITE_BACKUP_DIR=data/backups
```

使用 SQLite Online Backup API，不直接複製運作中的資料庫檔案。來源唯讀，快照包含全部會員與紀錄；需限制目錄存取，另外保存到可靠的私人儲存位置。同一硬碟的備份不能防止整顆硬碟損壞。檔案建立後檢查完整性、外鍵與必要資料表，失敗不修改原資料。

從 `D:\Users\User\test_app\backend` 執行：

```powershell
.\.venv\Scripts\python.exe scripts\manage_database.py backup
.\.venv\Scripts\python.exe scripts\manage_database.py check
```

## 還原操作（不覆蓋原資料）

1. 選擇已驗證的備份檔，不從網路接受不明資料庫。
2. 還原到一個全新的 `.db` 路徑；工具拒絕現有檔案及來源等於目標。把下例日期檔名換成實際檔名：

```powershell
.\.venv\Scripts\python.exe scripts\manage_database.py restore --source data\backups\smashcoach-日期-編號.db --target data\smashcoach-restored.db
.\.venv\Scripts\python.exe scripts\manage_database.py check --source data\smashcoach-restored.db
```

3. 核對會員、紀錄數量與所需時間點。停止後台，將本機 `.env` 的 `SQLITE_PATH` 設為 `data/smashcoach-restored.db`，再啟動並確認 health 與會員紀錄。
4. 原資料庫保留；要回退，停止後台後切回原 `SQLITE_PATH`，不要直接覆蓋運作中的檔案。本次沒有對正式資料庫執行還原。

備份只支援檔案式 SQLite；SQL Server 使用自己的備份程序，記憶體測試庫不觸發自動備份。備份內密碼仍是雜湊，但快照包含私人資料，不能分享或提交 Git（`.db` 已忽略）。

## API 相容

`GET /api/progress/{skillName}?version=pose-phase-v3` 回應新增 `selectedVersion` 和 `availableVersions`，舊欄位保留；不傳版本時預設最近紀錄的版本。舊無版本資料的代號為 `legacy-unknown`。沒有提供混算版本選項。

## 驗證

Flutter 完整 93 項測試通過；新增會員更新／401／舊憑證競態、背景舊401不取消新登入、離線保留／登出競態、101 筆分頁、版本切換及重新登入入口測試。憑證刪除先排入儲存佇列，再通知頁面，避免重新載入仍使用舊憑證。
後台 11 項測試通過（兩則既有套件棄用警告），涵蓋空白驗證、版本分開／舊資料保留、101 筆分頁、檔案備份／還原、拒絕覆蓋與損壞檔案；使用隔離資料庫。

已為正式 SQLite 建立並驗證獨立快照，會員 2、分析 3、分項 15、回饋 9、細節 19；原紀錄未修改。後台重啟後 health 正常，版本篩選參數已出現在 OpenAPI，啟動自動快照確實建立。

實際中文渲染：`preview/stability/history.png`、`versions.png`、`expired.png` 已檢視；趨勢先顯示版本與分數，詳細說明移至下方，版本以中文名稱呈現。這些頁面使用隔離假資料，不代表正式帳號新增紀錄。Android 安裝曾遇到模擬器系統服務未就緒和安裝等待；只做保留資料更新及重新開機，不卸載、不 wipe-data。

最終通用 debug APK 已使用 `adb install -r` 成功更新並啟動，已安裝的 base.apk SHA256 與最終建置檔一致。實際確認 APP 可開啟既有頁面與圖片，當前程序 Flutter／AndroidRuntime 錯誤日誌無輸出；後台 health 正常，正式資料庫再次檢查完整性與筆數相同。最後一次 Flutter 靜態檢查無問題、93 項測試通過。沒有使用使用者密碼實測正式帳號的登入／登出；會員狀態、重新登入與離線／競態流程由隔離測試驗證。未量測真機 FPS、長時間壓力或六小時等待週期，不宣稱所有裝置永不當機。
