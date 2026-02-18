import os
import shutil
from pathlib import Path
from datetime import datetime
from typing import Optional, List
import mimetypes
from app.core.config import settings

class FileStorageManager:
    """Manages secure file storage for biometric data"""
    
    UPLOAD_DIR = Path(settings.UPLOAD_DIR)
    ALLOWED_EXTENSIONS = set(settings.ALLOWED_EXTENSIONS)
    MAX_FILE_SIZE = settings.MAX_UPLOAD_SIZE_MB * 1024 * 1024  # Convert to bytes
    
    # Subdirectories for different file types
    FACE_DIR = UPLOAD_DIR / "faces"
    VOICE_DIR = UPLOAD_DIR / "voices"
    TEMP_DIR = UPLOAD_DIR / "temp"
    
    @classmethod
    def initialize(cls):
        """Create necessary directories"""
        cls.UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
        cls.FACE_DIR.mkdir(parents=True, exist_ok=True)
        cls.VOICE_DIR.mkdir(parents=True, exist_ok=True)
        cls.TEMP_DIR.mkdir(parents=True, exist_ok=True)
    
    @classmethod
    def _generate_filename(cls, user_id: str, file_type: str, original_filename: str) -> str:
        """Generate a secure filename"""
        timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        ext = Path(original_filename).suffix.lower()
        return f"{user_id}_{file_type}_{timestamp}{ext}"
    
    @classmethod
    def _validate_file(cls, filename: str, file_size: int) -> tuple[bool, Optional[str]]:
        """Validate file before saving"""
        # Check file extension
        ext = Path(filename).suffix.lower().lstrip('.')
        if ext not in cls.ALLOWED_EXTENSIONS:
            return False, f"File extension '{ext}' not allowed. Allowed: {cls.ALLOWED_EXTENSIONS}"
        
        # Check file size
        if file_size > cls.MAX_FILE_SIZE:
            max_mb = settings.MAX_UPLOAD_SIZE_MB
            return False, f"File size exceeds maximum allowed ({max_mb}MB)"
        
        return True, None
    
    @classmethod
    async def save_face_biometric(cls, user_id: str, file_content: bytes, original_filename: str) -> tuple[bool, str]:
        """Save face biometric file"""
        # Validate
        is_valid, error = cls._validate_file(original_filename, len(file_content))
        if not is_valid:
            return False, error
        
        try:
            # Generate secure filename
            filename = cls._generate_filename(user_id, "face", original_filename)
            filepath = cls.FACE_DIR / filename
            
            # Save file
            with open(filepath, 'wb') as f:
                f.write(file_content)
            
            return True, f"faces/{filename}"
        except Exception as e:
            return False, f"Error saving face file: {str(e)}"
    
    @classmethod
    async def save_voice_biometric(cls, user_id: str, file_content: bytes, original_filename: str) -> tuple[bool, str]:
        """Save voice biometric file"""
        # Validate
        is_valid, error = cls._validate_file(original_filename, len(file_content))
        if not is_valid:
            return False, error
        
        try:
            # Generate secure filename
            filename = cls._generate_filename(user_id, "voice", original_filename)
            filepath = cls.VOICE_DIR / filename
            
            # Save file
            with open(filepath, 'wb') as f:
                f.write(file_content)
            
            return True, f"voices/{filename}"
        except Exception as e:
            return False, f"Error saving voice file: {str(e)}"
    
    @classmethod
    def get_file(cls, file_path: str) -> Optional[bytes]:
        """Retrieve a file from storage"""
        try:
            full_path = cls.UPLOAD_DIR / file_path
            
            # Security: prevent path traversal
            if not str(full_path).startswith(str(cls.UPLOAD_DIR)):
                return None
            
            if full_path.exists():
                with open(full_path, 'rb') as f:
                    return f.read()
        except Exception:
            pass
        
        return None
    
    @classmethod
    def delete_file(cls, file_path: str) -> bool:
        """Delete a file from storage"""
        try:
            full_path = cls.UPLOAD_DIR / file_path
            
            # Security: prevent path traversal
            if not str(full_path).startswith(str(cls.UPLOAD_DIR)):
                return False
            
            if full_path.exists():
                full_path.unlink()
                return True
        except Exception:
            pass
        
        return False
    
    @classmethod
    def delete_user_files(cls, user_id: str) -> bool:
        """Delete all files for a user"""
        try:
            deleted_count = 0
            
            # Delete face files
            for face_file in cls.FACE_DIR.glob(f"{user_id}_face_*"):
                face_file.unlink()
                deleted_count += 1
            
            # Delete voice files
            for voice_file in cls.VOICE_DIR.glob(f"{user_id}_voice_*"):
                voice_file.unlink()
                deleted_count += 1
            
            return deleted_count > 0
        except Exception:
            return False
    
    @classmethod
    def get_file_size(cls, file_path: str) -> Optional[int]:
        """Get file size in bytes"""
        try:
            full_path = cls.UPLOAD_DIR / file_path
            
            # Security: prevent path traversal
            if not str(full_path).startswith(str(cls.UPLOAD_DIR)):
                return None
            
            if full_path.exists():
                return full_path.stat().st_size
        except Exception:
            pass
        
        return None
    
    @classmethod
    def get_storage_stats(cls) -> dict:
        """Get storage usage statistics"""
        try:
            total_size = sum(f.stat().st_size for f in cls.UPLOAD_DIR.rglob('*') if f.is_file())
            
            face_count = len(list(cls.FACE_DIR.glob("*.jpg"))) + len(list(cls.FACE_DIR.glob("*.png")))
            voice_count = len(list(cls.VOICE_DIR.glob("*.mp3"))) + len(list(cls.VOICE_DIR.glob("*.wav")))
            
            return {
                "total_size_bytes": total_size,
                "total_size_mb": round(total_size / (1024 * 1024), 2),
                "face_files": face_count,
                "voice_files": voice_count,
                "max_size_mb": settings.MAX_UPLOAD_SIZE_MB,
            }
        except Exception:
            return {
                "total_size_bytes": 0,
                "total_size_mb": 0,
                "face_files": 0,
                "voice_files": 0,
            }
    
    @classmethod
    def cleanup_old_files(cls, days: int = 30) -> int:
        """Delete files older than specified days"""
        try:
            from datetime import timedelta
            
            cutoff_time = datetime.utcnow() - timedelta(days=days)
            deleted_count = 0
            
            for file_path in cls.UPLOAD_DIR.rglob('*'):
                if file_path.is_file():
                    if datetime.fromtimestamp(file_path.stat().st_mtime) < cutoff_time:
                        file_path.unlink()
                        deleted_count += 1
            
            return deleted_count
        except Exception:
            return 0

# Initialize storage on import
FileStorageManager.initialize()
