from uuid import UUID
from sqlmodel import Session, select
from app.models.face import FaceData


def create_face_record(
    session: Session,
    user_id: UUID,
    face_type: str,
    file_path: str,
    file_name: str,
) -> FaceData:
    """Create a new face record."""
    face_data = FaceData(
        user_id=user_id,
        face_type=face_type,
        file_path=file_path,
        file_name=file_name,
    )
    session.add(face_data)
    session.commit()
    session.refresh(face_data)
    return face_data


def get_user_faces(session: Session, user_id: UUID) -> list[FaceData]:
    """Get all face records for a user."""
    statement = select(FaceData).where(FaceData.user_id == user_id)
    return session.exec(statement).all()


def get_face_by_type(
    session: Session,
    user_id: UUID,
    face_type: str,
) -> FaceData | None:
    """Get a specific face record by type."""
    statement = select(FaceData).where(
        (FaceData.user_id == user_id) & (FaceData.face_type == face_type)
    )
    return session.exec(statement).first()


def delete_user_faces(session: Session, user_id: UUID) -> None:
    """Delete all face records for a user."""
    statement = select(FaceData).where(FaceData.user_id == user_id)
    faces = session.exec(statement).all()
    for face in faces:
        session.delete(face)
    session.commit()
