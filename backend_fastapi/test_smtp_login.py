smtp_server = "smtp.zoho.in"
smtp_port = 465

smtp_email = "kavya.bs@contentlens.ai"
smtp_password = "5qSg2Zv2y7f4"


import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

sender_email = "kavya.bs@contentlens.ai"
receiver_email = "kavyabsalawadagi@gmail.com"
subject = "Zoho SMTP Test Email"
body = "This is a test email sent from Zoho SMTP using FastAPI backend script."

msg = MIMEMultipart()
msg["From"] = sender_email
msg["To"] = receiver_email
msg["Subject"] = subject
msg.attach(MIMEText(body, "plain"))

try:
    with smtplib.SMTP_SSL(smtp_server, smtp_port, timeout=10) as server:
        server.login(smtp_email, smtp_password)
        server.sendmail(sender_email, receiver_email, msg.as_string())
    print(f"✅ Test email sent successfully from {sender_email} to {receiver_email}")
except smtplib.SMTPAuthenticationError as e:
    print("❌ SMTP Authentication failed:", e)
except Exception as e:
    print("❌ Other SMTP error:", e)
