from pathlib import Path
from typing import List
from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables"""

    model_config = SettingsConfigDict(
        env_file=Path(__file__).resolve().parents[2] / ".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    PROJECT_NAME: str = "AILens"
    ENVIRONMENT: str = "development"
    DEBUG: bool = False

    # Database Configuration
    DATABASE_URL: str

    # Security Configuration
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    # OTP Configuration
    OTP_EXPIRY_MINUTES: int = 10

    # Email Configuration (SMTP)
    SMTP_SERVER: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_EMAIL: str = "kavya.bs@contentlens.ai"
    SMTP_PASSWORD: str = ""  # Set via environment variable or .env file

    # CORS Configuration
    CORS_ORIGINS: List[str] = ["*"]

    # API Configuration
    API_STR: str = "/api"

    # File Storage Configuration
    STORAGE_DIR: str = "./storage"
    FACE_DATA_DIR: str = "face_data"
    VOICE_DATA_DIR: str = "voice_data"
    TEMP_DIR: str = "temp"
    MAX_UPLOAD_SIZE_MB: int = 50
    ALLOWED_EXTENSIONS: List[str] = ["jpg", "jpeg", "png", "wav", "mp3", "mp4", "mov"]

    # Google OAuth Configuration
    GOOGLE_CLIENT_ID: str

    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def parse_cors_origins(cls, value):
        if isinstance(value, str):
            return [item.strip() for item in value.split(",") if item.strip()]
        return value


settings = Settings()
