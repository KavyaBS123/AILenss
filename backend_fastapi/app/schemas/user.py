from typing import Optional
from uuid import UUID
from pydantic import BaseModel, EmailStr


class UserRead(BaseModel):
    id: UUID
    name: str
    email: Optional[EmailStr] = None
    phone_number: Optional[str] = None
    is_active: bool
    is_verified: bool
    google_id: Optional[str] = None
    face_data_path: Optional[str] = None
    voice_data_path: Optional[str] = None

    class Config:
        from_attributes = True
