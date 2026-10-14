# REST API Specification

Base path: `/api`

## Auth

### POST /api/auth/register
```json
{"name":"User","email":"user@example.com","password":"password"}
```

### POST /api/auth/login
Response:
```json
{"accessToken":"jwt","tokenType":"bearer"}
```

### GET /api/users/me
Header:
```text
Authorization: Bearer <token>
```

## Analysis

### POST /api/analysis
```json
{
  "skillName":"殺球",
  "totalScore":84,
  "scores":[{"name":"架拍","score":85},{"name":"手臂伸展","score":90}],
  "goodPoints":["手臂伸展良好"],
  "problems":["下肢準備不足"],
  "suggestions":["殺球前保持膝蓋彈性"],
  "details":{"架拍手肘角度":"108.5°"}
}
```

### GET /api/analysis
支援：`?skill=殺球&page=1&pageSize=20`

### GET /api/analysis/{analysisId}

### DELETE /api/analysis/{analysisId}

## Progress

### GET /api/progress/{skillName}
```json
{
  "skillName":"殺球",
  "latestScore":85,
  "previousScore":81,
  "change":4,
  "bestScore":88,
  "records":[
    {"date":"2026-09-01T10:00:00","score":72},
    {"date":"2026-09-05T10:00:00","score":81},
    {"date":"2026-09-11T10:00:00","score":85}
  ]
}
```
