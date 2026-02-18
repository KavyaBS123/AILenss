import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), 'ailens.db')

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Get all tables
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
    tables = cursor.fetchall()
    
    print("=" * 80)
    print("DATABASE STRUCTURE: ailens.db")
    print("=" * 80)
    print(f"\nTables found: {[t[0] for t in tables]}\n")
    
    # Get users table schema
    cursor.execute("PRAGMA table_info(users)")
    columns = cursor.fetchall()
    
    print("📋 USERS TABLE SCHEMA:")
    print("-" * 80)
    print(f"{'Column Name':<25} {'Type':<20} {'Nullable':<10} {'Primary Key':<15}")
    print("-" * 80)
    
    for col in columns:
        col_id, name, col_type, not_null, default, pk = col
        nullable = "NO" if not_null else "YES"
        pk_indicator = "✓ PK" if pk else ""
        print(f"{name:<25} {col_type:<20} {nullable:<10} {pk_indicator:<15}")
    
    print("-" * 80)
    
    # Get row count
    cursor.execute("SELECT COUNT(*) FROM users")
    count = cursor.fetchone()[0]
    print(f"\n📊 Total users in database: {count}")
    
    # Get any existing users
    if count > 0:
        cursor.execute("SELECT id, email, first_name, last_name, is_verified, face_registered, voice_registered FROM users")
        users = cursor.fetchall()
        print("\nExisting Users:")
        print("-" * 80)
        print(f"{'ID':<5} {'Email':<30} {'Name':<25} {'Verified':<10} {'Face':<8} {'Voice':<8}")
        print("-" * 80)
        for user in users:
            uid, email, first_name, last_name, verified, face, voice = user
            name = f"{first_name} {last_name}"
            print(f"{uid:<5} {email:<30} {name:<25} {'✓' if verified else '✗':<10} {'✓' if face else '✗':<8} {'✓' if voice else '✗':<8}")
    
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
