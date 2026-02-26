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
    SMTP_SERVER: str = "smtp.zoho.in"
    SMTP_PORT: int = 465
    SMTP_EMAIL: str = "kavya.bs@contentlens.ai"
    SMTP_PASSWORD: str = "5qSg2Zv2y7f4"
    CORS_ORIGINS: List[str] = ["*"]
    API_STR: str = "/api"
    STORAGE_DIR: str = "./storage"
    FACE_DATA_DIR: str = "face_data"
    VOICE_DATA_DIR: str = "voice_data"
    TEMP_DIR: str = "temp"
    MAX_UPLOAD_SIZE_MB: int = 50
    ALLOWED_EXTENSIONS: List[str] = ["jpg", "jpeg", "png", "wav", "mp3", "mp4", "mov"]
    GOOGLE_CLIENT_ID: str
    ZOHO_CLIENT_ID: str = "your-zoho-client-id-here"  # TODO: Set your actual Zoho client ID
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    class Config:
        env_file = "../.env"
        # Also try loading from backend_fastapi/.env if present
        import os
        if os.path.exists(os.path.join(os.path.dirname(__file__), '../../backend_fastapi/.env')):
            env_file = os.path.join(os.path.dirname(__file__), '../../backend_fastapi/.env')
        env_file_encoding = "utf-8"
        case_sensitive = True

settings = Settings()

# Debug print to show loaded SMTP settings at import time
print("[CONFIG DEBUG] SMTP_SERVER:", settings.SMTP_SERVER)
print("[CONFIG DEBUG] SMTP_PORT:", settings.SMTP_PORT)
print("[CONFIG DEBUG] SMTP_EMAIL:", settings.SMTP_EMAIL)
print("[CONFIG DEBUG] SMTP_PASSWORD:", settings.SMTP_PASSWORD, "(length:", len(settings.SMTP_PASSWORD or ""), ")")
