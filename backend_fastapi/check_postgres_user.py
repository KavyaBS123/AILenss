"""Check users in PostgreSQL database"""
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="ailens_db",
    user="ailens_user",
    password="ailens_password123"
)

cursor = conn.cursor()

# Check if users table exists
cursor.execute("""
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'users'
    );
""")
table_exists = cursor.fetchone()[0]

if table_exists:
    print("✓ Users table exists")
    
    # Get table schema
    cursor.execute("""
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_name = 'users'
        ORDER BY ordinal_position;
    """)
    columns = cursor.fetchall()
    
    print("\n📋 Users table schema:")
    for col_name, data_type, nullable in columns:
        print(f"  - {col_name}: {data_type} ({'NULL' if nullable == 'YES' else 'NOT NULL'})")
    
    # Check for specific email
    email = "kavyabscse2026@gmail.com"
    print(f"\n🔍 Searching for user with email: {email}")
    
    cursor.execute("SELECT id, name, email, phone_number, is_verified FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()
    
    if user:
        print(f"✓ Found user:")
        print(f"  - ID: {user[0]}")
        print(f"  - Name: {user[1]}")
        print(f"  - Email: {user[2]}")
        print(f"  - Phone: {user[3]}")
        print(f"  - Verified: {user[4]}")
    else:
        print(f"✗ User not found")
        
        # Show all users
        cursor.execute("SELECT COUNT(*) FROM users")
        count = cursor.fetchone()[0]
        print(f"\n📊 Total users in database: {count}")
        
        if count > 0:
            cursor.execute("SELECT email, name FROM users WHERE email IS NOT NULL")
            all_users = cursor.fetchall()
            print("\nAll users with emails:")
            for email_val, name in all_users:
                print(f"  - {email_val} ({name})")
else:
    print("✗ Users table does not exist")

conn.close()
