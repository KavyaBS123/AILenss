from typing import Optional
from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    """User registration schema"""
    email: EmailStr
    first_name: str
    last_name: str
    phone: str
    password: str
    password_confirm: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "first_name": "John",
                "last_name": "Doe",
                "phone": "+1234567890",
                "password": "SecurePassword123!",
                "password_confirm": "SecurePassword123!",
            }
        }

class UserLogin(BaseModel):
    """User login schema"""
    email: EmailStr
    password: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "password": "SecurePassword123!",
            }
        }

class OTPVerify(BaseModel):
    """OTP verification schema"""
    email: EmailStr
    otp: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "otp": "123456",
            }
        }

class UserResponse(BaseModel):
    """User response schema"""
    id: int
    email: str
    first_name: str
    last_name: str
    phone: str
    is_active: bool
    is_verified: bool
    face_registered: bool
    voice_registered: bool
    
    class Config:
        from_attributes = True

class Token(BaseModel):
    """Token response schema"""
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
