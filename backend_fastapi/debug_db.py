import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

# Import models to register them
from app.models.user import User
from app.core.database import engine, create_db_and_tables
from sqlmodel import SQLModel
import sqlite3

# Check if User model is registered
print("📦 Checking SQLModel metadata:")
print(f"User model: {User}")
print(f"User fields: {User.__fields__.keys() if hasattr(User, '__fields__') else 'N/A'}")
print(f"SQLModel metadata tables: {SQLModel.metadata.tables.keys()}")

# Create tables
print("\n🔧 Creating database tables...")
create_db_and_tables()
print("✅ Tables created")

# Query the actual database
print("\n" + "="*100)
print("📋 DATABASE SCHEMA - USERS TABLE")
print("="*100)

conn = sqlite3.connect('ailens.db')
cursor = conn.cursor()

# Get table list
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables = cursor.fetchall()
print(f"\nTables in database: {[t[0] for t in tables]}\n")

# Get users table info
cursor.execute('PRAGMA table_info(users)')
cols = cursor.fetchall()

if cols:
    print(f"{'#':<4} {'Column':<30} {'Type':<20} {'Nullable':<12} {'Default':<15} {'PK':<5}")
    print("-"*100)
    for col in cols:
        col_id, name, col_type, not_null, default, pk = col
        nullable = "NO" if not_null else "YES"
        pk_flag = "✓" if pk else ""
        default_val = default or "NULL"
        print(f"{col_id:<4} {name:<30} {col_type:<20} {nullable:<12} {default_val:<15} {pk_flag:<5}")
    print("-"*100)
    print(f"\n✅ Total columns: {len(cols)}")
else:
    print("❌ No columns found in users table!")

conn.close()
