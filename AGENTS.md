# AGENTS.md

Codex / coding agent 修改前，先閱讀 README.md 與 docs/。

## 不可破壞規則

- 不要重寫目前可運作的 AI 骨架流程。
- 不要重複建立 `BadmintonSkill`。
- `BadmintonSkill` 目前在 `lib/test/test_skill.dart`。
- 新技術分析器放在 `lib/analysis/`。
- 共用角度計算放在 `pose_angle_utils.dart`。
- 所有技術評分結果統一使用 `SkillAnalysisResult`。
- Flutter 不直接連 SQL Server。
- 所有資料經 REST API。
- 密碼禁止明文儲存。
- Backend 使用安全密碼雜湊與 JWT。
- `.env`、JWT Secret、DB 密碼不得提交到版本控制。

## 修改後驗證

Flutter：
```bash
flutter analyze
```

Backend：
```bash
pytest
```

## 第一個主要任務

1. FastAPI 專案骨架
2. SQL Server 連線
3. Users 資料表
4. 註冊 API
5. 登入 API
6. JWT
7. 分析紀錄 POST / GET
8. 進步趨勢 API
9. Flutter 串接 API
