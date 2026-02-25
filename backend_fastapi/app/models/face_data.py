from datetime import datetime
from enum import Enum
from uuid import UUID, uuid4
from sqlalchemy import Column, String, Enum as SQLEnum, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.sql import func
from sqlmodel import SQLModel, Field, Relationship


class FaceType(str, Enum):
    """Face capture types for biometric registration."""
    STRAIGHT = "straight"
    LEFT = "left"
    RIGHT = "right"


class FaceData(SQLModel, table=True):
    """Face biometric data for users."""

    __tablename__ = "face_data"

    id: str = Field(
        default_factory=lambda: str(uuid4()),
        sa_column=Column(String(36), primary_key=True),
    )
    
    user_id: str = Field(
        sa_column=Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        index=True,
    )
    
    face_type: FaceType = Field(
        sa_column=Column(SQLEnum(FaceType, native_enum=False), nullable=False),
    )
    
    file_path: str = Field(
        sa_column=Column(String, nullable=False),
    )
    
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
        sa_column=Column(DateTime(timezone=True), server_default=func.now()),
    )


# Update User model to include relationship
from sqlmodel import Relationship

class UserWithFaces(SQLModel):
    """User model with faces relationship (for API responses)."""
    id: UUID
    name: str
    email: str | None = None
    phone_number: str | None = None
    faces: list["FaceData"] = Relationship(back_populates="user")
