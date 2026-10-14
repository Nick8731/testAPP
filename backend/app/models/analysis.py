from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import (
    BigInteger,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    String,
    Unicode,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.user import User

record_id_type = BigInteger().with_variant(Integer, "sqlite")


class AnalysisRecord(Base):
    __tablename__ = "AnalysisRecords"
    __table_args__ = (
        CheckConstraint("TotalScore BETWEEN 0 AND 100", name="CK_AnalysisRecords_TotalScore"),
        Index("IX_AnalysisRecords_User_Skill_Date", "UserId", "SkillName", "AnalyzedAt"),
    )

    id: Mapped[int] = mapped_column(
        "AnalysisId", record_id_type, primary_key=True, autoincrement=True
    )
    user_id: Mapped[int] = mapped_column("UserId", ForeignKey("Users.UserId"), nullable=False)
    skill_name: Mapped[str] = mapped_column("SkillName", Unicode(100), nullable=False)
    total_score: Mapped[int] = mapped_column("TotalScore", Integer, nullable=False)
    analyzed_at: Mapped[datetime] = mapped_column(
        "AnalyzedAt", DateTime, nullable=False, server_default=func.current_timestamp()
    )
    created_at: Mapped[datetime] = mapped_column(
        "CreatedAt", DateTime, nullable=False, server_default=func.current_timestamp()
    )
    user: Mapped["User"] = relationship(back_populates="analyses")
    scores: Mapped[list["AnalysisScore"]] = relationship(
        back_populates="analysis", cascade="all, delete-orphan", lazy="selectin"
    )
    feedback: Mapped[list["AnalysisFeedback"]] = relationship(
        back_populates="analysis", cascade="all, delete-orphan", lazy="selectin"
    )
    details: Mapped[list["AnalysisDetail"]] = relationship(
        back_populates="analysis", cascade="all, delete-orphan", lazy="selectin"
    )


class AnalysisScore(Base):
    __tablename__ = "AnalysisScores"
    __table_args__ = (
        CheckConstraint("ScoreValue BETWEEN 0 AND 100", name="CK_AnalysisScores_ScoreValue"),
    )

    id: Mapped[int] = mapped_column(
        "ScoreId", record_id_type, primary_key=True, autoincrement=True
    )
    analysis_id: Mapped[int] = mapped_column(
        "AnalysisId", ForeignKey("AnalysisRecords.AnalysisId", ondelete="CASCADE"), nullable=False, index=True
    )
    name: Mapped[str] = mapped_column("ScoreName", Unicode(100), nullable=False)
    value: Mapped[int] = mapped_column("ScoreValue", Integer, nullable=False)
    analysis: Mapped[AnalysisRecord] = relationship(back_populates="scores")


class AnalysisFeedback(Base):
    __tablename__ = "AnalysisFeedback"
    __table_args__ = (
        CheckConstraint(
            "FeedbackType IN ('GOOD', 'PROBLEM', 'SUGGESTION')",
            name="CK_AnalysisFeedback_Type",
        ),
    )

    id: Mapped[int] = mapped_column(
        "FeedbackId", record_id_type, primary_key=True, autoincrement=True
    )
    analysis_id: Mapped[int] = mapped_column(
        "AnalysisId", ForeignKey("AnalysisRecords.AnalysisId", ondelete="CASCADE"), nullable=False, index=True
    )
    feedback_type: Mapped[str] = mapped_column("FeedbackType", String(30), nullable=False)
    content: Mapped[str] = mapped_column("Content", Unicode(1000), nullable=False)
    analysis: Mapped[AnalysisRecord] = relationship(back_populates="feedback")


class AnalysisDetail(Base):
    __tablename__ = "AnalysisDetails"

    id: Mapped[int] = mapped_column(
        "DetailId", record_id_type, primary_key=True, autoincrement=True
    )
    analysis_id: Mapped[int] = mapped_column(
        "AnalysisId", ForeignKey("AnalysisRecords.AnalysisId", ondelete="CASCADE"), nullable=False, index=True
    )
    name: Mapped[str] = mapped_column("DetailName", Unicode(100), nullable=False)
    value: Mapped[str] = mapped_column("DetailValue", Unicode(255), nullable=False)
    analysis: Mapped[AnalysisRecord] = relationship(back_populates="details")
