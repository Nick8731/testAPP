# Architecture

```text
Flutter App
  ├─ UI
  ├─ Video
  ├─ Pose Detection
  └─ Rule-based Analysis
        ↓ HTTPS / REST / JSON
FastAPI Backend
  ├─ Auth
  ├─ JWT
  ├─ Analysis API
  └─ Progress API
        ↓
SQL Server
```

## Flutter
- UI、影片播放、Pose Detection、第一版規則式分析、呼叫 REST API。

## FastAPI
- 註冊、登入、JWT、權限、分析紀錄、進步趨勢。

## SQL Server
- Users
- AnalysisRecords
- AnalysisScores
- AnalysisFeedback
- AnalysisDetails

## 禁止
- Flutter 直接連 DB
- App 內寫 DB 帳密
- 明文密碼
- Git 內提交 Secret
