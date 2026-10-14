from datetime import datetime

from pydantic import Field

from app.schemas.common import ApiModel


class ProgressPoint(ApiModel):
    date: datetime
    score: int


class ProgressResponse(ApiModel):
    skill_name: str = Field(serialization_alias="skillName")
    latest_score: int | None = Field(serialization_alias="latestScore")
    previous_score: int | None = Field(serialization_alias="previousScore")
    change: int | None
    best_score: int | None = Field(serialization_alias="bestScore")
    records: list[ProgressPoint]
    selected_version: str | None = Field(default=None, serialization_alias='selectedVersion')
    available_versions: list[str] = Field(default_factory=list, serialization_alias='availableVersions')
