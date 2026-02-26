from typing import Optional
from pydantic import BaseModel, EmailStr


class GoogleLoginRequest(BaseModel):
    id_token: str


class GoogleUserInfo(BaseModel):
    """Google user info returned for new users registration"""
    google_id: str
    email: str
    name: str


class GoogleSignInResponse(BaseModel):
    """Response for Google Sign-In that checks user existence"""
    success: Optional[bool] = False
    user_exists: Optional[bool] = False
    user_id: Optional[str] = ""
    token: Optional[str] = None  # Only for existing users
    name: Optional[str] = ""
    email: Optional[str] = ""
    phone_number: Optional[str] = ""
    google_info: Optional[GoogleUserInfo] = None  # For new users, pre-fill registration form
    message: Optional[str] = ""


class RegistrationRequest(BaseModel):
    """Request to register a new user with password"""
    name: str
    email: EmailStr
    password: str
    google_id: Optional[str] = None  # For Google Sign-In registrations


class EmailAuthRequest(BaseModel):
    """Request to sign in or register with email"""
    name: Optional[str] = None
    email: EmailStr
    google_id: Optional[str] = None


class EmailCheckResponse(BaseModel):
    """Response for checking if email exists - indicates if user already exists"""
    success: bool
    message: str
    user_exists: bool  # True if email is already registered


class EmailSendOtpRequest(BaseModel):
    """Request to send OTP to email"""
    email: EmailStr
    name: Optional[str] = None  # Name for new user account creation

    def __init__(self, **data):
        print("EmailSendOtpRequest instantiated with:", data)
        super().__init__(**data)


class EmailSendOtpResponse(BaseModel):
    """Response for sending OTP to email"""
    success: bool
    message: str
    user_exists: bool  # True if email is already registered


class EmailVerifyOtpRequest(BaseModel):
    """Request to verify OTP for email"""
    email: EmailStr
    otp: str
    name: Optional[str] = None  # User's name for new account creation
    google_id: Optional[str] = None  # User's Google ID if registering via Google


class PhoneSendOtpRequest(BaseModel):
    phone_number: str


class PhoneSendOtpResponse(BaseModel):
    """Response for sending OTP - indicates if user already exists"""
    success: bool
    message: str
    user_exists: bool  # True if phone is already registered


class PhoneVerifyOtpRequest(BaseModel):
    phone_number: str
    otp: str
    name: Optional[str] = None  # User's name for account creation
    google_id: Optional[str] = None  # User's Google ID if registering via Google


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int


class AuthResponse(BaseModel):
    token: TokenResponse
    user_id: str
    name: str
    email: Optional[str] = None
    phone_number: Optional[str] = None
    user_exists: bool  # True if user already existed, False if just created
