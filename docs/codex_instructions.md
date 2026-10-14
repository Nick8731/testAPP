# Codex Task Instructions

## 目標
不要重做現有 Flutter AI Pose 功能。優先完成會員、REST API、SQL Server、分析歷史與進步趨勢。

## Backend 建議結構
```text
backend/
├─ app/
│  ├─ main.py
│  ├─ api/
│  ├─ models/
│  ├─ schemas/
│  ├─ services/
│  ├─ db/
│  └─ core/
├─ tests/
├─ requirements.txt
└─ .env.example
```

## 技術
- FastAPI
- SQLAlchemy
- pyodbc
- SQL Server
- JWT
- 安全密碼雜湊
- Pydantic

## Phase 1
建立 backend、DB 連線、Users、register、login、JWT。

## Phase 2
建立分析紀錄 POST/GET/DETAIL/DELETE，且使用者只能存取自己的資料。

## Phase 3
建立 `/api/progress/{skillName}`。

## Phase 4
Backend 穩定後再修改 Flutter，新增：
- api_service.dart
- auth_service.dart
- analysis_service.dart
- login_screen.dart
- register_screen.dart
- analysis_history_screen.dart
- analysis_record_detail_screen.dart
- progress_screen.dart
