import sys
import os
import base64
from datetime import datetime
sys.path.insert(0, os.path.dirname(__file__))

from app.models.user import User
from app.core.database import SessionLocal
from sqlmodel import select
from passlib.context import CryptContext

# Initialize password context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Sample dummy data for biometrics
# These are base64 encoded dummy values for demonstration
DUMMY_FACE_DATA = base64.b64encode(b"FACE_SAMPLE_DATA_" + b"X" * 1000).decode()  # Simulated face image
DUMMY_FACE_EMBEDDING = str([0.1 * i for i in range(128)])  # 128-dimensional face embedding vector

DUMMY_VOICE_DATA = base64.b64encode(b"VOICE_SAMPLE_DATA_" + b"Y" * 1500).decode()  # Simulated voice recording
DUMMY_VOICE_EMBEDDING = str([0.2 * i for i in range(256)])  # 256-dimensional voice embedding vector

# Create test users
test_users = [
    {
        "email": "john@ailens.app",
        "first_name": "John",
        "last_name": "Doe",
        "phone": "+1234567890",
        "password": "Test123",
        "face_registered": True,
        "voice_registered": True,
    },
    {
        "email": "jane@ailens.app",
        "first_name": "Jane",
        "last_name": "Smith",
        "phone": "+1987654321",
        "password": "Test123",
        "face_registered": True,
        "voice_registered": False,  # Only face registered
    },
    {
        "email": "demo@ailens.app",
        "first_name": "Demo",
        "last_name": "User",
        "phone": "+1111111111",
        "password": "Demo123",
        "face_registered": True,
        "voice_registered": True,
    },
]

def insert_test_users():
    """Insert test users with dummy biometric data"""
    session = SessionLocal()
    
    try:
        print("🔧 Inserting test users with dummy biometric data...\n")
        
        for user_data in test_users:
            # Check if user already exists
            statement = select(User).where(User.email == user_data["email"])
            existing = session.exec(statement).first()
            if existing:
                print(f"⏭️  Skipping {user_data['email']} (already exists)")
                continue
            
            # Create user
            user = User(
                email=user_data["email"],
                first_name=user_data["first_name"],
                last_name=user_data["last_name"],
                phone=user_data["phone"],
                hashed_password=pwd_context.hash(user_data["password"]),
                is_active=True,
                is_verified=True,  # Pre-verified for testing
                otp="123456",
                otp_created_at=datetime.utcnow(),
                
                # Biometric data
                face_data=DUMMY_FACE_DATA if user_data["face_registered"] else None,
                face_embedding=DUMMY_FACE_EMBEDDING if user_data["face_registered"] else None,
                face_registered=user_data["face_registered"],
                face_registered_at=datetime.utcnow() if user_data["face_registered"] else None,
                
                voice_data=DUMMY_VOICE_DATA if user_data["voice_registered"] else None,
                voice_embedding=DUMMY_VOICE_EMBEDDING if user_data["voice_registered"] else None,
                voice_registered=user_data["voice_registered"],
                voice_registered_at=datetime.utcnow() if user_data["voice_registered"] else None,
            )
            
            session.add(user)
            session.commit()
            
            face_status = "✓ Face" if user_data["face_registered"] else "✗ Face"
            voice_status = "✓ Voice" if user_data["voice_registered"] else "✗ Voice"
            print(f"✅ Created: {user_data['email']:25} | {face_status:15} | {voice_status:15}")
        
        print("\n✅ All test users created successfully!\n")
        
        # Display summary
        all_users = session.exec(select(User)).all()
        total_users = len(all_users)
        face_users = len([u for u in all_users if u.face_registered])
        voice_users = len([u for u in all_users if u.voice_registered])
        
        print("📊 Database Summary:")
        print(f"   Total users: {total_users}")
        print(f"   Face registered: {face_users}")
        print(f"   Voice registered: {voice_users}")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        session.rollback()
    finally:
        session.close()

if __name__ == "__main__":
    insert_test_users()
