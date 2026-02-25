from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.sql import func
from sqlmodel import SQLModel, Field, Relationship


class FaceData(SQLModel, table=True):
    """Face image records for user identification."""

    __tablename__ = "face_data"

    id: str = Field(
        default_factory=lambda: str(uuid4()),
        sa_column=Column(String(36), primary_key=True),
    )
    
    user_id: str = Field(
        sa_column=Column(
            String(36),
            ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
            index=True,
        ),
    )
    
    # Face type: "straight", "left", "right"
    face_type: str = Field(
        sa_column=Column(String, nullable=False, index=True),
    )
    
    # Path to stored image file
    file_path: str = Field(
        sa_column=Column(String, nullable=False),
    )
    
    # File name for retrieval
    file_name: str = Field(
        sa_column=Column(String, nullable=False),
    )
    
    # Metadata
    uploaded_at: datetime = Field(
        default_factory=datetime.utcnow,
        sa_column=Column(DateTime(timezone=True), server_default=func.now()),
    )
    
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
        sa_column=Column(DateTime(timezone=True), server_default=func.now()),
    )
    
    updated_at: datetime = Field(
        default_factory=datetime.utcnow,
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now()),
    )
