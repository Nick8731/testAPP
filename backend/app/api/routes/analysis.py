from fastapi import APIRouter, HTTPException, Query, Response, status
from sqlalchemy import func, select
from sqlalchemy.orm import selectinload

from app.api.dependencies import CurrentUser, DbSession
from app.models.analysis import AnalysisRecord
from app.schemas.analysis import AnalysisCreate, AnalysisPage, AnalysisResponse
from app.services.analysis_service import build_analysis, to_response, to_summary

router = APIRouter()


def owned_record_query(user_id: int):
    return (
        select(AnalysisRecord)
        .where(AnalysisRecord.user_id == user_id)
        .options(
            selectinload(AnalysisRecord.scores),
            selectinload(AnalysisRecord.feedback),
            selectinload(AnalysisRecord.details),
        )
    )


@router.post("", response_model=AnalysisResponse, status_code=status.HTTP_201_CREATED)
def create_analysis(payload: AnalysisCreate, db: DbSession, current_user: CurrentUser) -> AnalysisResponse:
    record = build_analysis(payload, current_user.id)
    db.add(record)
    db.commit()
    db.refresh(record)
    return to_response(record)


@router.get("", response_model=AnalysisPage)
def list_analyses(
    db: DbSession,
    current_user: CurrentUser,
    skill: str | None = Query(default=None, min_length=1, max_length=100),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, alias="pageSize", ge=1, le=100),
) -> AnalysisPage:
    filters = [AnalysisRecord.user_id == current_user.id]
    if skill is not None:
        filters.append(AnalysisRecord.skill_name == skill)
    total = db.scalar(select(func.count(AnalysisRecord.id)).where(*filters)) or 0
    records = db.scalars(
        select(AnalysisRecord)
        .where(*filters)
        .order_by(AnalysisRecord.analyzed_at.desc(), AnalysisRecord.id.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
    ).all()
    return AnalysisPage(
        items=[to_summary(record) for record in records],
        page=page,
        page_size=page_size,
        total=total,
    )


@router.get("/{analysis_id}", response_model=AnalysisResponse)
def get_analysis(analysis_id: int, db: DbSession, current_user: CurrentUser) -> AnalysisResponse:
    record = db.scalar(owned_record_query(current_user.id).where(AnalysisRecord.id == analysis_id))
    if record is None:
        raise HTTPException(status_code=404, detail="找不到分析紀錄")
    return to_response(record)


@router.delete("/{analysis_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_analysis(analysis_id: int, db: DbSession, current_user: CurrentUser) -> Response:
    record = db.scalar(owned_record_query(current_user.id).where(AnalysisRecord.id == analysis_id))
    if record is None:
        raise HTTPException(status_code=404, detail="找不到分析紀錄")
    db.delete(record)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
