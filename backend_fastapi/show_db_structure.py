#!/usr/bin/env python
"""Script to display database structure and user data"""

import os
import sys
from sqlmodel import Session, select
from app.core.database import engine
from app.models.user import User
from sqlalchemy import inspect
from datetime import datetime

def print_separator(title=""):
    print("\n" + "="*80)
    if title:
        print(f"  {title}")
        print("="*80)

def show_table_structure():
    """Display Users table structure"""
    print_separator("DATABASE TABLE STRUCTURE")
    
    inspector = inspect(engine)
    
    print("\n📋 TABLE: users")
    print("-" * 80)
    print(f"{'Column Name':<20} {'Data Type':<25} {'Nullable':<12} {'Constraints':<20}")
    print("-" * 80)
    
    columns = inspector.get_columns('users')
    for col in columns:
        nullable = "YES" if col['nullable'] else "NO"
        col_type = str(col['type'])
        print(f"{col['name']:<20} {col_type:<25} {nullable:<12}")
    
    print("\n🔑 INDEXES & CONSTRAINTS:")
    print("-" * 80)
    indexes = inspector.get_indexes('users')
    pk = inspector.get_pk_constraint('users')
    
    if pk:
        print(f"  PRIMARY KEY: {pk['constrained_columns']}")
    
    for idx in indexes:
        idx_type = "UNIQUE" if idx['unique'] else "INDEX"
        columns_str = ", ".join(idx['column_names'])
        print(f"  {idx_type:<10} {idx['name']:<30} ON ({columns_str})")

def show_users_data():
    """Display all users in the database"""
    print_separator("LOGGED USERS DATA")
    
    with Session(engine) as session:
        users = session.exec(select(User).order_by(User.created_at.desc())).all()
        
        if not users:
            print("\n❌ No users found in database")
            return
        
        print(f"\n✅ Total Users: {len(users)}")
        print("-" * 140)
        print(f"{'ID':<38} {'Name':<20} {'Email':<25} {'Phone':<15} {'Verified':<10} {'Google':<10} {'Created':<20}")
        print("-" * 140)
        
        for user in users:
            verified = "✓" if user.is_verified else "✗"
            google = "✓" if user.google_id else "✗"
            created = user.created_at.strftime("%Y-%m-%d %H:%M:%S") if user.created_at else "N/A"
            
            print(f"{str(user.id):<38} {user.name:<20} {(user.email or 'N/A'):<25} {(user.phone_number or 'N/A'):<15} {verified:<10} {google:<10} {created:<20}")
        
        print("-" * 140)
        
        # Summary statistics
        verified_count = sum(1 for u in users if u.is_verified)
        google_count = sum(1 for u in users if u.google_id)
        phone_count = sum(1 for u in users if u.phone_number)
        email_count = sum(1 for u in users if u.email)
        
        print(f"\n📊 STATISTICS:")
        print(f"  • Total Users:        {len(users)}")
        print(f"  • Verified Users:     {verified_count}")
        print(f"  • Google Sign-in:     {google_count}")
        print(f"  • Phone Users:        {phone_count}")
        print(f"  • Email Users:        {email_count}")

def main():
    print("""
    
╔════════════════════════════════════════════════════════════════════════════╗
║                     AILens DATABASE INSPECTOR                              ║
║                                                                            ║
║  This script displays the PostgreSQL database structure and user data     ║
╚════════════════════════════════════════════════════════════════════════════╝
    """)
    
    try:
        show_table_structure()
        show_users_data()
        print_separator("COMPLETE")
        print("\n✅ Database inspection completed successfully!\n")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
