# Database Design

## Users
- UserId INT IDENTITY PK
- Name NVARCHAR(100)
- Email NVARCHAR(255) UNIQUE
- PasswordHash NVARCHAR(255)
- CreatedAt DATETIME2
- UpdatedAt DATETIME2

## AnalysisRecords
- AnalysisId BIGINT IDENTITY PK
- UserId FK
- SkillName NVARCHAR(100)
- TotalScore INT
- AnalyzedAt DATETIME2
- CreatedAt DATETIME2

## AnalysisScores
不同技術的分項不同，因此使用 key/value 子表。
- ScoreId BIGINT IDENTITY PK
- AnalysisId FK
- ScoreName NVARCHAR(100)
- ScoreValue INT

## AnalysisFeedback
- FeedbackId BIGINT IDENTITY PK
- AnalysisId FK
- FeedbackType NVARCHAR(30): GOOD / PROBLEM / SUGGESTION
- Content NVARCHAR(1000)

## AnalysisDetails
- DetailId BIGINT IDENTITY PK
- AnalysisId FK
- DetailName NVARCHAR(100)
- DetailValue NVARCHAR(255)
