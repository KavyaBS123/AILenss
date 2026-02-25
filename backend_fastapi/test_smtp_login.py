import smtplib

smtp_server = "smtp.zoho.com"
smtp_port = 465
smtp_email = "kavya.bs@contentlens.ai"
smtp_password = "78Quq2ZSBk2u"

try:
    with smtplib.SMTP_SSL(smtp_server, smtp_port, timeout=10) as server:
        server.login(smtp_email, smtp_password)
    print("✅ SMTP login successful!")
except smtplib.SMTPAuthenticationError as e:
    print("❌ SMTP Authentication failed:", e)
except Exception as e:
    print("❌ Other SMTP error:", e)
