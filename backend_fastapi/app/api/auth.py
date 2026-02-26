print("IMPORT OK")
from datetime import timedelta
import os
from pathlib import Path
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Header
from sqlmodel import Session
from app.core.config import settings
from app.core.security import create_access_token, get_password_hash, decode_access_token
from app.core.database import get_session
from app.crud import user as user_crud
from app.crud import face as face_crud
from app.schemas.auth import (
    GoogleLoginRequest,
    GoogleSignInResponse,
    GoogleUserInfo,
    RegistrationRequest,
    EmailAuthRequest,
    EmailCheckResponse,
    EmailSendOtpRequest,
    EmailSendOtpResponse,
    EmailVerifyOtpRequest,
    PhoneSendOtpRequest,
    PhoneSendOtpResponse,
    PhoneVerifyOtpRequest,
    AuthResponse,
    TokenResponse,
)
from app.services.google_auth import verify_google_id_token
from app.services.otp_service import OtpService

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/email/send-otp-test", response_model=EmailSendOtpResponse)
def send_email_otp_test(payload: EmailSendOtpRequest, session: Session = Depends(get_session)):
    """Send OTP to email for verification (test endpoint)"""
    print('A')
    import logging
    print('B')
    print("send_email_otp_test called with:", payload)
    from app.services.email_service import EmailService
    print('C')
    logger = logging.getLogger(__name__)
    print('D')
    print('REACHED OTP ENDPOINT')
    print('E')
    normalized_email = payload.email.strip().lower()
    print('F')
    logger.info(f"📧 OTP request for email: {normalized_email}")
    print('G')
    existing_user = user_crud.get_by_email(session, normalized_email)
    print('H')
    user_exists = existing_user is not None
    print('I')
    import traceback
    print('J')
    try:
        print('K')
        otp_code = OtpService.send_otp(normalized_email)
        print('L')
        logger.info(f"✓ OTP generated: {otp_code}")
        email_sent = EmailService.send_otp_email(normalized_email, otp_code)
        print('N')
        if not email_sent:
            logger.error(f"❌ Failed to send OTP email to: {normalized_email}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to send OTP email. Please try again."
            )
    except Exception as e:
        print('P')
        logger.error(f"❌ Exception in send_email_otp_test: {e}")
        print("\n--- TRACEBACK ---\n" + traceback.format_exc() + "\n--- END TRACEBACK ---\n")
        traceback.print_exc()
        print(f"EXCEPTION: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal Server Error: {e}"
        )
    if user_exists:
        print('Q')
        logger.info(f"✓ User exists for email: {normalized_email} - OTP for sign in")
        message = "OTP sent to your Gmail inbox. Please verify to sign in."
    else:
        print('R')
        logger.info(f"👤 New user for email: {normalized_email} - OTP for registration")
        message = "OTP sent to your Gmail inbox. Please verify to create account."
    print('S')
    print('OTP ENDPOINT SUCCESS')
    return EmailSendOtpResponse(
        success=True,
        message=message,
        user_exists=user_exists
    )
from app.core.security import create_access_token, get_password_hash, decode_access_token
from app.core.database import get_session
from app.crud import user as user_crud
from app.crud import face as face_crud
from app.schemas.auth import (
    GoogleLoginRequest,
    GoogleSignInResponse,
    GoogleUserInfo,
    RegistrationRequest,
    EmailAuthRequest,
    EmailCheckResponse,
    EmailSendOtpRequest,
    EmailSendOtpResponse,
    EmailVerifyOtpRequest,
    PhoneSendOtpRequest,
    PhoneSendOtpResponse,
    PhoneVerifyOtpRequest,
    AuthResponse,
    TokenResponse,
)
from app.services.google_auth import verify_google_id_token
from app.services.otp_service import OtpService



