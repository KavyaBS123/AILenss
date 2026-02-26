
from typing import Optional
from sqlmodel import Session, select
from app.models.user import User
from app.core.security import verify_password



def get_by_email(session: Session, email: str) -> Optional[User]:
    statement = select(User).where(User.email == email)
    return session.exec(statement).first()


def get_by_phone(session: Session, phone_number: str) -> Optional[User]:
    statement = select(User).where(User.phone_number == phone_number)
    return session.exec(statement).first()


def get_by_google_id(session: Session, google_id: str) -> Optional[User]:
    statement = select(User).where(User.google_id == google_id)
    return session.exec(statement).first()


def get_by_id(session: Session, user_id) -> Optional[User]:
    return session.get(User, user_id)


def get_user(session: Session, user_id) -> Optional[User]:
    """Alias for get_by_id - get user by ID"""
    return session.get(User, user_id)


def create_user(
    session: Session,
    *,
    name: str,
    email: Optional[str] = None,
    phone_number: Optional[str] = None,
    google_id: Optional[str] = None,
    hashed_password: Optional[str] = None,
    is_verified: bool = False,
) -> User:
    user = User(
        name=name,
        email=email,
        phone_number=phone_number,
        google_id=google_id,
        hashed_password=hashed_password,
        is_verified=is_verified,
    )
    try:
        session.add(user)
        session.commit()
        session.refresh(user)
    except Exception as e:
        session.rollback()
        print("DB ERROR:", str(e))
        import traceback
        print(traceback.format_exc())
        raise
    return user


def verify_user_password(user: User, plain_password: str) -> bool:
    """Verify a user's password"""
    if not user.hashed_password:
        return False
    return verify_password(plain_password, user.hashed_password)
