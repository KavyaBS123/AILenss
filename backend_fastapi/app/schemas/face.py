from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel

class FaceDataBase(BaseModel):
    user_id: str
    face_type: str
    file_path: str
    file_name: str
    embedding: Optional[list[float]] = None

class FaceDataCreate(FaceDataBase):
    embedding: list[float]

class FaceDataRead(FaceDataBase):
    id: str
    uploaded_at: datetime
    created_at: datetime
    updated_at: datetime
    embedding: Optional[list[float]] = None

    class Config:
        orm_mode = True
