import sqlite3
import base64
from datetime import datetime

# Sample dummy data for biometrics
DUMMY_FACE_DATA = base64.b64encode(b"FACE_SAMPLE_DATA_" + b"X" * 1000).decode()
DUMMY_FACE_EMBEDDING = str([0.1 * i for i in range(128)])

DUMMY_VOICE_DATA = base64.b64encode(b"VOICE_SAMPLE_DATA_" + b"Y" * 1500).decode()
DUMMY_VOICE_EMBEDDING = str([0.2 * i for i in range(256)])

# Pre-hashed bcrypt passwords (generated externally)
# john / Test123
JOHN_HASH = "$2b$12$s4DkZMbm9ByGxQQdvVf0u.zGJx0OyaE0Z0P0QJrQ8J9QJKYXZvGma"
# jane / Test123  
JANE_HASH = "$2b$12$s4DkZMbm9ByGxQQdvVf0u.zGJx0OyaE0Z0P0QJrQ8J9QJKYXZvGma"
# demo / Demo123
DEMO_HASH = "$2b$12$qBaLOSwBniqQ9NBNB7YhWOt6TtI0Oi3L4H5j7bKmN2pGqZ5.pW2uS"

test_users = [
    {
        "email": "john@ailens.app",
        "first_name": "John",
        "last_name": "Doe",
        "phone": "+1234567890",
        "hashed_password": JOHN_HASH,
        "face_registered": True,
        "voice_registered": True,
    },
    {
        "email": "jane@ailens.app",
        "first_name": "Jane",
        "last_name": "Smith",
        "phone": "+1987654321",
        "hashed_password": JANE_HASH,
        "face_registered": True,
        "voice_registered": False,
    },
    {
        "email": "demo@ailens.app",
        "first_name": "Demo",
        "last_name": "User",
        "phone": "+1111111111",
        "hashed_password": DEMO_HASH,
        "face_registered": True,
        "voice_registered": True,
    },
]

def insert_test_users():
    """Insert test users with dummy biometric data using direct SQL"""
    conn = sqlite3.connect('ailens.db')
    cursor = conn.cursor()
    
    try:
        print("🔧 Inserting test users with dummy biometric data...\n")
        
        now = datetime.utcnow().isoformat()
        
        for user_data in test_users:
            # Check if user exists
            cursor.execute("SELECT id FROM users WHERE email = ?", (user_data["email"],))
            existing = cursor.fetchone()
            
            if existing:
                print(f"⏭️  Skipping {user_data['email']} (already exists)")
                continue
            
            # Insert user
            cursor.execute("""
                INSERT INTO users (
                    email, first_name, last_name, phone, hashed_password,
                    is_active, is_verified, otp, otp_created_at,
                    face_data, face_embedding, face_registered,
                    voice_data, voice_embedding, voice_registered,
                    created_at, updated_at, 
                    face_registered_at, voice_registered_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                user_data["email"],
                user_data["first_name"],
                user_data["last_name"],
                user_data["phone"],
                user_data["hashed_password"],
                True,  # is_active
                True,  # is_verified
                "123456",  # otp
                now,  # otp_created_at
                DUMMY_FACE_DATA if user_data["face_registered"] else None,
                DUMMY_FACE_EMBEDDING if user_data["face_registered"] else None,
                user_data["face_registered"],
                DUMMY_VOICE_DATA if user_data["voice_registered"] else None,
                DUMMY_VOICE_EMBEDDING if user_data["voice_registered"] else None,
                user_data["voice_registered"],
                now,  # created_at
                now,  # updated_at
                now if user_data["face_registered"] else None,
                now if user_data["voice_registered"] else None,
            ))
            
            face_status = "✓ Face" if user_data["face_registered"] else "✗ Face"
            voice_status = "✓ Voice" if user_data["voice_registered"] else "✗ Voice"
            print(f"✅ Created: {user_data['email']:25} | {face_status:15} | {voice_status:15}")
        
        conn.commit()
        print("\n✅ All test users created successfully!\n")
        
        # Display summary
        cursor.execute("SELECT COUNT(*) FROM users")
        total = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM users WHERE face_registered = 1")
        face = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM users WHERE voice_registered = 1")
        voice = cursor.fetchone()[0]
        
        print("📊 Database Summary:")
        print(f"   Total users: {total}")
        print(f"   Face registered: {face}")
        print(f"   Voice registered: {voice}")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    insert_test_users()
