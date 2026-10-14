from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, Integer, String, Unicode, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.analysis import AnalysisRecord


class User(Base):
    __tablename__ = "Users"

    id: Mapped[int] = mapped_column("UserId", Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column("Name", Unicode(100), nullable=False)
    email: Mapped[str] = mapped_column("Email", String(255), nullable=False, unique=True, index=True)
    password_hash: Mapped[str] = mapped_column("PasswordHash", String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        "CreatedAt", DateTime, nullable=False, server_default=func.current_timestamp()
    )
    updated_at: Mapped[datetime] = mapped_column(
        "UpdatedAt",
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
        onupdate=func.current_timestamp(),
    )
    analyses: Mapped[list["AnalysisRecord"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
