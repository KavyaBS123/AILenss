"""Quick script to check if user exists in database"""
import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), 'ailens.db')
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Check for the email
email = "kavyabscse2026@gmail.com"
print(f"\n🔍 Searching for user with email: {email}")

# Try exact match
cursor.execute("SELECT id, name, email, phone_number, is_verified FROM users WHERE email = ?", (email,))
user = cursor.fetchone()

if user:
    print(f"✓ Found user:")
    print(f"  - ID: {user[0]}")
    print(f"  - Name: {user[1]}")
    print(f"  - Email: {user[2]}")
    print(f"  - Phone: {user[3]}")
    print(f"  - Verified: {user[4]}")
else:
    print(f"✗ User not found with exact email")
    
    # Try case-insensitive
    print(f"\n🔍 Trying case-insensitive search...")
    cursor.execute("SELECT COUNT(*) FROM users")
    count = cursor.fetchone()[0]
    print(f"Total users in database: {count}")
    
    cursor.execute("SELECT id, name, email, phone_number, is_verified FROM users WHERE LOWER(email) = LOWER(?)", (email,))
    user = cursor.fetchone()
    
    if user:
        print(f"\n✓ Found user with different case:")
        print(f"  - ID: {user[0]}")
        print(f"  - Name: {user[1]}")
        print(f"  - Email (stored): '{user[2]}'")
        print(f"  - Phone: {user[3]}")
        print(f"  - Verified: {user[4]}")
    else:
        print(f"\n✗ No user found even with case-insensitive search")
        print(f"\nAll users with emails:")
        cursor.execute("SELECT email, name FROM users WHERE email IS NOT NULL")
        all_users = cursor.fetchall()
        for email_val, name in all_users:
            print(f"  - {email_val} ({name})")

conn.close()
