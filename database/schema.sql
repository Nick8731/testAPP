CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE AnalysisRecords (
    AnalysisId BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    SkillName NVARCHAR(100) NOT NULL,
    TotalScore INT NOT NULL,
    AnalyzedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_AnalysisRecords_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT CK_AnalysisRecords_TotalScore CHECK (TotalScore BETWEEN 0 AND 100)
);

CREATE TABLE AnalysisScores (
    ScoreId BIGINT IDENTITY(1,1) PRIMARY KEY,
    AnalysisId BIGINT NOT NULL,
    ScoreName NVARCHAR(100) NOT NULL,
    ScoreValue INT NOT NULL,
    CONSTRAINT FK_AnalysisScores_AnalysisRecords FOREIGN KEY (AnalysisId) REFERENCES AnalysisRecords(AnalysisId) ON DELETE CASCADE,
    CONSTRAINT CK_AnalysisScores_ScoreValue CHECK (ScoreValue BETWEEN 0 AND 100)
);

CREATE TABLE AnalysisFeedback (
    FeedbackId BIGINT IDENTITY(1,1) PRIMARY KEY,
    AnalysisId BIGINT NOT NULL,
    FeedbackType NVARCHAR(30) NOT NULL,
    Content NVARCHAR(1000) NOT NULL,
    CONSTRAINT FK_AnalysisFeedback_AnalysisRecords FOREIGN KEY (AnalysisId) REFERENCES AnalysisRecords(AnalysisId) ON DELETE CASCADE,
    CONSTRAINT CK_AnalysisFeedback_Type CHECK (FeedbackType IN ('GOOD', 'PROBLEM', 'SUGGESTION'))
);

CREATE TABLE AnalysisDetails (
    DetailId BIGINT IDENTITY(1,1) PRIMARY KEY,
    AnalysisId BIGINT NOT NULL,
    DetailName NVARCHAR(100) NOT NULL,
    DetailValue NVARCHAR(255) NOT NULL,
    CONSTRAINT FK_AnalysisDetails_AnalysisRecords FOREIGN KEY (AnalysisId) REFERENCES AnalysisRecords(AnalysisId) ON DELETE CASCADE
);

CREATE INDEX IX_AnalysisRecords_User_Skill_Date ON AnalysisRecords(UserId, SkillName, AnalyzedAt DESC);
CREATE INDEX IX_AnalysisScores_AnalysisId ON AnalysisScores(AnalysisId);
CREATE INDEX IX_AnalysisFeedback_AnalysisId ON AnalysisFeedback(AnalysisId);
CREATE INDEX IX_AnalysisDetails_AnalysisId ON AnalysisDetails(AnalysisId);
