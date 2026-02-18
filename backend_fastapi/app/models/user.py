from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field

class User(SQLModel, table=True):
    """User model with biometric data storage"""
    __tablename__ = "users"
    
    # Basic user info
    id: Optional[int] = Field(default=None, primary_key=True)
    email: str = Field(unique=True, index=True)
    first_name: str
    last_name: str
    phone: str
    hashed_password: str
    
    # Account status
    is_active: bool = Field(default=True)
    is_verified: bool = Field(default=False)
    
    # Authentication
    otp: Optional[str] = Field(default=None)
    otp_created_at: Optional[datetime] = Field(default=None)
    
    # Biometric data - Face recognition
    face_data: Optional[str] = Field(default=None)  # Stored as JSON or base64
    face_embedding: Optional[str] = Field(default=None)  # Face embedding vector
    face_registered: bool = Field(default=False)
    
    # Biometric data - Voice recognition
    voice_data: Optional[str] = Field(default=None)  # Stored as base64 or file path
    voice_embedding: Optional[str] = Field(default=None)  # Voice embedding vector
    voice_registered: bool = Field(default=False)
    
    # Timestamps
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    face_registered_at: Optional[datetime] = Field(default=None)
    voice_registered_at: Optional[datetime] = Field(default=None)
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "first_name": "John",
                "last_name": "Doe",
                "phone": "+1234567890",
            }
        }
