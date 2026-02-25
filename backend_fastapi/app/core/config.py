from typing import List
from pydantic import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str
    """Application settings loaded from environment variables"""
    PROJECT_NAME: str = "AILens"
    ENVIRONMENT: str = "development"
    DEBUG: bool = False
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    OTP_EXPIRY_MINUTES: int = 10
    SMTP_SERVER: str = "smtp.zoho.com"
    SMTP_PORT: int = 465
    SMTP_EMAIL: str = "kavya.bs@contentlens.ai"
    SMTP_PASSWORD: str = "78Quq2ZSBk2u"  # Set via environment variable or .env file
    CORS_ORIGINS: List[str] = ["*"]
    API_STR: str = "/api"
    STORAGE_DIR: str = "./storage"
    FACE_DATA_DIR: str = "face_data"
    VOICE_DATA_DIR: str = "voice_data"
    TEMP_DIR: str = "temp"
    MAX_UPLOAD_SIZE_MB: int = 50
    ALLOWED_EXTENSIONS: List[str] = ["jpg", "jpeg", "png", "wav", "mp3", "mp4", "mov"]
    GOOGLE_CLIENT_ID: str
    class Config:
        env_file = "../.env"
        # Also try loading from backend_fastapi/.env if present
        import os
        if os.path.exists(os.path.join(os.path.dirname(__file__), '../../backend_fastapi/.env')):
            env_file = os.path.join(os.path.dirname(__file__), '../../backend_fastapi/.env')
        env_file_encoding = "utf-8"
        case_sensitive = True

settings = Settings()
