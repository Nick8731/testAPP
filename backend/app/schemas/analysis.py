from datetime import datetime

from pydantic import Field, field_validator

from app.schemas.common import ApiModel


class ScoreInput(ApiModel):
    name: str = Field(min_length=1, max_length=100)
    score: int = Field(ge=0, le=100)

    @field_validator('name', mode='before')
    @classmethod
    def normalize_name(cls, value):
        return value.strip() if isinstance(value, str) else value


class AnalysisCreate(ApiModel):
    skill_name: str = Field(min_length=1, max_length=100, validation_alias="skillName")
    total_score: int = Field(ge=0, le=100, validation_alias="totalScore")
    scores: list[ScoreInput] = Field(default_factory=list, max_length=50)
    good_points: list[str] = Field(default_factory=list, max_length=50, validation_alias="goodPoints")
    problems: list[str] = Field(default_factory=list, max_length=50)
    suggestions: list[str] = Field(default_factory=list, max_length=50)
    details: dict[str, str] = Field(default_factory=dict)
    analyzed_at: datetime | None = Field(default=None, validation_alias="analyzedAt")

    @field_validator("skill_name", mode='before')
    @classmethod
    def strip_skill_name(cls, value: str) -> str:
        return value.strip() if isinstance(value, str) else value

    @field_validator("good_points", "problems", "suggestions")
    @classmethod
    def validate_feedback(cls, values: list[str]) -> list[str]:
        if any(not value.strip() or len(value) > 1000 for value in values):
            raise ValueError("feedback must contain 1 to 1000 characters")
        return [value.strip() for value in values]

    @field_validator("details")
    @classmethod
    def validate_details(cls, values: dict[str, str]) -> dict[str, str]:
        if len(values) > 100 or any(
            not key.strip() or len(key) > 100 or len(value) > 255 for key, value in values.items()
        ):
            raise ValueError("invalid analysis details")
        return {key.strip(): value for key, value in values.items()}


class ScoreResponse(ApiModel):
    name: str
    score: int


class AnalysisSummary(ApiModel):
    analysis_id: int = Field(serialization_alias="analysisId")
    skill_name: str = Field(serialization_alias="skillName")
    total_score: int = Field(serialization_alias="totalScore")
    analyzed_at: datetime = Field(serialization_alias="analyzedAt")


class AnalysisResponse(AnalysisSummary):
    scores: list[ScoreResponse]
    good_points: list[str] = Field(serialization_alias="goodPoints")
    problems: list[str]
    suggestions: list[str]
    details: dict[str, str]


class AnalysisPage(ApiModel):
    items: list[AnalysisSummary]
    page: int
    page_size: int = Field(serialization_alias="pageSize")
    total: int
