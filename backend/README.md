# SmashCoach Backend

FastAPI backend for account registration/login, private AI analysis history, and progress trends.

## SQLite local setup (default)

SQLite is built into Python, so SQL Server and an ODBC driver are not required.

1. Copy `.env.example` to `.env` and replace `JWT_SECRET` with a private random value of at least 32 characters.
2. Create the environment and install dependencies:

```powershell
python -m venv .venv
.venv\Scripts\python.exe -m pip install -r requirements.txt
```

3. Start the API from the `backend` directory:

```powershell
.venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

On first startup, the backend automatically creates `data/smashcoach.db` and all required tables. Registrations, password hashes, AI analysis history, and progress data persist in this file. Plain-text passwords are never stored.

OpenAPI is available at `http://127.0.0.1:8000/docs`. Android Emulator connects to the same backend through `http://10.0.2.2:8000/api`; a physical phone must use the computer's LAN IP instead.

To list saved account names and emails without exposing password hashes:

```powershell
.venv\Scripts\python.exe scripts\list_users.py
```

## SQLite 備份與還原

SQLite 自動備份預設在後台啟動後及運行期間每 6 小時建立一次快照，保留於 `data/backups/`。手動執行 `.venv\Scripts\python.exe scripts\manage_database.py backup`；還原只允許全新目標檔案，不覆蓋正式資料。設定、核對與還原步驟見 `../docs/stability_optimization.md`。備份包含私人會員資料，請限制存取並另存可靠位置。

## Optional SQL Server mode

Set `DB_BACKEND=sqlserver`, fill in the `DB_*` settings, run `../database/schema.sql`, and install the optional driver dependencies:

```powershell
.venv\Scripts\python.exe -m pip install -r requirements-sqlserver.txt
```

## Tests

Tests use an isolated in-memory SQLite database and do not modify the real account database:

```powershell
.venv\Scripts\python.exe -m pytest -q
```
