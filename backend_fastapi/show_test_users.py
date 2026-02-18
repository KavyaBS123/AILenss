import sqlite3

conn = sqlite3.connect('ailens.db')
c = conn.cursor()
c.execute('SELECT id, email, first_name, last_name, is_verified, face_registered, voice_registered FROM users ORDER BY id')
rows = c.fetchall()

print("\n" + "="*110)
print("📊 TEST USERS IN DATABASE")
print("="*110)
print(f"{'ID':<5} {'Email':<25} {'Name':<25} {'Verified':<12} {'Face':<10} {'Voice':<10}")
print("-"*110)

for r in rows:
    uid, email, fname, lname, verified, face, voice = r
    name = f"{fname} {lname}"
    verified_str = "✓" if verified else "✗"
    face_str = "✓" if face else "✗"
    voice_str = "✓" if voice else "✗"
    print(f"{uid:<5} {email:<25} {name:<25} {verified_str:<12} {face_str:<10} {voice_str:<10}")

print("-"*110)

# Show biometric data sizes
c.execute('SELECT email, LENGTH(face_data) as face_size, LENGTH(voice_data) as voice_size FROM users WHERE face_data IS NOT NULL OR voice_data IS NOT NULL')
bio_rows = c.fetchall()

if bio_rows:
    print("\n📦 BIOMETRIC DATA STORAGE:")
    print("-"*110)
    for email, face_size, voice_size in bio_rows:
        face_info = f"{face_size} bytes" if face_size else "N/A"
        voice_info = f"{voice_size} bytes" if voice_size else "N/A"
        print(f"   {email:<25} | Face: {face_info:<15} | Voice: {voice_info:<15}")

conn.close()
