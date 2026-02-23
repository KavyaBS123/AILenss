import secrets
from pathlib import Path
from datetime import datetime
from typing import Optional
from app.core.config import settings


class FileStorageManager:
    """Secure local storage for biometric files (S3-ready abstraction)."""

    BASE_DIR = Path(settings.STORAGE_DIR)
    FACE_DIR = BASE_DIR / settings.FACE_DATA_DIR
    VOICE_DIR = BASE_DIR / settings.VOICE_DATA_DIR
    TEMP_DIR = BASE_DIR / settings.TEMP_DIR
    ALLOWED_EXTENSIONS = set(settings.ALLOWED_EXTENSIONS)
    MAX_FILE_SIZE = settings.MAX_UPLOAD_SIZE_MB * 1024 * 1024

    @classmethod
    def initialize(cls) -> None:
        """Create storage directories if they don't exist."""
        cls.FACE_DIR.mkdir(parents=True, exist_ok=True)
        cls.VOICE_DIR.mkdir(parents=True, exist_ok=True)
        cls.TEMP_DIR.mkdir(parents=True, exist_ok=True)

    @classmethod
    def _validate_file(cls, filename: str, file_size: int) -> Optional[str]:
        """Validate file extension and size."""
        ext = Path(filename).suffix.lower().lstrip(".")
        if ext not in cls.ALLOWED_EXTENSIONS:
            return f"File extension '{ext}' not allowed."
        if file_size > cls.MAX_FILE_SIZE:
            return f"File size exceeds {settings.MAX_UPLOAD_SIZE_MB}MB."
        return None

    @classmethod
    def _user_dir(cls, base_dir: Path, user_id: str) -> Path:
        """Get or create user-specific directory."""
        user_dir = base_dir / user_id
        user_dir.mkdir(parents=True, exist_ok=True)
        return user_dir

    @classmethod
    def _secure_filename(cls, original_filename: str) -> str:
        """Generate secure filename with timestamp and random token."""
        ext = Path(original_filename).suffix.lower()
        token = secrets.token_urlsafe(12)
        timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        return f"{timestamp}_{token}{ext}"

    @classmethod
    def save_face(cls, user_id: str, content: bytes, original_filename: str) -> tuple[bool, str]:
        """Save face biometric file and return (success, relative_path_or_error)."""
        error = cls._validate_file(original_filename, len(content))
        if error:
            return False, error
        filename = cls._secure_filename(original_filename)
        path = cls._user_dir(cls.FACE_DIR, user_id) / filename
        path.write_bytes(content)
        return True, str(path.relative_to(cls.BASE_DIR)).replace("\\", "/")

    @classmethod
    def save_voice(cls, user_id: str, content: bytes, original_filename: str) -> tuple[bool, str]:
        """Save voice biometric file and return (success, relative_path_or_error)."""
        error = cls._validate_file(original_filename, len(content))
        if error:
            return False, error
        filename = cls._secure_filename(original_filename)
        path = cls._user_dir(cls.VOICE_DIR, user_id) / filename
        path.write_bytes(content)
        return True, str(path.relative_to(cls.BASE_DIR)).replace("\\", "/")

    @classmethod
    def get_file(cls, relative_path: str) -> Optional[bytes]:
        """Retrieve file contents with path traversal validation."""
        full_path = cls.BASE_DIR / relative_path
        if not str(full_path.resolve()).startswith(str(cls.BASE_DIR.resolve())):
            return None
        if full_path.exists():
            return full_path.read_bytes()
        return None

    @classmethod
    def delete_file(cls, relative_path: str) -> bool:
        """Delete file with path traversal validation."""
        full_path = cls.BASE_DIR / relative_path
        if not str(full_path.resolve()).startswith(str(cls.BASE_DIR.resolve())):
            return False
        if full_path.exists():
            full_path.unlink()
            return True
        return False
