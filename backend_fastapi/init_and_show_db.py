import sys
sys.path.insert(0, 'c:\\Users\\Kavya\\OneDrive\\Desktop\\AILens\\backend_fastapi')

from app.core.database import create_db_and_tables
import sqlite3

# Create tables
create_db_and_tables()
print("✅ Database tables created successfully")

# Now display the schema
conn = sqlite3.connect('ailens.db')
cursor = conn.cursor()
cursor.execute('PRAGMA table_info(users)')
cols = cursor.fetchall()

print("\n" + "="*80)
print("📋 DATABASE SCHEMA - USERS TABLE")
print("="*80)
print(f"{'Column':<30} {'Type':<20} {'Nullable':<12} {'PK':<5}")
print("-"*80)

for col in cols:
    col_id, name, col_type, not_null, default, pk = col
    nullable = "NO" if not_null else "YES"
    pk_flag = "✓" if pk else ""
    print(f"{name:<30} {col_type:<20} {nullable:<12} {pk_flag:<5}")

print("-"*80)
print(f"Total columns: {len(cols)}")
conn.close()
