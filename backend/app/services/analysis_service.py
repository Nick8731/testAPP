from app.models.analysis import AnalysisDetail, AnalysisFeedback, AnalysisRecord, AnalysisScore
from app.schemas.analysis import AnalysisCreate, AnalysisResponse, AnalysisSummary, ScoreResponse


def build_analysis(payload: AnalysisCreate, user_id: int) -> AnalysisRecord:
    record = AnalysisRecord(user_id=user_id, skill_name=payload.skill_name, total_score=payload.total_score)
    if payload.analyzed_at is not None:
        record.analyzed_at = payload.analyzed_at
    record.scores = [
        AnalysisScore(name=item.name.strip(), value=item.score) for item in payload.scores
    ]
    record.feedback = [
        *(AnalysisFeedback(feedback_type="GOOD", content=value) for value in payload.good_points),
        *(AnalysisFeedback(feedback_type="PROBLEM", content=value) for value in payload.problems),
        *(AnalysisFeedback(feedback_type="SUGGESTION", content=value) for value in payload.suggestions),
    ]
    record.details = [AnalysisDetail(name=key, value=value) for key, value in payload.details.items()]
    return record


def to_summary(record: AnalysisRecord) -> AnalysisSummary:
    return AnalysisSummary(
        analysis_id=record.id,
        skill_name=record.skill_name,
        total_score=record.total_score,
        analyzed_at=record.analyzed_at,
    )


def to_response(record: AnalysisRecord) -> AnalysisResponse:
    feedback_by_type = {"GOOD": [], "PROBLEM": [], "SUGGESTION": []}
    for item in record.feedback:
        feedback_by_type[item.feedback_type].append(item.content)
    return AnalysisResponse(
        **to_summary(record).model_dump(),
        scores=[ScoreResponse(name=item.name, score=item.value) for item in record.scores],
        good_points=feedback_by_type["GOOD"],
        problems=feedback_by_type["PROBLEM"],
        suggestions=feedback_by_type["SUGGESTION"],
        details={item.name: item.value for item in record.details},
    )