@router.post("/google", response_model=GoogleSignInResponse)
def google_login(payload: GoogleLoginRequest, session: Session = Depends(get_session)):
    import logging
    import time
    logger = logging.getLogger(__name__)
    
    start_time = time.time()
    logger.info(f"🔍 Google Login Request")
    logger.info(f"   Token received: {payload.id_token[:50] if payload.id_token else 'NULL'}...")
    logger.info(f"   Token length: {len(payload.id_token) if payload.id_token else 0}")
    logger.info(f"   Expected Client ID: {settings.GOOGLE_CLIENT_ID}")
    
    if not payload.id_token:
        logger.error("❌ ID token is empty or None!")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="ID token is required")
    
    try:
        logger.info("⏳ Starting Google token verification...")
        verify_start = time.time()
        user_info = verify_google_id_token(payload.id_token, settings.GOOGLE_CLIENT_ID)
        verify_time = time.time() - verify_start
        logger.info(f"✓ Token verified successfully in {verify_time:.2f}s for user: {user_info.get('email')}")
    except Exception as e:
        error_str = str(e)
        logger.error(f"❌ Token verification failed: {error_str}")
        logger.error(f"   Error type: {type(e).__name__}")
        
        # Provide better error messages
        if "timeout" in error_str.lower():
            detail = "Google service is slow - please try again"
        elif "wrong number of segments" in error_str.lower():
            detail = "Invalid token format"
        elif "audience" in error_str.lower():
            detail = "Token not valid for this app configuration"
        else:
            detail = f"Token verification failed: {error_str}"
        
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=detail)

    google_id = user_info.get("sub")
    email = user_info.get("email")
    name = user_info.get("name") or "Google User"

    logger.info(f"✓ Google token decoded - Google ID: {google_id}, Email: {email}")

    # Check if user exists (with timeout protection)
    user = None
    user_exists = False
    normalized_email = email.strip().lower() if email else None
    if google_id:
        logger.info(f"Checking user by Google ID...")
        user = user_crud.get_by_google_id(session, google_id)
    if not user and normalized_email:
        logger.info(f"Checking user by email...")
        user = user_crud.get_by_email(session, normalized_email)
    if not user:
        # Create new user with provided name or default
        user_name = name or "Email User"
        logger.info(f"👤 Creating new user with name: {user_name}")
        try:
            user = user_crud.create_user(
                session,
                name=user_name,
                email=normalized_email,
                google_id=google_id,  # Save google_id from token
                is_verified=True,
            )
            user_exists = False
        except Exception as e:
            # If user was created between check and creation, fetch and sign them in
            logger.warning(f"⚠️ User creation failed (likely duplicate): {e}")
            session.rollback()
            user = user_crud.get_by_email(session, normalized_email)
            if not user:
                raise HTTPException(status_code=500, detail="Failed to create user")
            user_exists = True
    else:
        # Update existing user with name from Google if needed
        if name and user.name in ["Email User", "Google User"]:
            user.name = name
        # Update google_id if not already set
        if google_id and not user.google_id:
            user.google_id = google_id
        user.is_verified = True
        session.add(user)
        session.commit()
        session.refresh(user)
        user_exists = True

    # Always return a valid GoogleSignInResponse
    # Defensive: never return None for any field, use empty string if missing
    # Generate JWT token for the user
    token = ""
    if user and user.id:
        token = create_access_token(data={"sub": str(user.id)})
    return GoogleSignInResponse(
        success=True,
        user_exists=user_exists,
        user_id=str(user.id) if user and user.id else "",
        name=user.name if user and user.name else user_name or "",
        email=user.email if user and user.email else normalized_email or "",
        phone_number=user.phone_number if user and user.phone_number else "",
        message="User signed in successfully" if user_exists else "User registered successfully",
        token=token,
        google_info=None
    )

