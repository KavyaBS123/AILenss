from datetime import datetime, timedelta
from typing import Dict, Tuple
import random
from app.core.config import settings


class OtpService:
    """In-memory OTP store for development (replace with Redis in production)."""

    _store: Dict[str, Tuple[str, datetime]] = {}

    @staticmethod
    def generate_otp(length: int = 6) -> str:
        """Generate a random OTP of specified length"""
        return ''.join([str(random.randint(0, 9)) for _ in range(length)])

    @classmethod
    def send_otp(cls, identifier: str) -> str:
        """
        Generate and store OTP for given identifier (phone or email)
        Args:
            identifier: Phone number or email address
        Returns:
            str: Generated OTP code
        """
        otp_code = cls.generate_otp()
        expires_at = datetime.utcnow() + timedelta(minutes=settings.OTP_EXPIRY_MINUTES)
        cls._store[identifier] = (otp_code, expires_at)
        return otp_code

    @classmethod
    def verify_otp(cls, phone_number: str, code: str) -> bool:
        record = cls._store.get(phone_number)
        if not record:
            return False
        otp_code, expires_at = record
        if datetime.utcnow() > expires_at:
            cls._store.pop(phone_number, None)
            return False
        if code != otp_code:
            return False
        cls._store.pop(phone_number, None)
        return True
