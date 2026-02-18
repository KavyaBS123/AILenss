import random
import string
from datetime import datetime, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from ..core.database import get_session
from ..core.security import (
    get_password_hash,
    verify_password,
    create_access_token,
    verify_token,
)
from ..models.user import User
from ..schemas.user import (
    UserCreate,
    UserLogin,
    UserResponse,
    OTPVerify,
    Token,
)

router = APIRouter(prefix="/auth", tags=["auth"])

# Hardcoded OTP for development
DEV_OTP = "123456"

def generate_otp(length: int = 6) -> str:
    """Generate OTP (hardcoded for development)"""
    # Return hardcoded OTP for development
    return DEV_OTP

def get_current_user(token: str, session: Session = Depends(get_session)) -> User:
    """Get current user from token"""
    user_id = verify_token(token)
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        )
    user = session.get(User, int(user_id))
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    return user

@router.post("/register", response_model=dict)
async def register(
    user_data: UserCreate,
    session: Session = Depends(get_session),
):
    """Register a new user"""
    # Validate passwords match
    if user_data.password != user_data.password_confirm:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Passwords do not match",
        )
    
    if len(user_data.password) < 8:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password must be at least 8 characters",
        )
    
    # Check if user already exists
    statement = select(User).where(User.email == user_data.email)
    existing_user = session.exec(statement).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )
    
    # Generate OTP
    otp = generate_otp()
    
    # Create new user
    new_user = User(
        email=user_data.email,
        first_name=user_data.first_name,
        last_name=user_data.last_name,
        phone=user_data.phone,
        hashed_password=get_password_hash(user_data.password),
        otp=otp,
        otp_created_at=datetime.utcnow(),
        is_verified=False,
    )
    
    session.add(new_user)
    session.commit()
    session.refresh(new_user)
    
    return {
        "success": True,
        "message": "User registered successfully. OTP sent to email.",
        "otp": otp,  # Return OTP for development
        "email": new_user.email,
    }

@router.post("/login", response_model=dict)
async def login(
    credentials: UserLogin,
    session: Session = Depends(get_session),
):
    """User login"""
    # Find user by email
    statement = select(User).where(User.email == credentials.email)
    user = session.exec(statement).first()
    
    if not user or not verify_password(credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User account is inactive",
        )
    
    # Generate OTP for login
    otp = generate_otp()
    user.otp = otp
    user.otp_created_at = datetime.utcnow()
    session.add(user)
    session.commit()
    session.refresh(user)
    
    return {
        "success": True,
        "message": "Login successful. OTP sent to email.",
        "otp": otp,  # Return OTP for development
        "email": user.email,
    }

@router.post("/verify-otp", response_model=Token)
async def verify_otp(
    data: OTPVerify,
    session: Session = Depends(get_session),
):
    """Verify OTP and complete authentication"""
    # Find user
    statement = select(User).where(User.email == data.email)
    user = session.exec(statement).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    
    # Verify OTP (accept both hardcoded OTP and user's OTP for flexibility)
    if user.otp != data.otp and data.otp != DEV_OTP:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid OTP",
        )
    
    # Mark user as verified
    user.is_verified = True
    user.otp = None
    user.otp_created_at = None
    session.add(user)
    session.commit()
    session.refresh(user)
    
    # Create access token
    access_token = create_access_token(
        data={"sub": str(user.id)},
        expires_delta=timedelta(minutes=30),
    )
    
    user_response = UserResponse.model_validate(user)
    
    return Token(
        access_token=access_token,
        user=user_response,
    )

@router.get("/me", response_model=UserResponse)
async def get_me(
    token: str,
    session: Session = Depends(get_session),
):
    """Get current user"""
    user = get_current_user(token, session)
    return UserResponse.model_validate(user)

@router.post("/logout")
async def logout(token: str):
    """Logout user"""
    return {"success": True, "message": "Logged out successfully"}

@router.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "ok", "message": "Backend is running"}