@router.post("/register", response_model=AuthResponse)
def register_user(payload: RegistrationRequest, session: Session = Depends(get_session)):
    """Register a new user with email and password"""
    import logging
    logger = logging.getLogger(__name__)

    normalized_email = payload.email.strip().lower()
    logger.info(f"📝 Registration Request for email: {normalized_email}")
    
    # Check if user already exists by email
    existing_user = user_crud.get_by_email(session, normalized_email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already registered"
        )
    
    # Validate password (minimum 6 characters)
    if len(payload.password) < 6:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password must be at least 6 characters long"
        )
    
    try:
        # Hash password
        hashed_password = get_password_hash(payload.password)
        
        # Create user with password
        user = user_crud.create_user(
            session,
            name=payload.name,
            email=normalized_email,
            hashed_password=hashed_password,
            google_id=payload.google_id,  # Optional, for Google OAuth users
            is_verified=True,
        )
        
        logger.info(f"✓ User registered successfully with ID: {user.id}")
        
        # Create access token
        token = create_access_token(
            data={"sub": str(user.id)},
            expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
        )
        
        return AuthResponse(
            token=TokenResponse(
                access_token=token,
                expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            ),
            user_id=str(user.id),
            name=user.name,
            email=user.email,
            phone_number=user.phone_number,
        )
    except Exception as e:
        logger.error(f"❌ Registration failed: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to register user"
        )


@router.post("/email")
def email_sign_in(payload: EmailAuthRequest, session: Session = Depends(get_session)):
    """Check if user exists by email and auto sign-in if they do."""
    import logging
    logger = logging.getLogger(__name__)

    normalized_email = payload.email.strip().lower()
    logger.info(f"📧 Email check request for: {normalized_email}")

    user = user_crud.get_by_email(session, normalized_email)
    
    if user:
        # User exists - auto sign-in
        logger.info(f"✓ User exists for email: {normalized_email} - auto sign-in")
        
        # Update name and google_id if provided
        if payload.name and user.name == "Email User":
            user.name = payload.name
        if payload.google_id and not user.google_id:
            user.google_id = payload.google_id
        user.is_verified = True
        session.add(user)
        session.commit()
        session.refresh(user)
        
        token = create_access_token(
            data={"sub": str(user.id)},
            expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
        )

        return AuthResponse(
            token=TokenResponse(
                access_token=token,
                expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            ),
            user_id=str(user.id),
            name=user.name,
            email=user.email,
            phone_number=user.phone_number,
        )
    else:
        # New user - if name is provided, create account and return token
        if payload.name:
            logger.info(f"📝 Creating new email user: {normalized_email}")
            try:
                user = user_crud.create_user(
                    session,
                    name=payload.name,
                    email=normalized_email,
                    google_id=payload.google_id,
                    is_verified=True,
                )

                token = create_access_token(
                    data={"sub": str(user.id)},
                    expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
                )

                return AuthResponse(
                    token=TokenResponse(
                        access_token=token,
                        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
                    ),
                    user_id=str(user.id),
                    name=user.name,
                    email=user.email,
                    phone_number=user.phone_number,
                )
            except Exception as e:
                # If user was created between check and creation, fetch and sign them in
                logger.warning(f"⚠️ User creation failed (likely duplicate): {e}")
                session.rollback()
                user = user_crud.get_by_email(session, normalized_email)
                if user:
                    logger.info(f"✓ User found after duplicate error - auto sign-in")
                    token = create_access_token(
                        data={"sub": str(user.id)},
                        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
                    )
                    return AuthResponse(
                        token=TokenResponse(
                            access_token=token,
                            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
                        ),
                        user_id=str(user.id),
                        name=user.name,
                        email=user.email,
                        phone_number=user.phone_number,
                    )
                raise HTTPException(status_code=500, detail="Failed to create user")

        # New user - return user_exists flag so frontend shows registration
        logger.info(f"👤 New user for email: {normalized_email} - show registration form")
        return EmailCheckResponse(
            success=True,
            message="Email not registered. Please create an account.",
            user_exists=False,
        )


from fastapi import Form
import json

