from fastapi import APIRouter, Query
from sqlalchemy import select

from app.api.dependencies import CurrentUser, DbSession
from app.models.analysis import AnalysisRecord
from app.schemas.progress import ProgressPoint, ProgressResponse

router = APIRouter()


@router.get("/{skill_name}", response_model=ProgressResponse)
def get_progress(skill_name: str, db: DbSession, current_user: CurrentUser,
                 version: str | None = Query(default=None, min_length=1, max_length=100)) -> ProgressResponse:
    records = db.scalars(
        select(AnalysisRecord)
        .where(
            AnalysisRecord.user_id == current_user.id,
            AnalysisRecord.skill_name == skill_name,
        )
        .order_by(AnalysisRecord.analyzed_at.asc(), AnalysisRecord.id.asc())
    ).all()
    def record_version(record):
        return next((d.value.strip() for d in record.details
                     if d.name in ('評分版本', '分析版本') and d.value.strip()), 'legacy-unknown')

    versions = list(dict.fromkeys(record_version(r) for r in reversed(records)))
    selected = version if version is not None else (versions[0] if versions else None)
    records = [r for r in records if record_version(r) == selected]
    scores = [record.total_score for record in records]
    latest = scores[-1] if scores else None
    previous = scores[-2] if len(scores) > 1 else None
    return ProgressResponse(
        skill_name=skill_name,
        latest_score=latest,
        previous_score=previous,
        change=latest - previous if latest is not None and previous is not None else None,
        best_score=max(scores) if scores else None,
        records=[ProgressPoint(date=record.analyzed_at, score=record.total_score) for record in records],
        selected_version=selected,
        available_versions=versions,
    )