@router.post("/upload-face")
def upload_face_image(
    file: UploadFile = File(...),
    face_type: str = Form("straight"),
    embedding: str = Form(None),
    session: Session = Depends(get_session),
    authorization: str = Header(None),
):
    """Upload a face image for the current user, with optional embedding vector."""
    import logging
    from uuid import UUID
    logger = logging.getLogger(__name__)
    try:
        # Extract token from Authorization header
        if not authorization or not authorization.startswith("Bearer "):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authorization header missing or invalid",
            )
        token = authorization[7:]
        logger.info(f"📸 Processing face image upload: {face_type}")
        payload = decode_access_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token",
            )
        user_id_str = payload.get("sub")
        if not user_id_str:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token",
            )
        user_id = UUID(user_id_str)
        current_user = user_crud.get_user(session, user_id)
        if not current_user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )
        logger.info(f"📸 Uploading face image for user: {current_user.id}")
        faces_dir = Path("uploads/faces")
        faces_dir.mkdir(parents=True, exist_ok=True)
        import time
        filename = f"{current_user.id}_{int(time.time() * 1000)}.jpg"
        filepath = faces_dir / filename
        contents = file.file.read()
        with open(filepath, "wb") as f:
            f.write(contents)
        logger.info(f"✓ Face image saved: {filepath}")
        # Parse embedding if provided
        embedding_list = None
        if embedding:
            try:
                embedding_list = json.loads(embedding)
            except Exception as emb_err:
                logger.error(f"Invalid embedding JSON: {emb_err}")
        try:
            face_record = face_crud.create_face_record(
                session,
                user_id=str(current_user.id),
                face_type=face_type,
                file_path=str(filepath),
                file_name=filename,
                embedding=embedding_list,
            )
            logger.info(f"✓ Face record created in DB: {face_record.id}")
        except Exception as db_error:
            logger.error(f"⚠️  File saved but DB record failed: {str(db_error)}")
            # Remove the saved file if DB insert fails
            try:
                os.remove(filepath)
            except Exception as file_rm_err:
                logger.error(f"Failed to remove file after DB error: {file_rm_err}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to save face record to database: {str(db_error)}",
            )
        return {
            "success": True,
            "message": "Face image uploaded successfully",
            "filename": filename,
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Face upload error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to upload face image: {str(e)}",
        )

@router.post("/phone/send-otp", response_model=PhoneSendOtpResponse)
def send_phone_otp(payload: PhoneSendOtpRequest, session: Session = Depends(get_session)):
    import logging
    logger = logging.getLogger(__name__)
    
    logger.info(f"📱 OTP request for phone: {payload.phone_number}")
    
    # Check if user already exists with this phone number
    existing_user = user_crud.get_by_phone(session, payload.phone_number)
    user_exists = existing_user is not None
    
    # Send OTP regardless
    OtpService.send_otp(payload.phone_number)
    
    if user_exists:
        logger.info(f"✓ User exists for phone: {payload.phone_number} - skip face capture")
        message = "OTP sent. Please verify to sign in."
    else:
        logger.info(f"👤 New user for phone: {payload.phone_number} - will capture face after OTP")
        message = "OTP sent. You will capture face after verification."
    
    return PhoneSendOtpResponse(
        success=True,
        message=message,
        user_exists=user_exists
    )


@router.post("/phone/verify-otp", response_model=AuthResponse)
def verify_phone_otp(payload: PhoneVerifyOtpRequest, session: Session = Depends(get_session)):
    import logging
    logger = logging.getLogger(__name__)
    
    logger.info(f"📱 Phone OTP Verification for: {payload.phone_number}")
    
    if not OtpService.verify_otp(payload.phone_number, payload.otp):
        logger.error("❌ Invalid OTP")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid OTP")

    user = user_crud.get_by_phone(session, payload.phone_number)
    if not user:
        # Create new user with provided name or default
        user_name = payload.name or "Phone User"
        logger.info(f"👤 Creating new user with name: {user_name}")
        user = user_crud.create_user(
            session,
            name=user_name,
            phone_number=payload.phone_number,
            google_id=payload.google_id,  # Save google_id if provided
            is_verified=True,
        )
    else:
        # Update existing user with name if provided
        if payload.name and user.name == "Phone User":
            user.name = payload.name
        # Update google_id if provided and not already set
        if payload.google_id and not user.google_id:
            user.google_id = payload.google_id
        user.is_verified = True
        session.add(user)
        session.commit()
        session.refresh(user)

    logger.info(f"✓ OTP verified for user: {user.id}")

    token = create_access_token(
        data={"sub": str(user.id)},
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
    )

    return AuthResponse(
        token=TokenResponse(
            access_token=token,
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        ),
        user_id=str(user.id),
        name=user.name,
        email=user.email,
        phone_number=user.phone_number,
    )


@router.post("/email/send-otp", response_model=EmailSendOtpResponse)
def send_email_otp(payload: EmailSendOtpRequest, session: Session = Depends(get_session)):
    """Send OTP to email for verification"""
    import logging
    from app.services.email_service import EmailService
    logger = logging.getLogger(__name__)
    
    normalized_email = payload.email.strip().lower()
    logger.info(f"📧 OTP request for email: {normalized_email}")
    
    # Check if user already exists with this email
    existing_user = user_crud.get_by_email(session, normalized_email)
    user_exists = existing_user is not None
    
    print('REACHED OTP ENDPOINT')
    import traceback
    try:
        # Generate OTP and store it
        otp_code = OtpService.send_otp(normalized_email)
        logger.info(f"✓ OTP generated: {otp_code}")

        # Send OTP email
        email_sent = EmailService.send_otp_email(normalized_email, otp_code)

        if not email_sent:
            logger.error(f"❌ Failed to send OTP email to: {normalized_email}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to send OTP email. Please try again."
            )
    except Exception as e:
        logger.error(f"❌ Exception in send_email_otp: {e}")
        print("\n--- TRACEBACK ---\n" + traceback.format_exc() + "\n--- END TRACEBACK ---\n")
        traceback.print_exc()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal Server Error: {e}"
        )
    
    if user_exists:
        logger.info(f"✓ User exists for email: {normalized_email} - OTP for sign in")
        message = "OTP sent to your Gmail inbox. Please verify to sign in."
    else:
        logger.info(f"👤 New user for email: {normalized_email} - OTP for registration")
        message = "OTP sent to your Gmail inbox. Please verify to create account."
    
    return EmailSendOtpResponse(
        success=True,
        message=message,
        user_exists=user_exists
    )


@router.post("/email/verify-otp", response_model=AuthResponse)
def verify_email_otp(payload: EmailVerifyOtpRequest, session: Session = Depends(get_session)):
    """Verify email OTP and sign in or create new user"""
    import logging
    logger = logging.getLogger(__name__)
    
    normalized_email = payload.email.strip().lower()
    logger.info(f"📧 Email OTP Verification for: {normalized_email}")
    
    if not OtpService.verify_otp(normalized_email, payload.otp):
        logger.error("❌ Invalid OTP")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid OTP")

    user = user_crud.get_by_email(session, normalized_email)
    if not user:
        # Create new user with provided name or default
        user_name = payload.name or "Email User"
        logger.info(f"👤 Creating new user with name: {user_name}")
        try:
            user = user_crud.create_user(
                session,
                name=user_name,
                email=normalized_email,
                google_id=getattr(payload, 'google_id', None),  # Save google_id if provided
                is_verified=True,
            )
            user_exists = False
        except Exception as e:
            # If user was created between check and creation, fetch and sign them in
            logger.warning(f"⚠️ User creation failed (likely duplicate): {e}")
            session.rollback()
            user = user_crud.get_by_email(session, normalized_email)
            if not user:
                raise HTTPException(status_code=500, detail="Failed to create user")
            user_exists = True
    else:
        # Update existing user with name if provided
        if payload.name and user.name in ["Email User", "Google User"]:
            user.name = payload.name
        # Update google_id if provided and not already set
        if hasattr(payload, 'google_id') and payload.google_id and not user.google_id:
            user.google_id = payload.google_id
        user.is_verified = True
        session.add(user)
        session.commit()
        session.refresh(user)
        user_exists = True

    logger.info(f"✓ OTP verified for user: {user.id}")

    token = create_access_token(
        data={"sub": str(user.id)},
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
    )

    return AuthResponse(
        token=TokenResponse(
            access_token=token,
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        ),
        user_id=str(user.id),
        name=user.name,
        email=user.email,
        phone_number=user.phone_number,
        user_exists=user_exists,
    )
